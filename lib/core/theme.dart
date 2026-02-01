import 'package:flutter/material.dart';

const kNavy = Color(0xFF1A3C6E);
const kCyan = Color(0xFF3BAFDA);

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: kNavy),
  scaffoldBackgroundColor: const Color(0xFFF6F7FB),
  appBarTheme: const AppBarTheme(
    backgroundColor: kNavy,
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  chipTheme: const ChipThemeData(side: BorderSide(color: Colors.transparent)),
);
