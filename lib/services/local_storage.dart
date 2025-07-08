import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  final SharedPreferences _prefs;

  LocalStorageService(this._prefs);

  Future<String> getOrCreateNamespace() async {
    final namespace = _prefs.getString('namespace');
    if (namespace != null) {
      debugPrint('Namespace found: $namespace');
      return namespace;
    }
    final newNamespace = DateTime.now().millisecondsSinceEpoch.toString();
    await _prefs.setString('namespace', newNamespace);
    debugPrint('Namespace created: $newNamespace');
    return newNamespace;
  }
}
