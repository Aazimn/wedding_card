import 'package:flutter/material.dart';
import 'package:weddingcard/views/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Wedding Invitation',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFC19A6B),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const WeddingSplashScreen(),
    );
  }
}
