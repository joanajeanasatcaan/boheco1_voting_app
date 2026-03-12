class Nominee {
  final int id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? town;
  final String? district;
  final String? nickname;
  final int votesCount;
  final String? imageUrl;

  Nominee({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.town,
    this.district,
    this.nickname,
    required this.votesCount,
    this.imageUrl,
  });

  String get fullName {
    return [firstName, middleName, lastName]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ');
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final l = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$f$l';
  }

  factory Nominee.fromJson(Map<String, dynamic> json) {
    return Nominee(
      id:          json['id'] as int,
      firstName:   json['first_name'] ?? '',
      middleName:  json['middle_name'],
      lastName:    json['last_name'] ?? '',
      town:        json['town'],
      district:    json['district']?.toString(),
      nickname:    json['nickname'],
      votesCount:  json['votes_count'] ?? 0,
      imageUrl:    json['image_url'],
    );
  }
}