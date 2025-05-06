import 'package:flutter/material.dart';
import 'package:project_ai_chat/utils/theme/widget_themes/text_field_theme.dart';
import 'package:project_ai_chat/utils/theme/widget_themes/text_theme.dart';

class TAppTheme {
  TAppTheme._();

  static ThemeData lightTheme = ThemeData(
      brightness: Brightness.light,
      textTheme: TTextTheme.lightTextTheme,
      inputDecorationTheme: TTextFormFieldTheme.lightInputDecorationTheme,
  );

  static ThemeData darkTheme = ThemeData(
      brightness: Brightness.dark,
      textTheme: TTextTheme.darkTextTheme,
      inputDecorationTheme: TTextFormFieldTheme.darkInputDecorationTheme,
  );

}
