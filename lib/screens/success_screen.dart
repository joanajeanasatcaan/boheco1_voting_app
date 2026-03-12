import 'package:flutter/material.dart';
import 'scanner_screen.dart';

class SuccessScreen extends StatefulWidget {
  const SuccessScreen({super.key});

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;
  late final Animation<double> _scaleAnim;
  late final Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _scaleAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeIn,
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _nextVoter() {
    // Fully clear the stack and push a brand-new ScannerScreen
    // so the camera controller is freshly initialised
    // Pop everything back to the root ScannerScreen
    // so it stays alive and its camera controller is never disposed
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            children: [
              const Spacer(flex: 2),

              // ── Animated checkmark
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF86EFAC),
                      width: 3,
                    ),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    color: Color(0xFF166534),
                    size: 64,
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ── Title + subtitle
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    const Text(
                      'Vote Cast Successfully!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'The vote has been recorded.\nThank you for participating.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              // ── Divider with BOHECO branding
              FadeTransition(
                opacity: _fadeAnim,
                child: Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey[200])),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        'BOHECO I Election System',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[400],
                          letterSpacing: 0.3,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey[200])),
                  ],
                ),
              ),

              const Spacer(flex: 3),

              // ── Next voter button
              FadeTransition(
                opacity: _fadeAnim,
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _nextVoter,
                    icon: const Icon(Icons.qr_code_scanner, size: 20),
                    label: const Text(
                      'Scan Next Voter',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF166534),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}