import 'package:flutter/material.dart';
import 'package:jarvis/views/Login/login_screen.dart';
import 'package:jarvis/views/Splash/splash_screen.dart';
// import 'package:jarvis/services/chat_service.dart';
import 'package:jarvis/utils/theme/theme.dart';
import 'package:jarvis/view_models/knowledge_base_view_model.dart';
import 'package:jarvis/view_models/ai_chat_list_view_model.dart';
import 'package:jarvis/view_models/auth_view_model.dart';
import 'package:jarvis/view_models/message_view_model.dart';
import 'package:jarvis/view_models/prompt_list_view_model.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// import 'package:jarvis/services/prompt_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        // Provider<ChatService>(
        //   create: (_) => ChatService(
        //     prefs: prefs,
        //   ),
        // ),
        // Provider<PromptService>(
        //   create: (_) => PromptService(),
        // ),
        ChangeNotifierProvider(
          create: (context) => MessageModel(
            // context.read<ChatService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => PromptListViewModel()),
        ChangeNotifierProvider(create: (context) => KnowledgeBase()),
        ChangeNotifierProvider(create: (context) => AIChatList()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
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
      title: 'JarvisCopi Assistant',
      theme: TAppTheme.lightTheme,
      darkTheme: TAppTheme.darkTheme,
      themeMode: ThemeMode.system,
      navigatorKey: navigatorKey,
      routes: {'/login': (context) => const LoginScreen()},
      home: const SplashScreen(),
    );
  }
}