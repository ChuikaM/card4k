import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import 'package:card4k/data/di/service_locator.dart';
import 'package:card4k/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  ServiceLocator().init();
  runApp(MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

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
      home: Scaffold(
        backgroundColor: const Color(0xFF212121),
        body: SafeArea(
          child: HomePage(),
        ),
      )
    );
  }
}