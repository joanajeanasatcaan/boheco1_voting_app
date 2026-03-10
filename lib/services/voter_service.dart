import '../models/voter.dart';

class VoterService {

  static List<Voter> voters = [
    Voter(id: "QR001", name: "Juan Dela Cruz", district: "District 1"),
    Voter(id: "QR002", name: "Maria Santos", district: "District 2"),
  ];

  static Voter? verifyVoter(String qr) {
    try {
      return voters.firstWhere((v) => v.id == qr);
    } catch (e) {
      return null;
    }
  }
}