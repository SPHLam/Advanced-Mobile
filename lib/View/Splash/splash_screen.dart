import 'package:flutter/material.dart';
import 'package:jarvis/View/Welcome/welcome_screen.dart';
import 'package:jarvis/constants/image_strings.dart';

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
    startAnimation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 2000),
          opacity: animate ? 1 : 0,
          child: SizedBox(
            width: 300, // Tăng kích thước ảnh (có thể điều chỉnh)
            height: 300,
            child: Image(
              image: AssetImage(splashImage),
              fit: BoxFit.contain, // Giữ tỷ lệ ảnh
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
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => WelcomeScreen()));
  }
}