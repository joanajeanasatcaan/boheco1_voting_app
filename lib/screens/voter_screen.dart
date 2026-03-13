import 'package:flutter/material.dart';
import '../models/voter.dart';
import 'ballot_screen.dart';

class VoterScreen extends StatelessWidget {
  final Voter voter;

  const VoterScreen({super.key, required this.voter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      bottomNavigationBar: voter.isVerified
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BallotScreen(voter: voter),
                      ),
                    ),
                    icon: const Icon(Icons.how_to_vote_rounded),
                    label: const Text(
                      'PROCEED TO BALLOT',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                ),
              ),
            )
          : null,

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              /// ───────────────── HEADER ─────────────────
              Column(
                children: [
                  Image.asset('assets/logo.png', height: 70),

                  const SizedBox(height: 10),

                  const Text(
                    'BOHECO I Election System',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 4),

                  const Text(
                    'Bohol I Electric Cooperative, Inc.',
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              /// ───────────────── PROFILE ─────────────────
              _ProfileCard(voter: voter),

              const SizedBox(height: 20),

              /// Personal Info
              _SectionCard(
                title: 'Personal Information',
                children: [
                  _InfoRow(label: 'Member ID', value: voter.memberId),
                  _InfoRow(label: 'Gender', value: voter.gender ?? '—'),
                  _InfoRow(label: 'Birthdate', value: voter.birthDate ?? '—'),
                  _InfoRow(
                    label: 'District',
                    value: voter.district != null
                        ? 'District ${voter.district}'
                        : '—',
                  ),
                ],
              ),

              const SizedBox(height: 16),

              /// Contact Info
              _SectionCard(
                title: 'Contact Information',
                children: [
                  _InfoRow(
                    icon: Icons.email_outlined,
                    label: 'Email',
                    value: (voter.email != null && voter.email!.isNotEmpty)
                        ? voter.email!
                        : 'No email on file',
                  ),
                  _InfoRow(
                    icon: Icons.phone_outlined,
                    label: 'Phone',
                    value:
                        (voter.contactNumber != null &&
                            voter.contactNumber!.isNotEmpty &&
                            voter.contactNumber != "0")
                        ? voter.contactNumber!
                        : 'No number on file',
                  ),
                ],
              ),

              if (voter.spouse != null) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Spouse',
                  children: [
                    _InfoRow(label: 'Name', value: voter.spouse!.fullName),
                    _InfoRow(label: 'ID', value: voter.spouse!.id),
                  ],
                ),
              ],

              if (voter.member != null) ...[
                const SizedBox(height: 16),
                _SectionCard(
                  title: 'Primary Member',
                  children: [
                    _InfoRow(label: 'Name', value: voter.member!.fullName),
                    _InfoRow(label: 'Member ID', value: voter.member!.memberId),
                  ],
                ),
              ],

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

/// ───────────────── PROFILE CARD ─────────────────
class _ProfileCard extends StatelessWidget {
  final Voter voter;
  const _ProfileCard({required this.voter});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// Voter Photo
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.account_circle, size: 70, color: Colors.grey),
                SizedBox(height: 6),
                Text(
                  "No Profile Picture",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        /// Member ID
        Text(
          voter.memberId,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black54,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 6),

        /// Name
        Text(
          voter.fullName,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF166534),
          ),
        ),

        const SizedBox(height: 10),

        _VerifiedBadge(isVerified: voter.isVerified),
      ],
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty ? last[0].toUpperCase() : '';
    return '$f$l';
  }
}

/// ───────────────── VERIFIED BADGE ─────────────────
class _VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  const _VerifiedBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: isVerified ? const Color(0xFFDCFCE7) : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending,
            size: 14,
            color: isVerified ? const Color(0xFF166534) : Colors.orange,
          ),
          const SizedBox(width: 6),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isVerified ? const Color(0xFF166534) : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

/// ───────────────── SECTION CARD ─────────────────
class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: 12),

          ...children,
        ],
      ),
    );
  }
}

/// ───────────────── INFO ROW ─────────────────
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;

  const _InfoRow({required this.label, required this.value, this.icon});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey),
            const SizedBox(width: 6),
          ],

          SizedBox(
            width: 110,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),

          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}
