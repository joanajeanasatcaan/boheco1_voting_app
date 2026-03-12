import 'package:flutter/material.dart';
import '../models/voter.dart';
import '../models/nominee.dart';
import '../services/api_service.dart';
import 'receipt_screen.dart';

class BallotScreen extends StatefulWidget {
  final Voter voter;

  const BallotScreen({super.key, required this.voter});

  @override
  State<BallotScreen> createState() => _BallotScreenState();
}

class _BallotScreenState extends State<BallotScreen> {
  // ── State
  List<Nominee> _nominees = [];
  bool _isLoading = true;
  String? _error;
  Nominee? _selectedNominee;

  @override
  void initState() {
    super.initState();
    _loadNominees();
  }

  Future<void> _loadNominees() async {
    setState(() { _isLoading = true; _error = null; });

    final result = await ApiService.getNominees();

    if (!mounted) return;

    if (result.isSuccess) {
      // Filter nominees to only those matching the voter's district
      final voterDistrict = widget.voter.district?.toString().trim();
      final filtered = voterDistrict == null || voterDistrict.isEmpty
          ? result.data!
          : result.data!.where((n) =>
      n.district?.toString().trim() == voterDistrict).toList();

      setState(() {
        _nominees  = filtered;
        _isLoading = false;
      });
    } else {
      setState(() {
        _error     = result.errorMessage;
        _isLoading = false;
      });
    }
  }

  bool get _canSubmit => _selectedNominee != null;

  void _submitVote() {
    if (!_canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a candidate or choose No Vote'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReceiptScreen(
          voter: widget.voter,
          selectedNominee: _selectedNominee,
        ),
      ),
    );
  }

  // ── Build ────────────────────────────────────────────────────
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
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Section label
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Board of Directors — District ${widget.voter.district ?? '—'}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ── Candidate grid
            Expanded(child: _buildBody()),

            const SizedBox(height: 10),

            // ── Bottom voter info + submit
            _BottomBar(
              voter: widget.voter,
              canSubmit: _canSubmit,
              selectedNominee: _selectedNominee,
              onSubmit: _submitVote,
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
          childAspectRatio: 0.9,
        ),
        itemCount: 6,
        itemBuilder: (_, __) => _SkeletonCard(),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 48, color: Colors.grey),
            const SizedBox(height: 12),
            Text(_error!, textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadNominees,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[700],
                  foregroundColor: Colors.white),
            ),
          ],
        ),
      );
    }

    if (_nominees.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.how_to_vote_outlined, size: 52, color: Colors.grey[300]),
            const SizedBox(height: 14),
            Text(
              'No candidates found for District ${widget.voter.district ?? '—'}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      );
    }

    // Build list: real nominees + No Vote sentinel
    final items = [..._nominees, null]; // null = "No Vote"

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.88,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final nominee = items[index]; // null means "No Vote"
        final isNoVote   = nominee == null;
        final isSelected = isNoVote
            ? _selectedNominee == null && _canSubmit == false
            ? false
            : (_selectedNominee == null && _canSubmit)
        // track "No Vote" selection separately via a flag instead:
            : _selectedNominee?.id == nominee.id;

        // We use id == -1 as a sentinel for "No Vote"
        final noVoteSelected = _selectedNominee?.id == -1;

        final cardSelected = isNoVote ? noVoteSelected : isSelected;

        return _CandidateCard(
          nominee:    nominee,
          isSelected: cardSelected,
          onTap: () {
            setState(() {
              if (isNoVote) {
                // Create a dummy Nominee for "No Vote"
                _selectedNominee = Nominee(
                  id:         -1,
                  firstName:  'No',
                  lastName:   'Vote',
                  votesCount: 0,
                );
              } else {
                _selectedNominee = nominee;
              }
            });
          },
        );
      },
    );
  }
}

// ── Candidate card ────────────────────────────────────────────
class _CandidateCard extends StatelessWidget {
  final Nominee? nominee; // null = No Vote
  final bool isSelected;
  final VoidCallback onTap;

  const _CandidateCard({
    required this.nominee,
    required this.isSelected,
    required this.onTap,
  });

  bool get isNoVote => nominee == null || nominee!.id == -1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isSelected ? Colors.green[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Avatar / photo
              _Avatar(nominee: nominee, isSelected: isSelected),

              const SizedBox(height: 10),

              // Name
              Text(
                isNoVote ? 'No Vote' : nominee!.fullName,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected ? Colors.green[800] : Colors.black87,
                ),
              ),

              // Nickname
              if (!isNoVote && (nominee!.nickname?.isNotEmpty ?? false)) ...[
                const SizedBox(height: 3),
                Text(
                  '"${nominee!.nickname}"',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],

              if (isNoVote) ...[
                const SizedBox(height: 3),
                Text(
                  'Abstain from voting',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],

              // Checkmark
              if (isSelected) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 14),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Avatar: shows network image or initials fallback ──────────
class _Avatar extends StatelessWidget {
  final Nominee? nominee;
  final bool isSelected;

  const _Avatar({required this.nominee, required this.isSelected});

  bool get isNoVote => nominee == null || nominee!.id == -1;

  @override
  Widget build(BuildContext context) {
    final bg = isNoVote
        ? Colors.grey[200]!
        : (isSelected ? Colors.green[100]! : Colors.grey[100]!);

    final borderColor = isNoVote
        ? Colors.grey[300]!
        : (isSelected ? Colors.green : Colors.grey[300]!);

    return Container(
      width: 68,
      height: 68,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: borderColor, width: 2),
      ),
      clipBehavior: Clip.antiAlias,
      child: isNoVote
          ? Icon(Icons.block, color: Colors.grey[500], size: 34)
          : (nominee!.imageUrl != null
          ? Image.network(
        nominee!.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _InitialsFallback(
          initials: nominee!.initials,
          isSelected: isSelected,
        ),
      )
          : _InitialsFallback(
        initials: nominee!.initials,
        isSelected: isSelected,
      )),
    );
  }
}

class _InitialsFallback extends StatelessWidget {
  final String initials;
  final bool isSelected;

  const _InitialsFallback({required this.initials, required this.isSelected});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        initials,
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: isSelected ? Colors.green[800] : Colors.grey[600],
        ),
      ),
    );
  }
}

// ── Skeleton loading card ─────────────────────────────────────
class _SkeletonCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 12, width: 80, color: Colors.grey[300]),
            const SizedBox(height: 6),
            Container(height: 10, width: 50, color: Colors.grey[200]),
          ],
        ),
      ),
    );
  }
}

// ── Bottom bar ────────────────────────────────────────────────
class _BottomBar extends StatelessWidget {
  final Voter voter;
  final bool canSubmit;
  final Nominee? selectedNominee;
  final VoidCallback onSubmit;

  const _BottomBar({
    required this.voter,
    required this.canSubmit,
    required this.selectedNominee,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        children: [
          // Voter info row
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green[700],
                radius: 20,
                child: Text(
                  voter.firstName.isNotEmpty
                      ? voter.firstName[0].toUpperCase()
                      : '?',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      voter.fullName,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                    Text(
                      'ID: ${voter.memberId}  •  District ${voter.district ?? '—'}',
                      style:
                      TextStyle(fontSize: 11, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: canSubmit ? Colors.green[50] : Colors.grey[200],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  canSubmit ? 'Ready' : 'Select',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color:
                    canSubmit ? Colors.green[700] : Colors.grey[600],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Submit button
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: onSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                canSubmit ? Colors.green[700] : Colors.grey[400],
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              child: const Text(
                'SUBMIT VOTE',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}