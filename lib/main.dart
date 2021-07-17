import 'package:flame/flame.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import 'screens/main_menu.dart';
import 'models/player_data.dart';
import 'models/spaceship_details.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // This opens the app in fullscreen mode.
  Flame.device.fullScreen();

  runApp(
    FutureProvider<PlayerData>(
      create: (BuildContext context) => getPlayerData(),
      initialData: PlayerData.fromMap(PlayerData.defaultData),
      builder: (context, child) {
        // We use .value constructor here because the required PlayerData
        // object is already created by upstream FutureProvider.
        return ChangeNotifierProvider<PlayerData>.value(
          value: Provider.of<PlayerData>(context),
          child: child,
        );
      },
      child: MaterialApp(
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
    ),
  );
}

// This function initializes hive with app's
// documents directory and also registers
// all the hive adapters.
Future<void> initHive() async {
  final dir = await getApplicationDocumentsDirectory();
  Hive.init(dir.path);

  Hive.registerAdapter(PlayerDataAdapter());
  Hive.registerAdapter(SpaceshipTypeAdapter());
}

/// This function reads the stored [PlayerData] from disk.
Future<PlayerData> getPlayerData() async {
  // First initialize hive.
  await initHive();

  // Open the player data box and read player data from it.
  final box = await Hive.openBox<PlayerData>('PlayerDataBox');
  final playerData = box.get('PlayerData');

  // If player data is null, it means this is a fresh launch
  // of the game. In such case, we first store the default
  // player data in the player data box and then return the same.
  if (playerData == null) {
    box.put('PlayerData', PlayerData.fromMap(PlayerData.defaultData));
  }

  return box.get('PlayerData')!;
}
