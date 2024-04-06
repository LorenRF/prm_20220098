import 'package:flutter/material.dart';
import '../singin.dart';
import 'eventsview.dart';
import 'login.dart';
import 'screen.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginScreen(),
    );
  }
}
