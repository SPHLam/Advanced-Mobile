import 'package:flutter/material.dart';
import 'package:jarvis/View/HomeChat/home.dart';
import 'package:jarvis/View/Login/login_screen.dart';
import 'package:jarvis/constants/sizes.dart';
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/core/Widget/elevated_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.person_outline_rounded),
                            label: Text(fullNameString),
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.email_outlined),
                            label: Text(emailString),
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.numbers_outlined),
                            label: Text(phoneNumberString),
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 20),
                        TextFormField(
                          decoration: const InputDecoration(
                            prefixIcon: Icon(Icons.password_outlined),
                            label: Text(passwordString),
                          ),
                        ),
                        const SizedBox(height: tFormHeight - 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButtonCustom(
                            text: registerString.toUpperCase(),
                            onPressed: () {
                              Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => const HomeChat()));
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  // -- .end - 2--

                  // -- Section - 3 --
                  Column(
                    children: [
                      const SizedBox(height: tFormHeight - 20),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LoginScreen()));
                          },
                          child: Text.rich(
                            TextSpan(
                                text: alreadyHaveAnAccountString,
                                style: Theme.of(context).textTheme.bodyLarge,
                                children: const [
                                  TextSpan(
                                    text: " $loginString",
                                    style: TextStyle(color: Colors.blue),
                                  )
                                ]),
                          ))
                    ],
                  )
                  // -- .end - 3--
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}