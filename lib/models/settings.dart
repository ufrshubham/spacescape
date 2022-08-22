import 'package:hive/hive.dart';
import 'package:flutter/foundation.dart';

part 'settings.g.dart';

@HiveType(typeId: 2)
class Settings extends ChangeNotifier with HiveObjectMixin {
  static const String settingsBox = 'SettingsBox';
  static const String settingsKey = 'Settings';

  @HiveField(0)
  bool _sfx = false;
  bool get soundEffects => _sfx;
  set soundEffects(bool value) {
    _sfx = value;
    notifyListeners();
    save();
  }

  @HiveField(1)
  bool _bgm = false;
  bool get backgroundMusic => _bgm;
  set backgroundMusic(bool value) {
    _bgm = value;
    notifyListeners();
    save();
  }

  Settings({
    bool soundEffects = false,
    bool backgroundMusic = false,
  })  : _bgm = backgroundMusic,
        _sfx = soundEffects;
}
