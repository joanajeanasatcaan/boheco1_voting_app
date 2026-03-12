import 'package:flutter/material.dart';
import '../models/voter.dart';
import 'ballot_screen.dart';

class VoterScreen extends StatelessWidget {
  final Voter voter;

  const VoterScreen({super.key, required this.voter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Voter Details',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
      ),
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
              icon: const Icon(Icons.how_to_vote_rounded, size: 20),
              label: const Text(
                'PROCEED TO BALLOT',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF166534),
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
        ),
      )
          : null,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Profile card
            _ProfileCard(voter: voter),

            const SizedBox(height: 16),

            // ── Personal info
            _SectionCard(
              title: 'Personal Information',
              children: [
                _InfoRow(label: 'Member ID', value: voter.memberId),
                _InfoRow(label: 'Gender',    value: voter.gender ?? '—'),
                _InfoRow(label: 'Birthdate', value: voter.birthDate ?? '—'),
                _InfoRow(label: 'District',  value: voter.district != null ? 'District ${voter.district}' : '—'),
              ],
            ),

            const SizedBox(height: 16),

            // ── Contact info
            _SectionCard(
              title: 'Contact Information',
              children: [
                _InfoRow(
                  icon: Icons.email_outlined,
                  label: 'Email',
                  value: (voter.email != null && voter.email!.isNotEmpty) ? voter.email! : 'No email on file',
                ),
                _InfoRow(
                  icon: Icons.phone_outlined,
                  label: 'Phone',
                  value: (voter.contactNumber != null && voter.contactNumber!.isNotEmpty && voter.contactNumber != "0") ? voter.contactNumber! : 'No number on file',
                ),
              ],
            ),

            // ── Spouse / Member link (if present)
            if (voter.spouse != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Spouse',
                children: [
                  _InfoRow(label: 'Name', value: voter.spouse!.fullName),
                  _InfoRow(label: 'ID',   value: voter.spouse!.id),
                ],
              ),
            ],

            if (voter.member != null) ...[
              const SizedBox(height: 16),
              _SectionCard(
                title: 'Primary Member',
                children: [
                  _InfoRow(label: 'Name',      value: voter.member!.fullName),
                  _InfoRow(label: 'Member ID', value: voter.member!.memberId),
                ],
              ),
            ],

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Profile card (avatar + name + status badge)
class _ProfileCard extends StatelessWidget {
  final Voter voter;
  const _ProfileCard({required this.voter});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar initials
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFFDCFCE7),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF86EFAC), width: 2),
            ),
            child: Center(
              child: Text(
                _initials(voter.firstName, voter.lastName),
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF166534),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  voter.fullName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                if (voter.district != null)
                  Text(
                    'District ${voter.district}',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                const SizedBox(height: 8),
                _VerifiedBadge(isVerified: voter.isVerified),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String first, String last) {
    final f = first.isNotEmpty ? first[0].toUpperCase() : '';
    final l = last.isNotEmpty  ? last[0].toUpperCase()  : '';
    return '$f$l';
  }
}

class _VerifiedBadge extends StatelessWidget {
  final bool isVerified;
  const _VerifiedBadge({required this.isVerified});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: isVerified
            ? const Color(0xFFDCFCE7)
            : const Color(0xFFFEF9C3),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isVerified ? Icons.verified : Icons.pending_outlined,
            size: 13,
            color: isVerified ? const Color(0xFF166534) : const Color(0xFF854D0E),
          ),
          const SizedBox(width: 4),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isVerified ? const Color(0xFF166534) : const Color(0xFF854D0E),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Reusable section card
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
              fontWeight: FontWeight.w600,
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

// ── Single info row
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 16, color: Colors.grey.shade400),
            const SizedBox(width: 8),
          ],
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}