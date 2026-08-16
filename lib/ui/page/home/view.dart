import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:card4k/ui/burger/groups/view.dart';
import 'package:card4k/ui/burger/new_group/new_group.dart';

import 'package:card4k/core/group_provider.dart';
import 'package:card4k/ui/dialog/card.dart';

import 'package:card4k/ui/page/home/presenter.dart';
import 'package:card4k/ui/page/cards/presenter.dart';
import 'package:card4k/ui/page/pairing/presenter.dart';
import 'package:card4k/ui/page/selection/presenter.dart';

import 'package:card4k/ui/util/widget.dart';

class HomePage extends StatelessWidget { 
  final GroupProvider groupProvider;

  const HomePage({
    super.key, 
    required this.groupProvider
  });

  Widget _buildCreateGroupButton(BuildContext context, HomePresenter presenter) {
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
                        onSubmit: presenter.addGroup,
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
    var presenter = HomePresenter(
      groupProvider: groupProvider
    );

    return StreamBuilder<List<Group>>(
      stream: groupProvider.allGroupsStream,
      initialData: groupProvider.groups,
      builder: (context, snapshot) {
        final hasGroups = snapshot.data?.isNotEmpty ?? false;

        final mainMenu = Column(
          children: [
            HomeTitle(homePresenter: presenter, hasGroups: hasGroups),
            if (hasGroups) ...[
              HomeMain(homePresenter: presenter),
              const Spacer()
            ] else ...[
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.style_outlined, 
                        size: 80,
                        color: Colors.white24,
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        "Create Your First Group",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        "Tap the button below to get started!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white38,
                          fontSize: 16,
                          height: 1.5, 
                        ),
                      ),
                      const SizedBox(height: 32),
                      _buildCreateGroupButton(context, presenter),
                    ],
                  ),
                )
              )
            ]
          ],
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
  final HomePresenter homePresenter;
  final bool hasGroups;

  final FocusNode focusNode = FocusNode();
  final FocusNode focusNodeTitle = FocusNode();
  final FocusNode focusNodeDescription = FocusNode();

  HomeTitle({super.key, required this.homePresenter, required this.hasGroups});

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
          pageBuilder: (context, animation, secondaryAnimation) => SafeArea(child: Align(alignment: Alignment.topCenter, child: BurgerGroups(groupProvider: homePresenter.groupProvider))),
        ),
        borderRadius: BorderRadius.circular(15),
        child: Padding(
          padding: EdgeInsetsGeometry.symmetric(vertical: 1, horizontal: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            spacing: 10,
            children: [
              StreamBuilder(
                stream: homePresenter.groupProvider.currentGroupStream,
                initialData: homePresenter.groupProvider.currentGroup,
                builder: (context, snapshot) =>
                CircleAvatar(
                  radius: 12,
                  backgroundColor: snapshot.data?.color ?? Colors.grey,
                ),
              ),
              
              StreamBuilder(
                stream: homePresenter.groupProvider.currentGroupStream,
                initialData: homePresenter.groupProvider.currentGroup,
                builder:(context, snapshot) {
                  return Text(
                    snapshot.data?.name ?? "Add Group", 
                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
                  );
                },
              )
            ],    
          ),
        )
      )
    );
    final cardsButton = Ink(
      decoration: borderDecoration,
      child: InkWell(
        onTap: () => buildAnimatedPage(context, CardPage(groupProvider: homePresenter.groupProvider, onGoBack: () => Navigator.pop(context))),
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
                StreamBuilder(
                  stream: homePresenter.groupProvider.currentGroupStream, 
                  initialData: homePresenter.groupProvider.currentGroup,
                  builder: (context, snapshot) => Text("Total: ${snapshot.data?.getTotalCards() ?? 0}", style: TextStyle(color: Colors.white, fontSize: 12),),
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
                        groupProvider: homePresenter.groupProvider, 
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
                                        oldGroup: homePresenter.groupProvider.currentGroup,
                                        burgerNewGroupMode: BurgerNewGroupMode.edit, 
                                        focusNode: focusNode,
                                        onSubmit: homePresenter.editGroup,
                                        onDelete: homePresenter.deleteGroup,
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
  final HomePresenter homePresenter;

  const HomeMain({super.key, required this.homePresenter});

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
        onTap: () => buildAnimatedPage(context, PairingPage(groupProvider: homePresenter.groupProvider, onGoBack: () => Navigator.pop(context))),
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
        onTap: () => buildAnimatedPage(context, SelectionPage(groupProvider: homePresenter.groupProvider, onGoBack: () => Navigator.pop(context))),
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