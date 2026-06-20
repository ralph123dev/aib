import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'features/welcome/pages/welcome_page.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: kFirebaseOptions);
  await initializeDateFormatting('fr_FR', null);
  runApp(const MyApp());
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