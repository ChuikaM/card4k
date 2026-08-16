import 'package:card4k/core/group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:card4k/ui/util/widget.dart';
import 'package:card4k/ui/dialog/card.dart';

import 'package:card4k/core/group_provider.dart' as gp;

class CardPage extends StatefulWidget {
  final gp.GroupProvider groupProvider;
  final VoidCallback onGoBack;

  const CardPage({super.key, required this.groupProvider, required this.onGoBack});

  @override
  State<CardPage> createState() => _CardPageState();
}

class _CardPageState extends State<CardPage> {
  final FocusNode focusNodeTitle = FocusNode();
  final FocusNode focusNodeDescription = FocusNode();

  String title = "";
  String description = "";

  bool isCardShowing = true;

  int index = 0;
  void _updateCardState(gp.Card card) {
    setState(() {
      title = card.title;
      description = card.description;
    });
  }

  void previous(Group group) async {
    if (group.cards.isEmpty) return;
    setState(() {
      if (index <= 0) {
        index = group.cards.length - 1;
      } else {
        index--;
      }
      _updateCardState(group.cards[index]);
    });
  }
  void next(Group group) async {
    if (group.cards.isEmpty) return;
    setState(() {
      if (index >= group.cards.length - 1) {
        index = 0;
      } else {
        index++;
      }
      _updateCardState(group.cards[index]);
    });
  }
  void showAndHide() {
    setState(() => isCardShowing = !isCardShowing);
  }

  void handleDelete(Group group) async {
    if (group.cards.isEmpty) return;

    await widget.groupProvider.deleteCardFrom(group.cards[index], group.name);
    setState((){
      _updateCardState(group.cards[index]);
    });
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeFirstCard();
    });
  }
  void _initializeFirstCard() {
    final group = widget.groupProvider.currentGroup;
    if (group != null && group.cards.isNotEmpty) {
      _updateCardState(group.cards[0]);
    }
  }

  Widget buildCards(BuildContext context, Group group) {
    final cardDecoration = BoxDecoration(
      color: const Color(0xFFD9D9D9),
      borderRadius: BorderRadius.circular(24),  
    );

    return Center(
      child: SizedBox(
        width: 320,
        height: 420,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 20,
              right: 20,
              child: Container(
                height: 360,
                decoration: cardDecoration.copyWith(
                  color: const Color(0xFF7C7C7C),
                ),
              ),
            ),
            Positioned(
              top: 12,
              left: 10,
              right: 10,
              child: Container(
                height: 360,
                decoration: cardDecoration.copyWith(
                  color: const Color(0xFFBBBBBB),
                ),
              ),
            ),
            Positioned(
              top: 24,
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                decoration: cardDecoration,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: Color(0xFFC92F2F), size: 32),
                          onPressed: () => handleDelete(group),
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit, color: Color(0xFF30BE91), size: 32),
                          onPressed: () => showDialog(
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
                                        child: CardDialog(oldCard: gp.Card(title: title, description: description), cardDialogMode: CardDialogMode.edit, groupProvider: widget.groupProvider, focusNodeTitle: focusNodeTitle, focusNodeDescription: focusNodeDescription),
                                      ),
                                    ],
                                  )
                                )
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            group.cards[index].title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12),
                          Text(
                            isCardShowing && group.cards.isNotEmpty ? group.cards[index].description : "",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  Widget buildCardContent(BuildContext context, Group group) {
    if (group.cards.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.credit_card, color: Colors.white54, size: 64),
              const SizedBox(height: 16),
              Text(
                "No cards in this group",
                style: TextStyle(color: Colors.white70, fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                "Add a new card to get started!",
                style: TextStyle(color: Colors.white54, fontSize: 14),
              ),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: Padding(
        padding: EdgeInsetsGeometry.symmetric(horizontal: 10, vertical: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            buildCards(context, group),
            const SizedBox(height: 24,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  onPressed: () => previous(group), 
                  icon: SvgPicture.asset("assets/icon/prev.svg"),
                  iconSize: 48,
                ),
                IconButton(
                  onPressed: () => showAndHide(), 
                  icon: isCardShowing ? SvgPicture.asset("assets/icon/show.svg") : SvgPicture.asset("assets/icon/hide.svg"),
                  iconSize: 64,
                ),
                IconButton(
                  onPressed: () => next(group), 
                  icon: SvgPicture.asset("assets/icon/next.svg"),
                  iconSize: 48,
                ),
              ],
            )
          ]
        ),
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF303030);
    return StreamBuilder<Group?>(
      stream: widget.groupProvider.currentGroupStream,
      initialData: widget.groupProvider.currentGroup ?? Group(cards: [], name: "", color: Colors.transparent),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final currentGroup = snapshot.data!;

        if (currentGroup.cards.isNotEmpty) {
          _updateLocalState(currentGroup);
        } else {
          title = "";
          description = "";
          index = 0;
        }

        final cardWidget = Column(
          children: [
            buildProgressBar(context, widget.onGoBack, current: index + 1, total: currentGroup.getTotalCards()),
            buildCardContent(context, currentGroup),
          ],
        );

        return SafeArea(
          child: Scaffold(
            backgroundColor: backgroundColor,
            body: cardWidget,
          ),
        );
      },
    );
  }
  void _updateLocalState(Group group) {
    if (group.cards.isEmpty) {
      title = "";
      description = "";
      index = 0;
      return;
    }

    if (index >= group.getTotalCards()) {
      index = 0;
    }
    title = group.cards[index].title;
    description = group.cards[index].description;
  }
}