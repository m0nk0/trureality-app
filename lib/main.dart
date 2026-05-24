import 'package:flutter/material.dart';
import 'screens/verify_screen.dart';

void main() {
  runApp(const TrueTalkProto());
}

class TrueTalkProto extends StatelessWidget {
  const TrueTalkProto({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TrueTalk Proto',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF00D4AA),
        scaffoldBackgroundColor: const Color(0xFF0F1115),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF0F1115),
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
        ),
      ),
      home: const VerifyScreen(),
    );
  }
}