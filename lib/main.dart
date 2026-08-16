import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import 'package:card4k/ui/pages/home_page.dart';
import 'package:card4k/ui/view_models/groups_view_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final groupProvider = GroupProvider();
  
  final initFuture = groupProvider.init(); 

  runApp(MainApp(
    groupProvider: groupProvider,
    initFuture: initFuture,
  ));
}

class MainApp extends StatefulWidget {
  final GroupProvider groupProvider;
  final Future<void> initFuture;

  const MainApp({super.key, required this.groupProvider, required this.initFuture});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    const Color backgroundColor = Color(0xFF303030);

    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: backgroundColor,
        canvasColor: backgroundColor, 
      ),
      home: FutureBuilder<void>(
        future: widget.initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF30BE91)),
              ),
            );
          }
          return Scaffold(
            backgroundColor: const Color(0xFF212121),
            body: SafeArea(
              child: HomePage(groupProvider: widget.groupProvider),
            ),
          );
        },
      ),
    );
  }
}