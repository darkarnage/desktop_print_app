import 'package:flutter/material.dart';
import 'features/home/home_screen.dart';

class PrintApp extends StatelessWidget {
  const PrintApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Print',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1A73E8)),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
