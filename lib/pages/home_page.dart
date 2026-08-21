import 'package:card4k/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:card4k/pages/cards_page.dart';
import 'package:card4k/pages/pairing_page.dart';
import 'package:card4k/pages/selection_page.dart';

import 'package:card4k/widgets/burgers/groups_burger.dart';
import 'package:card4k/widgets/burgers/new_or_edit_group_burger.dart';
import 'package:card4k/widgets/dialog/card_dialog.dart';
import 'package:card4k/widgets/widget.dart';

import 'package:card4k/providers/groups_provider.dart';
import 'package:card4k/models/group.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomePage extends ConsumerWidget { 
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provider = ref.watch(groupsProvider);
    final mainMenu = provider.when(
      data: (data) { 
        var group = data.current;
        if(group == null) return HomeDefault();

        return Column(
          children: [
            HomeTitle(group: group),
            HomeMain(),
            const Spacer()
          ]
        );
      },
      error: (error, stackTrace) => Center(child: Text("Error: ${error.toString()}"),),
      loading: () => Center(child: CircularProgressIndicator(),),
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.primaryBackground,
        body: mainMenu
      ),
    );
  }
}

class HomeTitle extends ConsumerWidget {
  final FocusNode focusModalNode = FocusNode();
  final FocusNode focusNodeTitle = FocusNode();
  final FocusNode focusNodeDescription = FocusNode();
  final Group group;

  HomeTitle({super.key, required this.group});

  BoxDecoration borderDecoration() {
    return BoxDecoration(
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
  }
  Widget groupButton(BuildContext context) {
    return Ink(
      width: 128,
      height: 32,
      decoration: borderDecoration(),
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
              CircleAvatar(
                radius: 12,
                backgroundColor: group.color,
              ),
              Text(
                group.name, 
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              )
            ],    
          )
        )
      )
    );
  }
  Widget cardsButton(BuildContext context) {
    return Ink(
      decoration: borderDecoration(),
      child: InkWell(
        onTap: () => buildAnimatedPage(context, CardPage(onGoBack: () => Navigator.pop(context))),
        borderRadius: BorderRadius.circular(15),
        child: SizedBox(
          width: MediaQuery.sizeOf(context).width / 2 - 20,
          child: Padding(
            padding: EdgeInsetsGeometry.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset("assets/icon/card.svg"),
                SizedBox(height: 10,),
                Text("Cards", style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),),
                Text("Total: ${group.getTotalCards()}", style: TextStyle(color: Colors.white, fontSize: 12),)
              ],
            ),
          )
        ),
      ),
    );
  }
  Widget newCardButton(BuildContext context) {
    return Ink(
      decoration: borderDecoration(),
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
          width: MediaQuery.sizeOf(context).width / 2 - 20,
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
  }
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height / 4.2,
      child: Material(
        color: Color(0xFF212121),
        borderRadius: BorderRadiusGeometry.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
       
            child:  Column(
              children: [
                Padding(
                  padding: EdgeInsetsGeometry.symmetric(horizontal: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
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
                                      if (!focusModalNode.hasFocus) {
                                        Navigator.pop(context);
                                      }
                                      else {
                                        focusModalNode.unfocus();
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
                                          burgerNewGroupMode: BurgerNewGroupMode.edit, 
                                          focusNode: focusModalNode,
                                          onSubmit: ref.read(groupsProvider.notifier).editGroup,
                                          onDelete: ref.read(groupsProvider.notifier).deleteGroup,
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
                      groupButton(context)
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
                        Expanded(child: AspectRatio(aspectRatio: 4/3, child: cardsButton(context))),
                        Expanded(child: AspectRatio(aspectRatio: 4/3, child: newCardButton(context))),              
                      ],
                    ),
                  )           
                ),
                const Spacer() 
              ]
            )
          
      )
    );
  }
}

class HomeMain extends ConsumerWidget {
  const HomeMain({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class HomeDefault extends ConsumerWidget {
  const HomeDefault({super.key});

  Widget createGroupButton(BuildContext context, WidgetRef ref) {
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
                        onSubmit: ref.read(groupsProvider.notifier).addGroup,
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
  @override Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: EdgeInsetsGeometry.symmetric(horizontal: 20),
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
            createGroupButton(context, ref),
          ],
        ),
      )
    );
  }
}