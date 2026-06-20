import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/welcome/pages/welcome_page.dart';

void main() {
  initializeDateFormatting('fr_FR', null).then((_) {
    runApp(const MyApp());
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AibaPay',
      theme: ThemeData.dark(),
      home: const WelcomePage(),
    );
  }
}
//Développer par Ralph Dev 
//ralphurgue@gmail.com
//Watshapp: +237689476780 
//Telegram: +237677968494 
//portfolio: https://ralphdeveloppeur.vercel.app