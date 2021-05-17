import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'screens/main_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // This opens the app in fullscreen mode.
  Flame.device.fullScreen();

  runApp(
    MaterialApp(
      // Dark more because we are too cool for white theme.
      themeMode: ThemeMode.dark,
      // We are even too cool for default dark theme, so use
      // copyWith() to set textTheme and scaffoldBackgroundColor
      // to match our level of coolness 😆.
      darkTheme: ThemeData.dark().copyWith(
        textTheme: GoogleFonts.bungeeInlineTextTheme(),
        scaffoldBackgroundColor: Colors.black,
      ),
      // MainMenu will be the first screen for now.
      // But this might change in future if we decide
      // to add a splash screen.
      home: const MainMenu(),
    ),
  );
}
