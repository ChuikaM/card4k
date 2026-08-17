import 'package:card4k/data/di/service_locator.dart';
import 'package:card4k/providers/groups_view_model.dart';
import 'package:flutter/material.dart';

import 'package:card4k/widgets/burgers/new_group_burger.dart';

import 'package:card4k/models/group.dart';

class BurgerGroups extends StatelessWidget {
  const BurgerGroups({super.key});

  Widget buildGroupsBurger(BuildContext context) {
    return SizedBox(
      height: 120,
      width: MediaQuery.sizeOf(context).width,
      child: Material(
        color: Color(0xFF212121),
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              GroupsButtons(),
              const SizedBox(width: 12),
              AddGroupButton()
            ],
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: buildGroupsBurger(context)
    );
  }
}

class GroupsButtons extends StatelessWidget {
  final GroupsViewModel vm = ServiceLocator().groupsViewModel;
  final FocusNode focusNode = FocusNode();

  GroupsButtons({super.key});

  Widget buildGroupItem({required String name, required Color color, required bool isActive}) {
    return GestureDetector(
      onTap: () async {
        if (!isActive) {
          vm.selectGroup(name);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 56,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive ? const Color(0xFF30BE91) : Colors.white,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: isActive ? Color(0xFF2E6252) : Color(0xFF7F7F7F),
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: ListenableBuilder(
          listenable: vm,
          builder:(context, child) {
            final groups = vm.groups;
            final activeGroupName = vm.currentGroup!.name;

            return Row(
              children: [
                for (var i = 0; i < groups.length; i++) ...[
                  buildGroupItem(
                    name: groups[i].name,
                    color: groups[i].color,
                    isActive: groups[i].name == activeGroupName,
                  ),
                  if (i < groups.length - 1) const SizedBox(width: 12),
                ]
              ],
            );
          }
        )
      ),
    );
  }
}

class AddGroupButton extends StatelessWidget {
  final GroupsViewModel vm = ServiceLocator().groupsViewModel;
  final FocusNode focusNode = FocusNode();

  AddGroupButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Dismiss Group Modal',
          barrierColor: Color(0xA0212121),
          transitionDuration: const Duration(milliseconds: 250),
          transitionBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, -1),
                end: Offset.zero,
              ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
              child: child,
            );
          },
          pageBuilder: (context, animation, secondaryAnimation) {
            return SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: GestureDetector(
                  onTap: () {
                    if (!focusNode.hasFocus) {
                      Navigator.pop(context);
                    }
                    else {
                      focusNode.unfocus();
                    }
                  },
                  child: Container(
                    color: Colors.transparent,
                    width: double.infinity,
                    height: double.infinity,
                    alignment: Alignment.topCenter,
                    child: GestureDetector(
                      onTap: () {}, 
                      behavior: HitTestBehavior.opaque,
                      child: BurgerNewGroup(
                        burgerNewGroupMode: BurgerNewGroupMode.add, 
                        focusNode: focusNode, 
                        onSubmit: (_, newest) => vm.addGroup(newest),
                        onDelete: (_) {},
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFF212121),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white, 
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0xFF7F7F7F),
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: const Icon(
              Icons.add, 
              color: Colors.white, 
              size: 28, 
              shadows: [
                Shadow(
                  color: Color(0xFF7F7F7F),
                  offset: Offset(0, 2),
                  blurRadius: 0,
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            "Group",
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}