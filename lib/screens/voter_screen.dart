import 'package:flutter/material.dart';
import '../models/voter.dart';
import 'ballot_screen.dart';

class VoterScreen extends StatelessWidget {
  final Voter voter;

  VoterScreen({required this.voter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Voter Information")),

      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', height: 70),

              const SizedBox(height: 8),

              Text(
                "BOHECO I Election System",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 4),

              const Text(
                "Bohol I Electric Cooperative, Inc.",
                style: TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 30),

              CircleAvatar(
                radius: 70,
                backgroundImage: voter.photoUrl != null
                    ? NetworkImage(voter.photoUrl!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
              ),

              const SizedBox(height: 20),

              Text(
                "${voter.id}",
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),

              const SizedBox(height: 6),

              Text(
                voter.name,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.green[900],
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  elevation: 0, 
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      0,
                    ),
                    side: BorderSide.none, 
                  ),
                  backgroundColor:
                      Colors.transparent, 
                  shadowColor: Colors.transparent,
                ),
                child: const Text("Press to continue →", 
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  decoration: TextDecoration.underline,    
                  color: Colors.grey,   
                    ),
                  ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BallotScreen(voter: voter),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
