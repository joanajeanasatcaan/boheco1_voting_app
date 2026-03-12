import 'package:flutter/material.dart';
import '../models/voter.dart';
import '../models/nominee.dart';
import '../services/api_service.dart';
import 'success_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final Voter voter;
  final Nominee? selectedNominee; // null = "No Vote / Abstain"

  const ReceiptScreen({
    super.key,
    required this.voter,
    required this.selectedNominee,
  });

  @override
  State<ReceiptScreen> createState() => _ReceiptScreenState();
}

class _ReceiptScreenState extends State<ReceiptScreen> {
  bool _isSubmitting = false;

  bool get isNoVote =>
      widget.selectedNominee == null || widget.selectedNominee!.id == -1;

  Future<void> _confirmVote() async {
    setState(() => _isSubmitting = true);

    final result = await ApiService.submitVote(
      nomineeId: widget.selectedNominee?.id ?? -1,
      memberId:  widget.voter.memberId,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (result.isSuccess) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => SuccessScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.errorMessage ?? 'Failed to submit vote.'),
          backgroundColor: Colors.red[600],
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final voter = widget.voter;
    final selectedNominee = widget.selectedNominee;
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text('Voting Receipt'),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header
            _ReceiptHeader(),

            const SizedBox(height: 20),

            // ── Voter details card
            _InfoCard(
              title: 'VOTER INFORMATION',
              titleColor: Colors.blue[700]!,
              children: [
                _InfoRow(label: 'Name',     value: voter.fullName),
                _InfoRow(label: 'Member ID',value: voter.memberId),
                _InfoRow(label: 'District', value: voter.district != null
                    ? 'District ${voter.district}' : '—'),
              ],
            ),

            const SizedBox(height: 16),

            // ── Vote details card
            _InfoCard(
              title: 'BOARD OF DIRECTORS VOTE',
              titleColor: Colors.blue[700]!,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Icon(
                        isNoVote
                            ? Icons.block
                            : Icons.how_to_vote_rounded,
                        color: isNoVote
                            ? Colors.grey
                            : Colors.green[700],
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          isNoVote
                              ? 'No Vote (Abstain)'
                              : selectedNominee!.fullName,
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isNoVote &&
                    (selectedNominee!.nickname?.isNotEmpty ?? false))
                  Padding(
                    padding: const EdgeInsets.only(left: 30, bottom: 4),
                    child: Text(
                      '"${selectedNominee!.nickname}"',
                      style: TextStyle(
                          color: Colors.grey[600],
                          fontStyle: FontStyle.italic,
                          fontSize: 13),
                    ),
                  ),
                if (!isNoVote && selectedNominee!.district != null)
                  Padding(
                    padding: const EdgeInsets.only(left: 30),
                    child: Text(
                      'District ${selectedNominee!.district}',
                      style:
                      TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ),
              ],
            ),

            const Spacer(),

            // ── Warning note
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      color: Colors.amber[700], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Once confirmed, your vote cannot be changed.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.amber[900]),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Colors.grey),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel',
                        style: TextStyle(color: Colors.grey)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _confirmVote,
                    child: _isSubmitting
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text('Confirm Vote',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

// ── Widgets ───────────────────────────────────────────────────

class _ReceiptHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: Color(0xFFDCFCE7),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.check_circle_rounded,
              color: Color(0xFF166534), size: 44),
        ),
        const SizedBox(height: 10),
        const Text(
          'Review Your Vote',
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        const SizedBox(height: 4),
        Text(
          'Please verify before confirming',
          style: TextStyle(fontSize: 13, color: Colors.grey[500]),
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final Color titleColor;
  final List<Widget> children;

  const _InfoCard({
    required this.title,
    required this.titleColor,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                    color: titleColor)),
            const Divider(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(label,
                style:
                TextStyle(fontSize: 12, color: Colors.grey[500])),
          ),
          Expanded(
            child: Text(value,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}