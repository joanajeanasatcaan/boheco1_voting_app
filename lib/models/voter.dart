class Voter {
  final String id;
  final String name;
  final String district;
  bool hasVoted;
  final String? photoUrl;

  Voter({
    required this.id,
    required this.name,
    required this.district,
    this.hasVoted = false,
    this.photoUrl,
  });
}

