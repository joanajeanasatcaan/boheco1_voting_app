import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/voter.dart';
import '../models/nominee.dart';

class ApiService {
  static const String baseUrl = 'http://192.168.12.185:8000/api';

  // ─────────────────────────────────────────────────────────────
  // GET /api/members/{id}
  // ─────────────────────────────────────────────────────────────
  static Future<ApiResult<Voter>> getVoterById(String id) async {
    final uri = Uri.parse('$baseUrl/voters/members/$id');

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timed out'),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final data = body['data'] ?? body;
        return ApiResult.success(Voter.fromJson(data));
      } else if (response.statusCode == 404) {
        return ApiResult.error('Voter not found');
      } else {
        return ApiResult.error(
            body['message'] ?? 'Unexpected error (${response.statusCode})');
      }
    } on Exception catch (e) {
      return ApiResult.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // GET /api/nominees
  // ─────────────────────────────────────────────────────────────
  static Future<ApiResult<List<Nominee>>> getNominees() async {
    final uri = Uri.parse('$baseUrl/voters/nominees');

    try {
      final response = await http.get(
        uri,
        headers: {'Accept': 'application/json'},
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('Request timed out'),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200) {
        final List<dynamic> list = body['data'] ?? body;
        final nominees = list
            .map((e) => Nominee.fromJson(e as Map<String, dynamic>))
            .toList();
        return ApiResult.success(nominees);
      } else {
        return ApiResult.error(
            body['message'] ?? 'Failed to load nominees (${response.statusCode})');
      }
    } on Exception catch (e) {
      return ApiResult.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  // ─────────────────────────────────────────────────────────────
  // POST /api/vote
  // ─────────────────────────────────────────────────────────────
  static Future<ApiResult<bool>> submitVote({
    required int nomineeId,
    required String memberId,
  }) async {
    // "No Vote" sentinel — nothing to POST, treat as success
    if (nomineeId == -1) return ApiResult.success(true);

    final uri = Uri.parse('$baseUrl/voters/vote');

    try {
      final response = await http.post(
        uri,
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'nominee_id':   nomineeId,
          'member_id':    memberId,
          'voted_method': 'Onsite',
        }),
      ).timeout(
        const Duration(seconds: 15),
        onTimeout: () => throw Exception('Request timed out'),
      );

      final body = json.decode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResult.success(true);
      } else if (response.statusCode == 409) {
        return ApiResult.error('This household has already voted.');
      } else if (response.statusCode == 403) {
        return ApiResult.error(body['message'] ?? 'Voter is not verified.');
      } else if (response.statusCode == 422) {
        return ApiResult.error(body['message'] ?? 'Invalid submission. Please try again.');
      } else {
        return ApiResult.error(
            body['message'] ?? 'Vote failed (${response.statusCode})');
      }
    } on Exception catch (e) {
      return ApiResult.error(e.toString().replaceFirst('Exception: ', ''));
    }
  }
}

// ─────────────────────────────────────────────────────────────
// Simple result wrapper
// ─────────────────────────────────────────────────────────────
class ApiResult<T> {
  final T? data;
  final String? errorMessage;
  final bool isSuccess;

  const ApiResult._({this.data, this.errorMessage, required this.isSuccess});

  factory ApiResult.success(T data) =>
      ApiResult._(data: data, isSuccess: true);

  factory ApiResult.error(String message) =>
      ApiResult._(errorMessage: message, isSuccess: false);
}