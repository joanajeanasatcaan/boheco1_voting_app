import 'package:flutter/material.dart';
import '../models/voter.dart';
import 'receipt_screen.dart';

class BallotScreen extends StatefulWidget {
  final Voter voter;

  const BallotScreen({super.key, required this.voter});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  String? selectedCandidate;

  final List<Map<String, String>> boardCandidates = [
    {
      'name': 'Juan Pedro David',
      'nickname': 'Toto',
      'image': 'assets/no_profile.png',
    },
    {'name': 'No Vote', 'nickname': '', 'image': 'assets/placeholder.png'},
    {
      'name': 'Ismael Yll Tan',
      'nickname': 'Tantan',
      'image': 'assets/no_profile.png',
    },
  ];

  bool get canSubmit => selectedCandidate != null;

  void _submitVote() {
    if (!canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a candidate'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReceiptScreen(
          voter: widget.voter,
          selectedBoardMembers: selectedCandidate != null
              ? [selectedCandidate!]
              : [],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/logo.png', width: 40, height: 40),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'BOHECO 1 Election System',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  Text(
                    'Bohol 1 Electric Cooperative, Inc.',
                    style: TextStyle(fontSize: 12, color: Colors.grey[300]),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 10),

            Expanded(
              child: Center(
                // This centers vertically
                child: Padding(
                  // This adds horizontal padding
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: GridView.builder(
                    shrinkWrap: true, // Required when using Center
                    physics:
                        const NeverScrollableScrollPhysics(), // Optional: disable scrolling if grid fits
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                          childAspectRatio: 0.75,
                        ),
                    itemCount: boardCandidates.length,
                    itemBuilder: (context, index) {
                      // ... your existing itemBuilder code
                      final candidate = boardCandidates[index];
                      final isSelected = selectedCandidate == candidate['name'];
                      final isNoVote = candidate['name'] == 'No Vote';

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedCandidate = candidate['name'];
                          });
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.green[50] : Colors.white,
                            border: Border.all(
                              color: isSelected
                                  ? Colors.green
                                  : Colors.grey[300]!,
                              width: isSelected ? 2 : 1,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: isNoVote
                                        ? Colors.grey[200]
                                        : (isSelected
                                              ? Colors.green[100]
                                              : Colors.grey[100]),
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isNoVote
                                          ? Colors.grey[300]!
                                          : (isSelected
                                                ? Colors.green
                                                : Colors.grey[300]!),
                                      width: 1.5,
                                    ),
                                  ),
                                  child: Center(
                                    child: isNoVote
                                        ? Icon(
                                            Icons.block,
                                            color: Colors.grey[600],
                                            size: 22,
                                          )
                                        : Text(
                                            candidate['name']!.substring(0, 1),
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                              color: isSelected
                                                  ? Colors.green[800]
                                                  : Colors.grey[700],
                                            ),
                                          ),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  candidate['name']!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                    color: isSelected
                                        ? Colors.green[800]
                                        : Colors.black87,
                                  ),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                if (candidate['nickname']!.isNotEmpty)
                                  Text(
                                    '"${candidate['nickname']}"',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                      fontStyle: FontStyle.italic,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                if (isNoVote)
                                  Text(
                                    'Abstain',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                if (isSelected)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 4),
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: const BoxDecoration(
                                        color: Colors.green,
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.check,
                                        color: Colors.white,
                                        size: 10,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            // Voter info and submit button
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(15),
                child: Column(
                  children: [
                    // Voter info
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.green[700],
                          radius: 20,
                          child: Text(
                            widget.voter.name.substring(0, 1).toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.voter.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                'ID: ${widget.voter.id} • District: ${widget.voter.district}',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: selectedCandidate != null
                                ? Colors.green[50]
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            selectedCandidate != null ? 'Ready' : 'Select',
                            style: TextStyle(
                              color: selectedCandidate != null
                                  ? Colors.green[700]
                                  : Colors.grey[600],
                              fontWeight: FontWeight.w500,
                              fontSize: 11,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 15),

                    // Submit button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _submitVote,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: canSubmit
                              ? Colors.green[700]
                              : Colors.grey[400],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'SUBMIT VOTE',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: canSubmit ? Colors.white : Colors.grey[200],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
