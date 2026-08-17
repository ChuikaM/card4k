import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:card4k/pages/home_page.dart';
import 'package:card4k/pages/cards_page.dart';
import 'package:card4k/pages/pairing_page.dart';
import 'package:card4k/pages/selection_page.dart';

import 'package:card4k/widgets/burgers/groups_burger.dart';
import 'package:card4k/widgets/burgers/new_group_burger.dart';
import 'package:card4k/widgets/dialog/card_dialog.dart';
import 'package:card4k/widgets/widget.dart';

import 'package:card4k/providers/groups_view_model.dart';

import 'package:card4k/models/group.dart';

import 'package:card4k/data/di/service_locator.dart';

class HomePage extends StatelessWidget { 
  final GroupsViewModel vm = ServiceLocator().groupsViewModel;

  HomePage({super.key});

  Widget _buildCreateGroupButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final focusNode = FocusNode();
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierLabel: 'Dismiss Modal',
          barrierColor: const Color(0xA0212121),
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
                    } else {
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
                        onSubmit: (_, newest) => ServiceLocator().groupsViewModel.addGroup(newest),
                        onDelete: (_){},
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF30BE91),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Color(0xFF2E6252),
              offset: Offset(0, 6),
              blurRadius: 6.0,
              blurStyle: BlurStyle.inner,
            )
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add, color: Colors.white, size: 28),
            SizedBox(width: 12),
            Text(
              "Create Group",
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF303030);
    return ListenableBuilder(
      listenable: vm,
      builder: (context, snapshot) {
        final mainMenu = Column(
          children: [
            HomeTitle(hasGroups: true),
            HomeMain(),
            const Spacer()
          ]
        );

        return SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: mainMenu
          ),
        );
      }
    );
  }
}

class HomeTitle extends StatelessWidget {
  final GroupsViewModel vm = ServiceLocator().groupsViewModel;

  final bool hasGroups;

  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodeTitle = FocusNode();
  final FocusNode focusNodeDescription = FocusNode();

  HomeTitle({super.key, required this.hasGroups});

  @override
  Widget build(BuildContext context) {
    double availableHeight = MediaQuery.sizeOf(context).height;
    double availableWidth = MediaQuery.sizeOf(context).width;

    final borderDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0xFF7F7F7F),
          offset: Offset(0, 6),
          blurRadius: 6.0,
          blurStyle: BlurStyle.inner
        )
      ],
      borderRadius: BorderRadius.circular(15.0),
      color: Color(0xFFD9D9D9),
    );

    final groupButton = Ink(
      width: 128,
      height: 32,
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => showGeneralDialog(
          context: context,
          barrierDismissible: true,
          barrierLabel: 'Dismiss Modal G',
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
          pageBuilder: (context, animation, secondaryAnimation) => SafeArea(child: Align(alignment: Alignment.topCenter, child: BurgerGroups())),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 1, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              ListenableBuilder(
                listenable: vm, 
                builder: (context, _) => CircleAvatar(
                  radius: 12,
                  backgroundColor: vm.currentGroup?.color ?? Colors.grey,
                ),
              ),
              ListenableBuilder(
                listenable: vm, 
                builder: (context, _) => Text(
                  vm.currentGroup?.name ?? "Add Group", 
                  style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                )
              ),
            ],    
          ),
        )
      )
    );
    final cardsButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => buildAnimatedPage(context, CardPage(onGoBack: () => Navigator.pop(context))),
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: availableWidth / 2 - 20,
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/card.svg"),
                SizedBox(height: 10,),
                Text("Cards", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                ListenableBuilder(
                  listenable: vm, 
                  builder: (context, _) => Text("Total: ${vm.currentGroup?.getTotalCards() ?? 0}", style: TextStyle(color: Colors.white, fontSize: 12),),
                )
              ],
            ),
          )
        ),
      ),
    );
    final newCardButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => showDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Color(0xA0212121),
          builder: (context) {
            return SafeArea(
              child: Material(
                color: Colors.transparent, 
                child: Stack(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        if (!focusNodeTitle.hasFocus && !focusNodeDescription.hasFocus) {
                          Navigator.pop(context);
                        } else {
                          focusNodeTitle.unfocus();
                          focusNodeDescription.unfocus();
                        }
                      },
                      child: const SizedBox.expand(),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: CardDialog(
                        cardDialogMode: CardDialogMode.add, 
                        focusNodeTitle: focusNodeTitle, 
                        focusNodeDescription: focusNodeDescription
                      ),
                    ),
                  ],
                )
              )
            );
          },
        ),
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: availableWidth / 2 - 20,
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset("assets/icon/new card.svg"),
                SizedBox(height: 10,),
                Text("Card", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
              ],
            ),
          ) 
        ),
      ),
    );
    if(hasGroups) {
      return SizedBox(
        height: availableHeight / 4.2,
        child: Material(
          color: Color(0xFF212121),
          borderRadius: BorderRadiusGeometry.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
          child: Column(
            children: [
              Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: hasGroups ? MainAxisAlignment.spaceBetween : MainAxisAlignment.center,
                  children: [
                    if(hasGroups)
                      IconButton(
                        onPressed: () => showGeneralDialog(
                          context: context,
                          barrierDismissible: false,
                          barrierLabel: 'Dismiss Modal',
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
                                        oldGroup: vm.currentGroup,
                                        burgerNewGroupMode: BurgerNewGroupMode.edit, 
                                        focusNode: focusNode,
                                        onSubmit: vm.editGroup,
                                        onDelete: vm.deleteGroup,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                        icon: const Icon(
                          Icons.settings,
                          color: Colors.white,
                          shadows: [
                            Shadow(
                              color: Color(0xFFD9D9D9),
                              offset: Offset(0, 2),
                              blurRadius: 0,
                            ),
                          ],
                        ),
                        iconSize: 32, 
                      ),
                    Spacer(), 
                    groupButton
                  ],
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 5),            
                child: Padding(
                  padding: const EdgeInsets.all(15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    spacing: 20,
                    children: [
                      Expanded(child: AspectRatio(aspectRatio: 4/3, child: cardsButton)),
                      Expanded(child: AspectRatio(aspectRatio: 4/3, child: newCardButton)),              
                    ],
                  ),
                )           
              ),
              const Spacer() 
            ]
          ), 
        )
      );
    }
    else {
      return SizedBox();
    }
  }
}

class HomeMain extends StatelessWidget {
  final GroupsViewModel groupsViewModel = ServiceLocator().groupsViewModel;

  HomeMain({super.key});

  @override
  Widget build(BuildContext context) {
    final borderDecoration = BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Color(0xFF7F7F7F),
          offset: Offset(0, 6),
          blurRadius: 6.0,
          blurStyle: BlurStyle.inner
        )
      ],
      borderRadius: BorderRadius.circular(15.0),
      color: Color(0xFFD9D9D9),
    );

    final pairingButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => buildAnimatedPage(context, PairingPage(onGoBack: () => Navigator.pop(context))),
        borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Pairing", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                      Text("Pair words with their’s\ndescription", style: TextStyle(color: Colors.white, fontSize: 16)),
                    ],
                  ),
                ),
                SvgPicture.asset("assets/icon/pairing.svg")        
              ],
            )
          )    
      ),
    );
    final selectionButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => buildAnimatedPage(context, SelectionPage(onGoBack: () => Navigator.pop(context))),
        borderRadius: BorderRadius.circular(15),
          child: Padding(
            padding: EdgeInsetsGeometry.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Selection", style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),),
                    Text("Select appropriate translation\nfor the word", style: TextStyle(color: Colors.white, fontSize: 16),),
                  ],
                ),
                SvgPicture.asset("assets/icon/selection.svg")
              ],
            ),
          )    
      ),
    );

    return Padding(
      padding: EdgeInsetsGeometry.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        spacing: 16,
        children: [
          SizedBox(height: 128, child: pairingButton,),
          SizedBox(height: 128, child: selectionButton,)
        ],
      ),
    );
  }
}