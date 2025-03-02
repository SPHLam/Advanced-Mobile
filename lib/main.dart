import 'package:flutter/material.dart';
import 'package:jarvis/View/Splash/splash_screen.dart';
import 'package:flutter/widgets.dart';
import 'package:jarvis/View/Welcome/welcome_screen.dart';
import 'package:jarvis/utils/theme.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jarvis',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: SplashScreen(),
    );
  }
}
