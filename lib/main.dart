import 'package:flutter/material.dart';
import 'package:voice_assistant_app/home_page.dart';
import 'package:voice_assistant_app/pallete.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Assistant App',
      theme: ThemeData.light(useMaterial3: true).copyWith(
          scaffoldBackgroundColor: Pallete.whiteColor,
          appBarTheme: AppBarTheme(
            backgroundColor: Pallete.whiteColor,
          )),
      home: homepage(),
    );
  }
}
