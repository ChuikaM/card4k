import 'package:flutter/material.dart';

import 'package:card4k/ui/view_models/groups_view_model.dart';
import 'package:card4k/data/models/card.dart' as c;

enum CardDialogMode { add, edit }

class CardDialog extends StatefulWidget {
  final CardDialogMode cardDialogMode;
  final c.Card? oldCard;
  final GroupProvider groupProvider;
  final FocusNode focusNodeTitle;
  final FocusNode focusNodeDescription;
  const CardDialog({
    super.key, 
    this.oldCard, 
    required this.cardDialogMode, 
    required this.groupProvider, 
    required this.focusNodeTitle, 
    required this.focusNodeDescription
  });

  @override
  State<CardDialog> createState() => _CardDialogState();
}

class _CardDialogState extends State<CardDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _descController;

  // NEW: error flags
  bool _titleError = false;
  bool _descError = false;

  @override
  void initState() { 
    super.initState();   
    _titleController = TextEditingController(text: widget.oldCard?.title ?? '');
    _descController = TextEditingController(text: widget.oldCard?.description ?? '');

    // NEW: clear the error as soon as the user types again
    _titleController.addListener(() {
      if (_titleError && _titleController.text.trim().isNotEmpty) {
        setState(() => _titleError = false);
      }
    });
    _descController.addListener(() {
      if (_descError && _descController.text.trim().isNotEmpty) {
        setState(() => _descError = false);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  // NEW: returns true only if both fields are non-empty
  bool _validate() {
    final titleEmpty = _titleController.text.trim().isEmpty;
    final descEmpty = _descController.text.trim().isEmpty;

    setState(() {
      _titleError = titleEmpty;
      _descError = descEmpty;
    });

    return !titleEmpty && !descEmpty;
  }

  Future<void> _handleApply(GroupProvider groupProvider) async {
    String? groupName = await groupProvider.getLastUsedGroupName();
    if (groupName == null || groupName.isEmpty) return;

    final newCard = c.Card(
      title: _titleController.text.trim(),
      description: _descController.text.trim(),
    );
    switch(widget.cardDialogMode) {
      case CardDialogMode.add:  groupProvider.addCardTo(newCard, groupName); break;
      case CardDialogMode.edit: groupProvider.editCardAt(widget.oldCard!, newCard, groupName); break;
    }
  }

  Widget buildEditCardDialog(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        width: 312,
        height: 440,
        child: Column(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        // NEW: red border on error
                        border: Border.all(
                          color: _titleError ? const Color(0xFFC92F2F) : const Color(0xFF7F7F7F),
                          width: _titleError ? 2 : 1,
                        ),
                      ),
                      child: TextField(
                        controller: _titleController,
                        focusNode: widget.focusNodeTitle,
                        style: const TextStyle(color: Colors.black, fontSize: 16),
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          border: InputBorder.none,
                          hintText: "Word/Term",
                          hintStyle: TextStyle(color: Color(0xFF333333)),
                        ),
                      ),
                    ),
                    // NEW: error message
                    if (_titleError)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "Word/Term cannot be empty",
                            style: TextStyle(color: Color(0xFFC92F2F), fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          // NEW: red border on error
                          border: Border.all(
                            color: _descError ? const Color(0xFFC92F2F) : const Color(0xFF7F7F7F),
                            width: _descError ? 2 : 1,
                          ),
                        ),
                        child: TextField(
                          controller: _descController,
                          focusNode: widget.focusNodeDescription,
                          maxLines: null,
                          expands: true,
                          textAlignVertical: TextAlignVertical.top,
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.all(14),
                            border: InputBorder.none,
                            hintText: "Description",
                            hintStyle: TextStyle(color: Color(0xFF333333)),
                          ),
                        ),
                      ),
                    ),
                    // NEW: error message
                    if (_descError)
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: EdgeInsets.only(top: 4),
                          child: Text(
                            "Description cannot be empty",
                            style: TextStyle(color: Color(0xFFC92F2F), fontSize: 12),
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 140,
                  height: 46,
                  child: build3DButton(
                    text: "cancel",
                    buttonColor: const Color(0xFFC92F2F),
                    shadowColor: const Color(0xFF9C2525),
                    onTap: () => Navigator.pop(context),
                  ),
                ),
                SizedBox(
                  width: 140,
                  height: 46,
                  child: build3DButton(
                    text: widget.cardDialogMode == CardDialogMode.add ? "create" : "apply",
                    buttonColor: const Color(0xFF30BE91),
                    shadowColor: const Color(0xFF2E6252),
                    onTap: () async {
                      // NEW: block submission if validation fails
                      if (!_validate()) return;
                      await _handleApply(widget.groupProvider);
                      if (mounted) Navigator.pop(context); 
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget build3DButton({required String text, required Color buttonColor, required Color shadowColor, required VoidCallback onTap}) {
    return Container(
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
    return buildEditCardDialog(context);
  }
}