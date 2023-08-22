import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  late SharedPreferences _prefs;
  bool _initialized = false;
  Completer<bool> completer = Completer();

  static const String _installKey = 'install';
  static const String _upgradeKey = 'upgrade';

  static CacheService instance = CacheService._();

  CacheService._() {
    _init();
  }

  _init() async {
    SharedPreferences.getInstance().then((value) {
      _prefs = value;
      completer.complete(true);
      if (kDebugMode) {
        print('initialized');
      }
    });
    _initialized = true;
    if (kDebugMode) {
      print('initialized2');
    }
  }

  set installed(List<String> installed) {
    _prefs.setStringList(_installKey, installed);
  }

  List<String> get installed {
    return _prefs.getStringList(_installKey)!;
  }

  bool hasInstalled() {
    return _prefs.containsKey(_installKey);
  }

  set upgradeable(List<String> upgradeable) {
    _prefs.setStringList(_upgradeKey, upgradeable);
  }

  List<String> get upgradeable {
    return _prefs.getStringList(_upgradeKey)!;
  }

  bool hasUpgradeable() {
    return _prefs.containsKey(_upgradeKey);
  }

  bool get initialized => _initialized;

  Future<bool> isInitialized() {
    return completer.future;
  }
}
