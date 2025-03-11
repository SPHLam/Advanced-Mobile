import 'package:flutter/material.dart';
import 'package:jarvis/View/Splash/splash_screen.dart';
import 'package:jarvis/utils/theme.dart';
import 'package:jarvis/ViewModel/knowledge_base.dart';
import 'ViewModel/ai-chat-list.dart';
import 'ViewModel/message-home-chat.dart';
import 'package:provider/provider.dart';


void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MessageModel()),
        ChangeNotifierProvider(create: (context) => KnowledgeBase()),
        ChangeNotifierProvider(create: (context) => AIChatList()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JarvisCopi',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
    );
  }
}