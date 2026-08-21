import 'package:card4k/constants/colors.dart';
import 'package:card4k/providers/groups_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'package:card4k/models/group.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BurgerNewGroupMode { add, edit }

class BurgerNewGroup extends ConsumerStatefulWidget {
  final BurgerNewGroupMode burgerNewGroupMode;
  final FocusNode focusNode;
  final void Function(Group) onSubmit;
  final void Function(Group) onDelete;

  const BurgerNewGroup({
    super.key, 
    required this.burgerNewGroupMode, 
    required this.focusNode,
    required this.onSubmit,
    required this.onDelete
  });

  @override
  ConsumerState<BurgerNewGroup> createState() => _BurgerNewGroupState();
}

class _BurgerNewGroupState extends ConsumerState<BurgerNewGroup> {
  final TextEditingController _textEditingController = TextEditingController();
  Color _currentColor = AppColors.primaryBackground;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();

    if (widget.burgerNewGroupMode == BurgerNewGroupMode.edit) {
      final currentState = ref.read(groupsProvider);
      _tryInitializeFromState(currentState);
    }
  }
  void _tryInitializeFromState(AsyncValue state) {
    state.whenData((data) {
      if (data.current != null && mounted) {
        setState(() {
          _textEditingController.text = data.current!.name;
          _currentColor = data.current!.color;
        });
      }
    });
  }
  @override
  void didUpdateWidget(covariant BurgerNewGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.burgerNewGroupMode != widget.burgerNewGroupMode) {
      if (widget.burgerNewGroupMode == BurgerNewGroupMode.add) {
        setState(() {
          _textEditingController.clear();
          _currentColor = AppColors.primaryBackground;
          _hasError = false;
        });
      } else {
        final currentState = ref.read(groupsProvider);
        _tryInitializeFromState(currentState);
      }
    }
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  void _handleSubmit(BuildContext context) {
    final name = _textEditingController.text.trim();

    if (name.isEmpty) {
      setState(() => _hasError = true);
      widget.focusNode.requestFocus();
      return;
    }

    widget.onSubmit(
      Group(cards: [], name: name, color: _currentColor),
    );
    Navigator.pop(context);
  }

  Widget buildNewGroupBurger(BuildContext context) {
    var provider = ref.watch(groupsProvider);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      height: 284,
      width: MediaQuery.sizeOf(context).width,
      decoration: const BoxDecoration(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: provider.when(
        data: (data) {
          if (widget.burgerNewGroupMode == BurgerNewGroupMode.edit) {
            var group = data.current;
            if (group == null) return const SizedBox();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Title",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if(widget.burgerNewGroupMode == BurgerNewGroupMode.edit)
                    IconButton(
                      onPressed: () { 
                        var group = data.current;
                        if(group == null) return;
                        widget.onDelete.call(group);
                        Navigator.pop(context);
                      },
                      icon: Icon(Icons.delete_outline, color: Color(0xFFC92F2F), size: 32)
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: _hasError
                      ? Border.all(color: const Color(0xFFC92F2F), width: 2)
                      : null,
                ),
                child: TextField(
                  controller: _textEditingController,
                  focusNode: widget.focusNode,
                  onChanged: (value) {
                    if (_hasError && value.trim().isNotEmpty) {
                      setState(() => _hasError = false);
                    }
                  },
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    border: InputBorder.none,
                    hintText: "English",
                    hintStyle: TextStyle(color: Colors.black54),
                  ),
                ),
              ),
              if (_hasError)
                const Padding(
                  padding: EdgeInsets.only(top: 6),
                  child: Text(
                    "Group name cannot be empty!",
                    style: TextStyle(
                      color: Color(0xFFC92F2F),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Ink(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: InkWell(
                      onTap: () {},
                      customBorder: const CircleBorder(),
                      child: Padding(
                        padding: const EdgeInsets.all(3),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: _currentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),          
                  Ink(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: InkWell(
                      onTap: () => showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: SingleChildScrollView(
                            child: Column(
                              children: [
                                ColorPicker(
                                  pickerColor: _currentColor,
                                  onColorChanged: (Color color) {
                                    setState(() => _currentColor = color);
                                  },
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: buildModalButton(
                                        text: "cancel",
                                        buttonColor: const Color(0xFFC92A2A),
                                        shadowColor: const Color(0xFF861B1B),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ),
                                    const SizedBox(width: 20),
                                    Expanded(
                                      child: buildModalButton(
                                        text: "apply",
                                        buttonColor: const Color(0xFF30BE91),
                                        shadowColor: const Color(0xFF1B6A51),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      customBorder: const CircleBorder(),
                      child: const Icon(Icons.add, color: Colors.white, size: 28),
                    ),
                  ),
                ],
              ),
              const Spacer(),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: buildModalButton(
                      text: "cancel",
                      buttonColor: const Color(0xFFC92A2A),
                      shadowColor: const Color(0xFF861B1B),
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: buildModalButton(
                      text: widget.burgerNewGroupMode == BurgerNewGroupMode.add ? "create" : "apply",
                      buttonColor: const Color(0xFF30BE91),
                      shadowColor: const Color(0xFF1B6A51),
                      onTap: () {
                        _handleSubmit(context);
                      }
                    ),
                  ),
                ],
              ),
            ],
          );
        },
        error: (error, stackTrace) => Center(child: Text("Error: ${error.toString()}"),),
        loading: () => Center(child: CircularProgressIndicator(),),
      )
    );
  }

  Widget buildModalButton({required String text, required Color buttonColor, required Color shadowColor, required VoidCallback onTap}) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: buttonColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: const Offset(0, 4),
            blurRadius: 0,
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: buildNewGroupBurger(context)
    );
  }
}