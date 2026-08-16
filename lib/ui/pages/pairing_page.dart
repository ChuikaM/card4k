import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';

import 'package:card4k/ui/view_models/groups_view_model.dart';
import 'package:card4k/ui/widgets/widget.dart';

import 'package:card4k/ui/pages/results_page.dart';

import 'package:card4k/data/models/group.dart';
import 'package:card4k/data/models/card.dart' as c;

class PairingPage extends StatefulWidget {
  final GroupProvider groupProvider;
  final VoidCallback onGoBack;

  PairingPage({
    super.key,
    required this.groupProvider,
    required this.onGoBack,
  });

  @override
  State<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends State<PairingPage> {
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF303030);

    return StreamBuilder<Group?>(
      stream: widget.groupProvider.currentGroupStream,
      initialData: widget.groupProvider.currentGroup,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final group = snapshot.data;

        if (group == null) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        final contentHash = group.cards.fold<int>(
          0,
          (previousValue, card) => previousValue ^ card.hashCode,
        );

        return SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: _PairingGame(
              key: ValueKey(
                'pairing_${group.name}_${group.cards.length}_$contentHash',
              ),
              group: group,
              onGoBack: widget.onGoBack,
            ),
          ),
        );
      },
    );
  }
}

class _PairingGame extends StatefulWidget {
  final Group group;
  final VoidCallback onGoBack;

  _PairingGame({
    super.key,
    required this.group,
    required this.onGoBack,
  });

  @override
  State<_PairingGame> createState() => _PairingGameState();
}

class _PairingGameState extends State<_PairingGame> {
  final Random _random = Random();

  List<_PairItem> _leftItems = [];
  List<_PairItem> _rightItems = [];

  List<c.Card> _allCards = [];
  List<c.Card> _remainingCards = [];
  List<c.Card> _currentRoundCards = [];

  final Set<int> _matchedIds = {};

  int? _selectedLeftId;
  int? _selectedRightId;

  int? _wrongLeftId;
  int? _wrongRightId;

  bool _locked = false;
  Timer? _wrongTimer;

  int _mistakes = 0;
  int _totalMatched = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void didUpdateWidget(covariant _PairingGame oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.group != widget.group) {
      _wrongTimer?.cancel();
      setState(() {
        _initializeGame();
      });
    }
  }

  @override
  void dispose() {
    _wrongTimer?.cancel();
    super.dispose();
  }

  List<c.Card> get _playableCards => widget.group.cards
      .where(
        (card) =>
            card.title.trim().isNotEmpty &&
            card.description.trim().isNotEmpty,
      )
      .toList();

  void _initializeGame() {
    _allCards = _playableCards;
    _allCards.shuffle(_random);
    _remainingCards = List.from(_allCards);
    
    _mistakes = 0;
    _totalMatched = 0;
    
    if (_remainingCards.isNotEmpty) {
      _loadNextRound();
    } else {
      setState(() {
        _leftItems = [];
        _rightItems = [];
      });
    }
  }

  void _loadNextRound() {
    final count = _remainingCards.length > 5 ? 5 : _remainingCards.length;
    _currentRoundCards = _remainingCards.sublist(0, count);
    _remainingCards = _remainingCards.sublist(count);
    
    _initializeRoundItems();
  }

    void _initializeRoundItems() {
    _wrongTimer?.cancel();
    final cards = _currentRoundCards;

    final left = <_PairItem>[];
    final right = <_PairItem>[];

    for (var i = 0; i < cards.length; i++) {
      left.add(_PairItem(pairId: i, label: cards[i].title));
      right.add(_PairItem(pairId: i, label: cards[i].description));
    }

    left.shuffle(_random);
    right.shuffle(_random);

    setState(() {
      _leftItems = left;
      _rightItems = right;
      _matchedIds.clear();
      _selectedLeftId = null;
      _selectedRightId = null;
      _wrongLeftId = null;
      _wrongRightId = null;
      _locked = false;
    });
  }

  void _onTapLeft(int pairId) {
    if (_locked || _matchedIds.contains(pairId)) return;

    setState(() {
      if (_selectedLeftId == pairId) {
        _selectedLeftId = null;
      } else {
        _selectedLeftId = pairId;
      }
    });

    _evaluateSelection();
  }

  void _onTapRight(int pairId) {
    if (_locked || _matchedIds.contains(pairId)) return;

    setState(() {
      if (_selectedRightId == pairId) {
        _selectedRightId = null;
      } else {
        _selectedRightId = pairId;
      }
    });

    _evaluateSelection();
  }

    void _evaluateSelection() {
    final left = _selectedLeftId;
    final right = _selectedRightId;

    if (left == null || right == null) return;

    if (left == right) {
      setState(() {
        _matchedIds.add(left);
        _totalMatched++;

        _selectedLeftId = null;
        _selectedRightId = null;

        _wrongLeftId = null;
        _wrongRightId = null;
      });

      if (_matchedIds.length == _currentRoundCards.length) {
        if (_remainingCards.isNotEmpty) {
          Future.delayed(const Duration(milliseconds: 600), () {
            if (mounted) _loadNextRound();
          });
        } else {
          Future.delayed(const Duration(seconds: 1), () {
            if (mounted) _navigateToResults();
          });
        }
      }
      return;
    }

    _mistakes++;
    
    setState(() {
      _locked = true;
      _wrongLeftId = left;
      _wrongRightId = right;
    });

    _wrongTimer?.cancel();
    _wrongTimer = Timer(const Duration(seconds: 1), () {
      if (!mounted) return;

      setState(() {
        _wrongLeftId = null;
        _wrongRightId = null;
        _selectedLeftId = null;
        _selectedRightId = null;
        _locked = false;
      });
    });
  }

  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          correctPairs: _totalMatched,
          mistakes: _mistakes,
          onFinish: widget.onGoBack,
        ),
      ),
    );
  }

  Color _itemColor({
    required int pairId,
    required bool isLeft,
  }) {
    final isWrong = isLeft ? _wrongLeftId == pairId : _wrongRightId == pairId;

    if (isWrong) return const Color(0xFFC92F2F);
    if (_matchedIds.contains(pairId)) return const Color(0xFF30BE91);

    final isSelected = isLeft ? _selectedLeftId == pairId : _selectedRightId == pairId;
    if (isSelected) return const Color(0xFF2EC4B6);

    return const Color(0xFFD9D9D9);
  }

  @override
  Widget build(BuildContext context) {
    final total = _allCards.length;
    final current = _totalMatched;

    return Column(
      children: [
        buildProgressBar(
          context,
          widget.onGoBack,
          current: current,
          total: total,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: total == 0
                ? _buildEmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Tap the matching pairs",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: _buildPairs(),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.style_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            "No cards available for pairing",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            "Add cards with title and description first.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54, fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildPairs() {
    return SingleChildScrollView(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: _buildList(_leftItems, isLeft: true)),
          const SizedBox(width: 16),
          Expanded(child: _buildList(_rightItems, isLeft: false)),
        ],
      ),
    );
  }

  Widget _buildList(List<_PairItem> items, {required bool isLeft}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          _buildPairButton(items[i], isLeft: isLeft),
          if (i < items.length - 1) const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildPairButton(_PairItem item, {required bool isLeft}) {
    final color = _itemColor(pairId: item.pairId, isLeft: isLeft);
    final isEnabled = !_locked && !_matchedIds.contains(item.pairId);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled
            ? () {
                if (isLeft) {
                  _onTapLeft(item.pairId);
                } else {
                  _onTapRight(item.pairId);
                }
              }
            : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(
                color: Color(0xFF7F7F7F),
                offset: Offset(0, 6),
                blurRadius: 6.0,
                blurStyle: BlurStyle.inner,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            item.label,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}

class _PairItem {
  final int pairId;
  final String label;

  const _PairItem({
    required this.pairId,
    required this.label,
  });
}