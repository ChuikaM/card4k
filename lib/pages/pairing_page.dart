import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:card4k/widgets/widget.dart';
import 'package:card4k/pages/results_page.dart';
import 'package:card4k/providers/pairing_provider.dart';
import 'package:card4k/providers/groups_provider.dart';

class PairingPage extends ConsumerStatefulWidget {
  final VoidCallback onGoBack;
  const PairingPage({
    super.key, 
    required this.onGoBack
  });

  @override
  ConsumerState<PairingPage> createState() => _PairingPageState();
}

class _PairingPageState extends ConsumerState<PairingPage> {
  late PairingProvider _vm;

  @override
  void initState() {
    super.initState();
    _vm = PairingProvider(ref.read(groupsProvider).value?.current);
    _vm.onFinished = () => Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => ResultPage(
          correctPairs: _vm.totalMatched,
          mistakes: _vm.mistakes,
          onFinish: widget.onGoBack,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF303030),
        body: ListenableBuilder(
          listenable: _vm,
          builder: (context, _) => Column(
            children: [
              buildProgressBar(context, widget.onGoBack, current: _vm.progress, total: _vm.total),
              Expanded(
                child: _vm.total == 0
                    ? const Center(child: Text("No cards available", style: TextStyle(color: Colors.white70)))
                    : _buildBoard(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoard() => Padding(
    padding: const EdgeInsets.all(10),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Tap the matching pairs", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Expanded(
          child: SingleChildScrollView(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _column(_vm.leftItems, isLeft: true)),
                const SizedBox(width: 16),
                Expanded(child: _column(_vm.rightItems, isLeft: false)),
              ],
            ),
          ),
        ),
      ],
    ),
  );

  Widget _column(List<PairItem> items, {required bool isLeft}) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < items.length; i++) ...[
        _button(items[i], isLeft: isLeft),
        if (i < items.length - 1) const SizedBox(height: 24),
      ],
    ],
  );

  Widget _button(PairItem item, {required bool isLeft}) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: _vm.isEnabled(item.pairId)
          ? () => isLeft ? _vm.tapLeft(item.pairId) : _vm.tapRight(item.pairId)
          : null,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          color: _colorFor(_vm.stateFor(item.pairId, isLeft: isLeft)),
          borderRadius: BorderRadius.circular(15),
        ),
        alignment: Alignment.center,
        child: Text(item.label, textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
      ),
    ),
  );

  Color _colorFor(PairItemState s) => switch (s) {
    PairItemState.failed => const Color(0xFFC92F2F),
    PairItemState.matched => const Color(0xFF30BE91),
    PairItemState.selected => const Color(0xFF2EC4B6),
    PairItemState.normal => const Color(0xFFD9D9D9),
  };
}