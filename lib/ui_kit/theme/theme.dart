import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MentourTheme {
  static ThemeData lightTheme = ThemeData(
    fontFamily: "Nunito",
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    fontFamily: "Nunito",
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
  );
}
