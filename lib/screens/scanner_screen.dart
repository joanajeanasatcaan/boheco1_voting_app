import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../services/api_service.dart';
import 'voter_screen.dart';
import '../models/voter.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen>
    with WidgetsBindingObserver {

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.front,
    autoStart: false,
  );

  bool _isProcessing = false;
  bool _hasError = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startCamera());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!mounted) return;
    if (state == AppLifecycleState.resumed) {
      _startCamera();
    } else if (state == AppLifecycleState.paused) {
      _controller.stop();
    }
  }

  Future<void> _startCamera() async {
    if (!mounted) return;
    setState(() { _hasError = false; _isProcessing = false; });
    try {
      await _controller.start();
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;
    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null || rawValue.isEmpty) return;

    setState(() => _isProcessing = true);
    await _controller.stop();

    final memberId = _extractMemberId(rawValue);
    if (!mounted) return;

    _showLoadingDialog();
    final result = await ApiService.getVoterById(memberId);
    if (!mounted) return;
    Navigator.of(context).pop();

    if (result.isSuccess && result.data != null) {
      final voter = result.data!;

      // ── Block already-voted households immediately at scan
      if (voter.hasVoted) {
        _showAlreadyVotedDialog(voter.fullName);
        if (mounted) await _startCamera();
        return;
      }

      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => VoterScreen(voter: voter)),
      );
    } else {
      _showErrorSnackbar(result.errorMessage ?? 'Could not fetch voter data.');
    }

    // Always restart after returning from any navigation
    if (mounted) await _startCamera();
  }

  String _extractMemberId(String raw) {
    try {
      final uri = Uri.tryParse(raw);
      if (uri != null && uri.pathSegments.isNotEmpty) {
        final last = uri.pathSegments.last;
        if (last.isNotEmpty) return Uri.decodeComponent(last);
      }
    } catch (_) {}
    return raw.trim();
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: Card(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12))),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(color: Color(0xFF166634)),
                SizedBox(height: 16),
                Text('Fetching voter info…',
                    style: TextStyle(fontSize: 14, color: Colors.black87)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlreadyVotedDialog(String voterName) {
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: const EdgeInsets.fromLTRB(24, 28, 24, 16),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.how_to_vote_rounded,
                  color: Colors.red.shade400, size: 40),
            ),
            const SizedBox(height: 16),
            const Text(
              'Already Voted',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '$voterName\'s household has already cast their vote.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF166534),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: const Text('Scan Next Voter'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: Colors.red.shade600,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ));
  }

  // Temporary method to navigate to voter screen(delete later)
  void _navigateToTempVoter() {
  final tempVoter = Voter(
    memberId: 'M-2024-001',
    firstName: 'Juan',
    lastName: 'Dela Cruz',
    middleName: 'Santos',
    suffix: null,
    district: '1',
    gender: 'Male',
    birthDate: '1980-01-01',
    contactNumber: '09123456789',
    email: 'juan.delacruz@email.com',
    isVerified: true,
    hasVoted: false,
    spouse: null,
    member: null,
  );
  
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => VoterScreen(voter: tempVoter),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Add floating action button for temporary navigation (delete later)
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToTempVoter,
        backgroundColor: const Color(0xFF166534),
        child: const Icon(Icons.arrow_forward, color: Colors.white),
        tooltip: 'Temporary: Go to Voter Screen',
      ),


      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            Image.asset('assets/logo.png', height: 80),
            const SizedBox(height: 10),
            const Text(
              'BOHECO I ELECTION SYSTEM',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5),
            ),
            const Text(
              'Bohol I Electric Cooperative, Inc.',
              style: TextStyle(fontSize: 13, color: Colors.grey),
            ),
            const SizedBox(height: 28),
            const Text('Scan your voter QR code',
                style: TextStyle(fontSize: 16, color: Colors.black87)),
            const SizedBox(height: 20),

            // ── Scanner box
            Center(
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF166534), width: 4),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(11),
                  child: RotatedBox(
                    quarterTurns: -1,
                    child: _hasError
                        ? _ErrorView(
                      message: _errorMessage,
                      onRetry: _startCamera,
                    )
                        : MobileScanner(
                      controller: _controller,
                      onDetect: _onDetect,
                      errorBuilder: (context, error, child) {
                        return _ErrorView(
                          message: error.errorCode.name,
                          onRetry: _startCamera,
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.qr_code_scanner,
                    size: 18, color: Colors.grey.shade400),
                const SizedBox(width: 6),
                Text('Align QR code within the box',
                    style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade500)),
              ],
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Please present your voter QR code to the scanner',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt_outlined,
                color: Colors.white54, size: 40),
            const SizedBox(height: 10),
            Text(
              'Camera unavailable\n$message',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white60, fontSize: 11),
            ),
            const SizedBox(height: 14),
            TextButton(
              onPressed: onRetry,
              child: const Text('Tap to retry',
                  style: TextStyle(color: Colors.greenAccent)),
            ),
          ],
        ),
      ),
    );
  }
}