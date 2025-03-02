import 'package:flutter/material.dart';
//import 'package:jarvis/View/Home/home.dart';
import 'package:jarvis/View/Login/login_screen.dart';
import 'package:jarvis/constants/colors.dart';
import 'package:jarvis/constants/image_strings.dart';
import 'package:jarvis/constants/sizes.dart';
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/core/Widget/elevated_button.dart';
import 'package:jarvis/core/Widget/outlined_button.dart';

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
                  Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: tFormHeight - 10),
                    child: Form(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.person_outline_rounded),
                              label: Text(fullnameString),
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
                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => Home()));
                              },
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  // -- .end - 2--

                  // -- Section - 3 --
                  Column(
                    children: [
                      const Text("OR"),
                      const SizedBox(height: tFormHeight - 20),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButtonCustom(
                          icon: Image(
                            image: AssetImage(googleLogoImage),
                            width: 20.0,
                          ),
                          onPressed: () {},
                          label: loginWithGoogleString,
                        ),
                      ),
                      const SizedBox(height: tFormHeight - 20),
                      TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => LoginScreen()));
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
