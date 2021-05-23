import 'package:flame/flame.dart';
import 'package:flutter/material.dart';

import 'screens/main_menu.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // This opens the app in fullscreen mode.
  Flame.device.fullScreen();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      // Dark more because we are too cool for white theme.
      themeMode: ThemeMode.dark,
      // Use custom theme with 'BungeeInline' font.
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'BungeeInline',
        scaffoldBackgroundColor: Colors.black,
      ),
      // MainMenu will be the first screen for now.
      // But this might change in future if we decide
      // to add a splash screen.
      home: const MainMenu(),
    ),
  );
}
