import 'package:flutter/material.dart';
//import 'package:jarvis/View/HomeChat/home.dart';
import 'package:jarvis/View/Register/register_screen.dart';
import 'package:jarvis/constants/colors.dart';
import 'package:jarvis/constants/image_strings.dart';
import 'package:jarvis/constants/sizes.dart';
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/core/Widget/elevated_button.dart';
import 'package:jarvis/core/Widget/outlined_button.dart';

//import '../ForgetPassword/forget-password.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return SafeArea(
      child: Scaffold(
        body: Center(
          // Căn giữa nội dung
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(tDefaultSize),
              alignment: Alignment.center, // Căn giữa Container
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Căn giữa nội dung trong Column
                crossAxisAlignment:
                    CrossAxisAlignment.center, // Căn giữa theo chiều ngang
                children: [
                  // -- Section - 1 --
                  Text(
                    loginTitleString,
                    style: Theme.of(context).textTheme.headlineLarge,
                    textAlign: TextAlign.center, // Căn giữa văn bản
                  ),
                  Text(
                    loginSubtitleString,
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center, // Căn giữa văn bản
                  ),
                  const SizedBox(height: tFormHeight),

                  // -- Section - 2 --
                  Form(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: tFormHeight - 10),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.center, // Căn giữa input fields
                        children: [
                          TextFormField(
                            decoration: const InputDecoration(
                                prefixIcon: Icon(Icons.email_outlined),
                                label: Text(emailString)),
                          ),
                          const SizedBox(height: tFormHeight - 20),
                          TextFormField(
                            decoration: const InputDecoration(
                              prefixIcon: Icon(Icons.password_outlined),
                              label: Text(passwordString),
                              suffixIcon: IconButton(
                                  onPressed: null,
                                  icon: Icon(Icons.remove_red_eye_sharp)),
                            ),
                          ),
                          const SizedBox(height: tFormHeight - 20),
                          // Align(
                          //   alignment: Alignment.centerRight,
                          //   child: TextButton(
                          //     onPressed: () {
                          //       Navigator.push(
                          //           context,
                          //           MaterialPageRoute(
                          //               builder: (context) => ForgetPasswordScreen()));
                          //     },
                          //     child: const Text(forgetPasswordString, style: TextStyle(color: Colors.blue)),
                          //   ),
                          // ),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButtonCustom(
                              text: loginString.toUpperCase(),
                              onPressed: () {
                                // Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => HomeChat()));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // -- .end - 2--

                  // -- Section - 3 --
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
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
                                  builder: (context) => RegisterScreen()));
                        },
                        child: Text.rich(
                          TextSpan(
                            text: dontHaveAnAccountString,
                            style: Theme.of(context).textTheme.bodyLarge,
                            children: const [
                              TextSpan(
                                text: " $registerString",
                                style: TextStyle(color: Colors.blue),
                              )
                            ],
                          ),
                        ),
                      )
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
