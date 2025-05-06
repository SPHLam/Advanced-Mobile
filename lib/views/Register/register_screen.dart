import 'package:flutter/material.dart';
import 'package:project_ai_chat/views/Login/login_screen.dart';
import 'package:project_ai_chat/constants/colors.dart';
import 'package:project_ai_chat/constants/sizes.dart';
import 'package:project_ai_chat/constants/text_strings.dart';
import 'package:project_ai_chat/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';
import 'package:project_ai_chat/utils/validators/register_validator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _validateEmail(String? value) {
    return validateEmail(value);
  }

  String? _validatePassword(String? value) {
    return validatePassword(value);
  }

  String? _validateConfirmPassword(String? confirmPassword) {
    return validateConfirmPassword(confirmPassword, _passwordController.text);
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final success = await context.read<AuthViewModel>().register(
        username: _usernameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful! Please log in'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                context.read<AuthViewModel>().error ?? 'Registration failed'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(tDefaultSize),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // -- Section - 1 --
                  Text(
                    registerTitleString,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    registerSubtitleString,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: tFormHeight),
                  // -- .end - 1 --

                  // -- Section - 2 --
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          controller: _usernameController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            label: Text(fullNameString),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please input username';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            label: Text(emailString),
                          ),
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_outlined),
                            label: Text(passwordString),
                          ),
                          validator: _validatePassword,
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          controller: _confirmPasswordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_outlined),
                            label: Text('Confirm Password'),
                          ),
                          validator: _validateConfirmPassword,
                        ),
                        const SizedBox(height: tFormHeight - 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              shape: const RoundedRectangleBorder(),
                              foregroundColor: whiteColor,
                              backgroundColor: secondaryColor,
                              side: const BorderSide(color: secondaryColor),
                              padding: const EdgeInsets.symmetric(
                                  vertical: tButtonHeight),
                            ),
                            onPressed: context.watch<AuthViewModel>().isLoading
                                ? null
                                : _register,
                            child: context.watch<AuthViewModel>().isLoading
                                ? const CircularProgressIndicator()
                                : const Text('SIGN UP'),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // -- .end - 2 --

                  // -- Section - 3 --
                  Column(
                    children: [
                      const SizedBox(height: tFormHeight - 20),
                      TextButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const LoginScreen()),
                          );
                        },
                        child: Text.rich(
                          TextSpan(
                            text: alreadyHaveAnAccountString,
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: const [
                              TextSpan(
                                text: " $loginString",
                                style: TextStyle(color: Colors.blue),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // -- .end - 3 --
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}