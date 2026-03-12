class Voter {
  final String memberId;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String? suffix;
  final String? district;
  final String? gender;
  final String? birthDate;
  final String? contactNumber;
  final String? email;
  final bool isVerified;
  final bool hasVoted;
  final SpouseInfo? spouse;
  final MemberInfo? member; // for spouse records

  Voter({
    required this.memberId,
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.suffix,
    this.district,
    this.gender,
    this.birthDate,
    this.contactNumber,
    this.email,
    required this.isVerified,
    required this.hasVoted,
    this.spouse,
    this.member,
  });

  String get fullName {
    return [firstName, middleName, lastName, suffix]
        .where((p) => p != null && p.isNotEmpty)
        .join(' ');
  }

  factory Voter.fromJson(Map<String, dynamic> json) {
    // Handles both Member and MemberSpouse responses
    final rawId = json['member_id'] ?? json['id'];

    return Voter(
      memberId: rawId?.toString() ?? '',
      firstName: json['first_name'] ?? '',
      middleName: json['middle_name'],
      lastName: json['last_name'] ?? '',
      suffix: json['suffix'],
      district: json['district']?.toString(),
      gender: json['gender'],
      birthDate: json['birth_date'],
      contactNumber: json['contact_number'],
      email: json['email'],
      isVerified: json['is_verified'] == true,
      hasVoted: json['has_voted'] == true,
      spouse: json['spouse'] != null ? SpouseInfo.fromJson(json['spouse']) : null,
      member: json['member'] != null ? MemberInfo.fromJson(json['member']) : null,
    );
  }
}

class SpouseInfo {
  final String id;
  final String fullName;

  SpouseInfo({required this.id, required this.fullName});

  factory SpouseInfo.fromJson(Map<String, dynamic> json) {
    return SpouseInfo(
      id: json['id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

class MemberInfo {
  final String memberId;
  final String fullName;

  MemberInfo({required this.memberId, required this.fullName});

  factory MemberInfo.fromJson(Map<String, dynamic> json) {
    return MemberInfo(
      memberId: json['member_id']?.toString() ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}