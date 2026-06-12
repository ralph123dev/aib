import 'package:flutter/material.dart';
import 'features/welcome/pages/welcome_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orbit Messenger',
      theme: ThemeData.dark(),
      home: const WelcomePage(),
    );
  }
}
