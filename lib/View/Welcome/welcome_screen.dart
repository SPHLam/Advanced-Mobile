import 'package:flutter/material.dart';
import 'package:jarvis/View/Login/login_screen.dart';
import 'package:jarvis/View/Register/register_screen.dart';
import 'package:jarvis/constants/colors.dart';
import 'package:jarvis/constants/image_strings.dart';
import 'package:jarvis/constants/sizes.dart';
import 'package:jarvis/constants/text_strings.dart';
import 'package:jarvis/core/Widget/elevated_button.dart';
import 'package:jarvis/core/Widget/outlined_button.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    var mediaQuery = MediaQuery.of(context);
    var height = mediaQuery.size.height;
    var width = mediaQuery.size.width;
    var brightness = mediaQuery.platformBrightness;
    var isDarkMode = brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDarkMode ? secondaryColor : primaryColor,
      body: Center(
        child: Container(
          padding: EdgeInsets.all(tDefaultSize),
          width: width * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Image(
                  image: AssetImage(welcomeScreenImage), height: height * 0.5),
              Column(
                children: [
                  Text(welcomeString,
                      style: Theme.of(context).textTheme.headlineSmall),
                  Text(
                    welcomeSubtitleString,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButtonCustom(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => LoginScreen()),
                        );
                      },
                      label: loginString.toUpperCase(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButtonCustom(
                      text: registerString.toUpperCase(),
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RegisterScreen()),
                        );
                      },
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}