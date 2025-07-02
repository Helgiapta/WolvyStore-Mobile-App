import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ThemeController extends GetxController {
  final _box = GetStorage();
  final themeMode = ThemeMode.system.obs;

  @override
  void onInit() {
    final savedTheme = _box.read('themeMode');
    if (savedTheme != null && savedTheme is String) {
      themeMode.value = savedTheme == 'dark' ? ThemeMode.dark : ThemeMode.light;
    }
    super.onInit();
  }

  void toggleTheme() {
    if (themeMode.value == ThemeMode.dark) {
      themeMode.value = ThemeMode.light;
      _box.write('themeMode', 'light');
    } else {
      themeMode.value = ThemeMode.dark;
      _box.write('themeMode', 'dark');
    }
  }
}
