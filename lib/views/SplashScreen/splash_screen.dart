import 'package:flutter/material.dart';
import 'package:jarvis/views/HomeChat/home.dart';
import 'package:jarvis/views/Welcome/welcome_screen.dart';
import 'package:jarvis/constants/image_strings.dart';
import 'package:jarvis/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool animate = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIsLoginState();
    });
    startAnimation();
  }

  Future<void> _loadIsLoginState() async {
    await Provider.of<AuthViewModel>(context, listen: false)
        .loadIsLoggedInFromPrefs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 2000),
          opacity: animate ? 1 : 0,
          child: SizedBox(
            width: 300,
            height: 300,
            child: Image(
              image: AssetImage(splashImage),
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }

  Future startAnimation() async {
    await Future.delayed(const Duration(milliseconds: 500));
    setState(() => animate = true);
    await Future.delayed(const Duration(milliseconds: 5000));

    final authState = Provider.of<AuthViewModel>(context, listen: false);

    if (authState.isLoggedIn) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeChat()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeScreen()),
      );
    }
  }
}
