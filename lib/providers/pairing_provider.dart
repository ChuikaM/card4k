import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:card4k/models/group.dart';

enum PairItemState { normal, selected, matched, failed }

class PairItem {
  final int pairId;
  final String label;
  const PairItem({required this.pairId, required this.label});
}

class PairingProvider extends ChangeNotifier {
  final Random _random = Random();

  List<PairItem> leftItems = [];
  List<PairItem> rightItems = [];

  List<dynamic> _allCards = [];
  List<dynamic> _remainingCards = [];
  List<dynamic> _currentRoundCards = [];

  final Set<int> _matchedIds = {};
  final Set<int> _failedIds = {};
  
  final Set<String> _failedItems = {};

  int? selectedLeftId;
  int? selectedRightId;
  bool locked = false;

  int mistakes = 0;
  int totalMatched = 0;

  Timer? _timer;

  VoidCallback? onFinished;

  int get total => _allCards.length;
  int get progress => totalMatched;

  PairingProvider(Group? group) {
    _allCards = (group?.cards ?? [])
        .where((c) => c.title.trim().isNotEmpty && c.description.trim().isNotEmpty)
        .toList()
      ..shuffle(_random);
    _remainingCards = List.from(_allCards);
    _loadNextRound();
  }

  void _loadNextRound() {
    final count = min(5, _remainingCards.length);
    _currentRoundCards = _remainingCards.sublist(0, count);
    _remainingCards = _remainingCards.sublist(count);

    leftItems = [for (var i = 0; i < _currentRoundCards.length; i++) PairItem(pairId: i, label: _currentRoundCards[i].title)];
    rightItems = [for (var i = 0; i < _currentRoundCards.length; i++) PairItem(pairId: i, label: _currentRoundCards[i].description)];
    leftItems.shuffle(_random);
    rightItems.shuffle(_random);

    _matchedIds.clear();
    _failedIds.clear();
    _failedItems.clear();
    selectedLeftId = null;
    selectedRightId = null;
    locked = false;
    notifyListeners();
  }

  void tapLeft(int id) {
    if (!isEnabled(id)) return;
    selectedLeftId = (selectedLeftId == id) ? null : id;
    notifyListeners();
    _evaluate();
  }

  void tapRight(int id) {
    if (!isEnabled(id)) return;
    selectedRightId = (selectedRightId == id) ? null : id;
    notifyListeners();
    _evaluate();
  }

  bool isEnabled(int id) => !locked && !_matchedIds.contains(id) && !_failedIds.contains(id);

  PairItemState stateFor(int id, {required bool isLeft}) {
    final itemKey = '${isLeft ? 'L' : 'R'}_$id';
    
    if (_failedItems.contains(itemKey)) return PairItemState.failed;
    if (_matchedIds.contains(id)) return PairItemState.matched;
    final selected = isLeft ? selectedLeftId == id : selectedRightId == id;
    return selected ? PairItemState.selected : PairItemState.normal;
  }

  void _evaluate() {
    final left = selectedLeftId;
    final right = selectedRightId;
    if (left == null || right == null) return;

    if (left == right) {
      _matchedIds.add(left);
      totalMatched++;
      selectedLeftId = null;
      selectedRightId = null;
      notifyListeners();

      if (_matchedIds.length * 2 + _failedIds.length == _currentRoundCards.length * 2) {
        _timer = Timer(
          _remainingCards.isNotEmpty ? const Duration(milliseconds: 600) : const Duration(seconds: 1),
          () => _remainingCards.isNotEmpty ? _loadNextRound() : onFinished?.call(),
        );
      }
      return;
    }

    mistakes++;
    locked = true;

    _failedIds.add(left);
    _failedIds.add(right);
    _failedItems.add('L_$left');
    _failedItems.add('R_$right');
    
    selectedLeftId = null;
    selectedRightId = null;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 1), () {
      locked = false;
      _failedIds.clear();
      _failedItems.clear();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}