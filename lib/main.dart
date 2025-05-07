import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:project_ai_chat/views/EmailChat/email.dart';
import 'package:project_ai_chat/views/HomeChat/home.dart';
import 'package:project_ai_chat/views/Login/login_screen.dart';
import 'package:project_ai_chat/views/SplashScreen/splash_screen.dart';
import 'package:project_ai_chat/firebase_options.dart';
import 'package:project_ai_chat/services/bot_service.dart';
import 'package:project_ai_chat/services/chat_service.dart';
import 'package:project_ai_chat/services/email_chat_service.dart';
import 'package:project_ai_chat/utils/theme/theme.dart';
import 'package:project_ai_chat/viewmodels/bot_view_model.dart';
import 'package:project_ai_chat/viewmodels/emailchat_view_model.dart';
import 'package:project_ai_chat/viewmodels/knowledge_base_view_model.dart';
import 'package:project_ai_chat/viewmodels/aichat_list_view_model.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:project_ai_chat/viewmodels/homechat_view_model.dart';
import 'package:project_ai_chat/viewmodels/prompt_list_view_model.dart';
import 'package:project_ai_chat/views/Login/login_screen.dart';
import 'package:project_ai_chat/views/SplashScreen/splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:project_ai_chat/services/prompt_service.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  final prefs = await SharedPreferences.getInstance();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    MultiProvider(
      providers: [
        Provider<ChatService>(
          create: (_) => ChatService(),
        ),
        Provider<EmailChatService>(
          create: (_) => EmailChatService(),
        ),
        Provider<PromptService>(
          create: (_) => PromptService(),
        ),
        Provider<BotService>(
          create: (_) => BotService(),
        ),
        ChangeNotifierProvider(
          create: (context) => HomeChatViewModel(
            context.read<ChatService>(),
          ),
        ),
        ChangeNotifierProvider(create: (context) => EmailChatViewModel()),
        ChangeNotifierProvider(create: (context) => PromptListViewModel()),
        ChangeNotifierProvider(create: (context) => BotViewModel()),
        ChangeNotifierProvider(create: (context) => KnowledgeBaseProvider()),
        ChangeNotifierProvider(create: (context) => AIChatList()),
        ChangeNotifierProvider(create: (_) => AuthViewModel()),
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
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
      home: SplashScreen(),
    );
  }
}
