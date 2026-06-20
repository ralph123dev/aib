import 'package:flutter/material.dart';
import '../../../features/auth/pages/auth_page.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _showButton = true);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fond blanc
          Container(
            color: Colors.white,
          ),
          // Content
          Column(
            children: [
              // Logo centré
              Expanded(
                child: Center(
                  child: Image.asset(
                    'assets/images/ralph.png',
                    width: 150,
                    height: 150,
                  ),
                ),
              ),
              // Button with animation
              if (_showButton)
                ScaleTransition(
                  scale: Tween<double>(begin: 0.0, end: 1.0).animate(
                    CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
                  ),
                  child: FadeTransition(
                    opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 50),
                      child: SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4FA3D1),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AuthPage(),
                              ),
                            );
                          },
                          child: const Text(
                            'Commencer',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                )
              else
                const SizedBox(height: 100),
            ],
          ),
        ],
      ),
    );
  }
}

//Développer par Ralph Dev 
//ralphurgue@gmail.com
//Watshapp: +237689476780 
//Telegram: +237677968494 
//portfolio: https://ralphdeveloppeur.vercel.app