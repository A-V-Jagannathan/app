import 'package:flutter/material.dart';

const primaryBlue = Color(0xFF003A96);
const secondaryBlue = Color(0xFF009CA6);
const tertiaryBlue = Color(0xFFB1E4E3);
const textColor = Color(0xFF202020);

const ColorScheme appColorScheme = ColorScheme(
  primary: primaryBlue,
  onPrimary: Colors.white,
  secondary: secondaryBlue,
  onSecondary: Colors.white,
  tertiary: tertiaryBlue,
  onTertiary: textColor,
  error: Colors.red,
  onError: textColor,
  surface: Color(0xEBEBEBFF),
  onSurface: textColor,
  brightness: Brightness.light,
);
