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
      'image': 'assets/placeholder.png', 
    },
    {
      'name': 'No Vote',
      'nickname': '',
      'image': 'assets/placeholder.png',
    },
    {
      'name': 'Ismael Yll Tan',
      'nickname': 'Tantan',
      'image': 'assets/placeholder.png',
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
          selectedBoardMembers: selectedCandidate != null ? [selectedCandidate!] : [],
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
            Image.asset(
              'assets/logo.png', 
              width: 40,
              height: 40,
            ),
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
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, 
                  crossAxisSpacing: 15, 
                  mainAxisSpacing: 15, 
                  childAspectRatio: 0.9,
                ),
                itemCount: boardCandidates.length,
                itemBuilder: (context, index) {
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
                        color: isSelected 
                            ? Colors.green[50] 
                            : Colors.white,
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(10),
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
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Candidate image placeholder
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: isNoVote 
                                    ? Colors.grey[200] 
                                    : (isSelected ? Colors.green[100] : Colors.grey[100]),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: isNoVote 
                                      ? Colors.grey[300]! 
                                      : (isSelected ? Colors.green : Colors.grey[300]!),
                                  width: 2,
                                ),
                              ),
                              child: Center(
                                child: isNoVote
                                    ? Icon(
                                        Icons.block,
                                        color: Colors.grey[600],
                                        size: 35,
                                      )
                                    : Text(
                                        candidate['name']!.substring(0, 1),
                                        style: TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold,
                                          color: isSelected 
                                              ? Colors.green[800] 
                                              : Colors.grey[700],
                                        ),
                                      ),
                              ),
                            ),
                            
                            const SizedBox(height: 12),
                            
                            // Candidate name
                            Text(
                              candidate['name']!,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: isSelected 
                                    ? FontWeight.bold 
                                    : FontWeight.w500,
                                color: isSelected 
                                    ? Colors.green[800] 
                                    : Colors.black87,
                              ),
                            ),
                            
                            // Nickname if available
                            if (candidate['nickname']!.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                '"${candidate['nickname']}"',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                            
                            // No Vote description
                            if (isNoVote) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Abstain from voting',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                            
                            // Selection checkmark (optional)
                            if (isSelected)
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: const BoxDecoration(
                                    color: Colors.green,
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
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
                            selectedCandidate != null 
                                ? 'Ready' 
                                : 'Select',
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
                          backgroundColor: canSubmit ? Colors.green[700] : Colors.grey[400],
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