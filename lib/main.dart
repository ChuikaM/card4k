import 'package:card4k/constants/colors.dart';
import 'package:card4k/providers/sqlite_group_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 

import 'package:card4k/pages/home_page.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark,
  ));

  final container = ProviderContainer();
  await container.read(sqliteGroupProvider).init();

  runApp(UncontrolledProviderScope(container: container, child: MainApp()));
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.primaryBackground,
        canvasColor: AppColors.primaryBackground, 
      ),
      home: Scaffold(
        backgroundColor: AppColors.secondaryBackground,
        body: SafeArea(
          child: HomePage(),
        ),
      )
    );
  }
}