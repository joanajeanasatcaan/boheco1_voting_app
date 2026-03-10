import 'package:flutter/material.dart';
import 'scanner_screen.dart';

class SuccessScreen extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Center(

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,

          children: [

            Icon(Icons.check_circle,
              color: Colors.green,
              size: 80),

            SizedBox(height: 20),

            Text(
              "Vote Successfully Cast",
              style: TextStyle(fontSize: 22),
            ),

            SizedBox(height: 20),

            ElevatedButton(
              child: Text("Next Voter"),

              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ScannerScreen(),
                  ),
                  (route) => false,
                );
              },
            )
          ],
        ),
      ),
    );
  }
}