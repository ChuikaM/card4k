import 'dart:math';
import 'package:card4k/providers/groups_provider.dart';
import 'package:flutter/material.dart';

import 'package:card4k/pages/results_page.dart';

import 'package:card4k/widgets/widget.dart';

import 'package:card4k/models/group.dart';
import 'package:card4k/models/card.dart' as c;
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectionPage extends ConsumerStatefulWidget {
  final VoidCallback onGoBack;

  const SelectionPage({
    super.key,
    required this.onGoBack
  });

  @override
  ConsumerState<SelectionPage> createState() => _SelectionPageState();
}

class _SelectionPageState extends ConsumerState<SelectionPage> {
  @override
  Widget build(BuildContext context) {
    var provider = ref.read(groupsProvider);
    const Color backgroundColor = Color(0xFF303030);

    return provider.when(
      data:(data) {
        final group = data.current;
        if (group == null) {
          return const Text('No groups. Create one!');
        }

        final contentHash = group.cards.fold<int>(
          0,
          (previousValue, card) => previousValue ^ card.hashCode,
        );
        return SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: _SelectionGame(
              key: ValueKey(
                'selection_${group.name}_${group.cards.length}_$contentHash',
              ),
              group: group,
              onGoBack: widget.onGoBack,
            ),
          ),
        );
      }, 
      error:(error, stackTrace) => Text("Error: ${error.toString()}"), 
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      )
    );
  }
}

class _SelectionGame extends StatefulWidget {
  final Group group;
  final VoidCallback onGoBack;

  const _SelectionGame({
    super.key,
    required this.group,
    required this.onGoBack,
  });

  @override
  State<_SelectionGame> createState() => _SelectionGameState();
}

class _SelectionGameState extends State<_SelectionGame> {
  final Random _random = Random();

  List<c.Card> _allCards = [];
  List<c.Card> _remainingCards = [];
  
  c.Card? _currentCard;
  List<String> _choices = [];
  
  String? _selectedChoice;
  bool _locked = false;
  int _mistakes = 0;
  int _correctAnswers = 0;

  @override
  void initState() {
    super.initState();
    _initializeGame();
  }

  @override
  void didUpdateWidget(covariant _SelectionGame oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.group != widget.group) {
      setState(() => _initializeGame());
    }
  }

  List<c.Card> get _playableCards => widget.group.cards
      .where((card) => card.title.trim().isNotEmpty && card.description.trim().isNotEmpty)
      .toList();

  void _initializeGame() {
    _allCards = _playableCards;
    _allCards.shuffle(_random);
    _remainingCards = List.from(_allCards);
    
    _mistakes = 0;
    _correctAnswers = 0;
    
    _loadNextCard();
  }

  void _loadNextCard() {
    if (_remainingCards.isEmpty) {
      setState(() {
        _currentCard = null;
        _choices = [];
      });
      
      
      if (_allCards.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _navigateToResults();
        });
      }
      
      return;
    }

    final current = _remainingCards.removeAt(0);
    _currentCard = current;

    final correctChoice = current.description;
    final choices = <String>{correctChoice};

    final otherCards = _allCards.where((c) => c != current).toList();
    otherCards.shuffle(_random);
    
    for (var c in otherCards) {
      if (choices.length >= 4) break;
      choices.add(c.description);
    }

    final choicesList = choices.toList();
    choicesList.shuffle(_random);

    setState(() {
      _choices = choicesList;
      _selectedChoice = null;
      _locked = false;
    });
  }
  void _navigateToResults() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => ResultPage(
          correctPairs: _correctAnswers,
          mistakes: _mistakes,
          onFinish: widget.onGoBack,
        ),
      ),
    );
  }

  void _onChoiceTap(String choice) {
    if (_locked || _currentCard == null) return;

    final isCorrect = choice == _currentCard!.description;
    
    setState(() {
      _selectedChoice = choice;
      _locked = true;
      
      if (isCorrect) {
        _correctAnswers++;
      } else {
        _mistakes++;
      }
    });

    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      _loadNextCard();
    });
  }

  Color _getChoiceColor(String choice) {
    if (!_locked) return const Color(0xFFD9D9D9);

    final isCorrectChoice = choice == _currentCard!.description;
    final isSelected = choice == _selectedChoice;

    if (isCorrectChoice) {
      return const Color(0xFF30BE91);
    } else if (isSelected) {
      return const Color(0xFFC92F2F);
    }

    return const Color(0xFFD9D9D9);
  }

  @override
  Widget build(BuildContext context) {
    final total = _allCards.length;
    final progress = total - _remainingCards.length;
    
    final isFinished = _currentCard == null && total > 0;

    return Column(
      children: [
        buildProgressBar(context, widget.onGoBack, current: progress, total: total),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
            child: total == 0
                ? _buildEmptyState()
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Select the correct translation",
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (!isFinished && _currentCard != null) _buildQuestionArea(),
                      const Spacer(),
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
          const Icon(Icons.quiz_outlined, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          const Text(
            "No cards available for selection",
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

  Widget _buildQuestionArea() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Center(
          child: Text(
            _currentCard!.title,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: _choices.map((choice) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildChoiceButton(choice),
                );
              }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ],
    );
  }

  Widget _buildChoiceButton(String choice) {
    final color = _getChoiceColor(choice);
    final isEnabled = !_locked;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isEnabled ? () => _onChoiceTap(choice) : null,
        borderRadius: BorderRadius.circular(15),
        child: Container(
          width: 320,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(15.0),
            boxShadow: const [
              BoxShadow(color: Color(0xFF7F7F7F), offset: Offset(0, 6), blurRadius: 6.0, blurStyle: BlurStyle.inner),
            ],
          ),
          alignment: Alignment.center,
          child: Text(
            choice,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }
}