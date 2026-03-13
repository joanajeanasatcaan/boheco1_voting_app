import 'package:flutter/material.dart';
import '../models/voter.dart';
import '../models/nominee.dart';
import '../services/api_service.dart';
import 'success_screen.dart';

class ReceiptScreen extends StatefulWidget {
  final Voter voter;
  final Nominee? selectedNominee;

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
      memberId: widget.voter.memberId,
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
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final voter = widget.voter;
    final selectedNominee = widget.selectedNominee;

    return Scaffold(
      backgroundColor: const Color(0xFF5F5F5F),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            /// RECEIPT PAPER
            Container(
              width: 340,
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  /// HEADER
                  const Center(
                    child: Text(
                      "Boheco 1 Election",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  /// VOTER DETAILS
                  Text(
                    "Voter's Name: ${voter.fullName}",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Voter's ID Number: ${voter.memberId}",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Voter's address: District ${voter.district ?? '-'}",
                    style: const TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "****************************************",
                    style: TextStyle(letterSpacing: 1),
                  ),

                  const SizedBox(height: 12),

                  /// VOTE RESULT
                  const Text(
                    "You voted:",
                    style: TextStyle(fontSize: 14),
                  ),

                  const SizedBox(height: 6),

                  Text(
                    isNoVote
                        ? "No Vote (Abstain)"
                        : selectedNominee!.fullName,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Text(
                    "****************************************",
                    style: TextStyle(letterSpacing: 1),
                  ),

                  const SizedBox(height: 12),

                  /// DATE & TIME
                  Text(
                    "Date: ${DateTime.now().toLocal().toString().split(' ')[0]}",
                    style: const TextStyle(fontSize: 13),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    "Time: ${TimeOfDay.now().format(context)}",
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// ACTION BUTTONS
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                /// CANCEL
                SizedBox(
                  width: 140,
                  height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.grey[200],
                      side: const BorderSide(color: Colors.black26),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 20),

                /// CONFIRM & PRINT
                SizedBox(
                  width: 160,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF15803D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: _isSubmitting ? null : _confirmVote,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            "Confirm & Print",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}