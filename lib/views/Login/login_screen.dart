import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:project_ai_chat/views/HomeChat/home.dart';
import 'package:project_ai_chat/views/Register/register_screen.dart';
import 'package:project_ai_chat/constants/colors.dart';
import 'package:project_ai_chat/constants/image_strings.dart';
import 'package:project_ai_chat/constants/sizes.dart';
import 'package:project_ai_chat/constants/text_strings.dart';
import 'package:project_ai_chat/core/Widget/elevated_button.dart';
import 'package:project_ai_chat/core/Widget/outlined_button.dart';
import 'package:project_ai_chat/services/analytics_service.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

import '../ForgetPassword/forget_password.dart';
import 'package:project_ai_chat/utils/validators/login_validator.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void initState() {
    super.initState();

    // Sử dụng addPostFrameCallback để tránh lỗi khi gọi setState trong build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final shouldShowMessage =
          ModalRoute.of(context)?.settings.arguments as bool? ?? false;

      if (shouldShowMessage) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Session expired, please log in again."),
            backgroundColor: Colors.red,
          ),
        );
      }
    });
  }

  String? _validateEmail(String? value) {
    return validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return validatePassword(value);
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      final success =
          await Provider.of<AuthViewModel>(context, listen: false).login(
        email: _emailController.text,
        password: _passwordController.text,
      );
      AnalyticsService().logEvent(
        "login",
        {
          "email": _emailController.text,
        },
      );

      if (success && mounted) {
        // Chuyển sang màn hình HomeChat
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeChat()),
        );
      } else if (mounted) {
        // Hiển thị thông báo lỗi
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Provider.of<AuthViewModel>(context, listen: false).error ??
                    'Đăng nhập thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _logInGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        scopes: <String>[
          'email',
          'openid',
        ],
      );

      // Get the user after successful sign in
      final GoogleSignInAccount? googleAccount = await googleSignIn.signIn();
      if (googleAccount == null) {
        // User cancelled the sign-in
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đăng nhập Google bị hủy'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      final GoogleSignInAuthentication googleAuthentication = await googleAccount.authentication;

      print("GG access token: ${googleAuthentication.accessToken}");
      print("GG id token: ${googleAuthentication.idToken}");

      // Call the Google login method from AuthViewModel
      final success = await Provider.of<AuthViewModel>(context, listen: false)
          .loginGoogle(
        code: googleAuthentication.idToken ?? '',
        codeVerifier: googleAuthentication.accessToken ?? '',
      );

      // Log analytics event
      AnalyticsService().logEvent(
        "google_login",
        {
          "email": googleAccount.email,
        },
      );

      if (success && mounted) {
        // Navigate to HomeChat screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeChat()),
        );
      } else if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                Provider.of<AuthViewModel>(context, listen: false).error ??
                    'Đăng nhập Google thất bại'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Handle any unexpected errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(tDefaultSize),
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Section 1 - Title
                  Text(
                    loginTitleString,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    loginSubtitleString,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: tFormHeight),

                  // Section 2 - Form
                  Form(
                    key: _formKey,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: tFormHeight - 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            controller: _emailController,
                            validator: _validateEmail,
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.email_outlined),
                              label: Text(emailString),
                            ),
                          ),
                          const SizedBox(height: tFormHeight - 20),
                          TextFormField(
                            controller: _passwordController,
                            validator: _validatePassword,
                            obscureText: !_isPasswordVisible,
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.password_outlined),
                              label: const Text(passwordString),
                              suffixIcon: IconButton(
                                onPressed: () {
                                  setState(() {
                                    _isPasswordVisible = !_isPasswordVisible;
                                  });
                                },
                                icon: Icon(
                                  _isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: tFormHeight - 20),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ForgetPasswordScreen(),
                                  ),
                                );
                              },
                              child: const Text(
                                forgetPasswordString,
                                style: TextStyle(color: Colors.blue),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                shape: const RoundedRectangleBorder(),
                                foregroundColor: Colors.white,
                                backgroundColor: secondaryColor,
                                side: const BorderSide(color: secondaryColor),
                                padding: const EdgeInsets.symmetric(
                                    vertical: tButtonHeight),
                              ),
                              onPressed: context.watch<AuthViewModel>().isLoading
                                  ? null
                                  : _login,
                              child: context.watch<AuthViewModel>().isLoading
                                  ? const CircularProgressIndicator()
                                  : const Text('LOGIN'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Section 3 - Other options
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text("OR"),
                      const SizedBox(height: tFormHeight - 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButtonCustom(
                          icon: const Image(
                            image: AssetImage(googleLogoImage),
                            width: 20.0,
                          ),
                          onPressed: _logInGoogle,
                          label: loginWithGoogleString,
                        ),
                      ),
                      const SizedBox(height: tFormHeight - 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RegisterScreen(),
                            ),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: notHaveAnAccountString,
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: const [
                              TextSpan(
                                text: " $registerString",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
