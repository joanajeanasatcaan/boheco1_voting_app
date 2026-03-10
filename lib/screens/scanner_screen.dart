import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/voter_service.dart';
import '../models/voter.dart';
import 'voter_screen.dart';

class ScannerScreen extends StatelessWidget {
  const ScannerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary dummy voter for testing
    final dummyVoter = Voter(
      id: "1234",
      name: "Joana Jean Astacaan",
      district: "District 1",
      hasVoted: false,
    );

    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 20),
          Image.asset('assets/logo.png', height: 80),
          const SizedBox(height: 10),
          const Text(
            "BOHECO I ELECTION SYSTEM",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const Text(
            "Bohol I Electric Cooperative, Inc.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),

          const SizedBox(height: 20),
          const Text("Scan your voter QR code", style: TextStyle(fontSize: 16)),
          const SizedBox(height: 20),

          // temporary button will delete soon
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => VoterScreen(voter: dummyVoter),
                ),
              );
            },
            child: const Text("Next(Sample lang po ito)"),
          ),

          const SizedBox(height: 30),

          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 4),
                borderRadius: BorderRadius.circular(15),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MobileScanner(
                  onDetect: (capture) {
                    final barcode = capture.barcodes.first;
                    final String? code = barcode.rawValue;

                    if (code != null) {
                      final voter = VoterService.verifyVoter(code);

                      if (voter == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Invalid voter")),
                        );
                        return;
                      }

                      if (voter.hasVoted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Already voted")),
                        );
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VoterScreen(voter: voter),
                        ),
                      );
                    }
                  },
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          const Text(
            "Please present your voter QR code to the scanner",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}