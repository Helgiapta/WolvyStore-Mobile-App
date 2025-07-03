import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:wolvystore/controllers/theme_controller.dart';
import 'package:wolvystore/controllers/cart_controller.dart';
import 'package:wolvystore/controllers/product_controller.dart';

import 'package:wolvystore/utils/session_manager.dart';
import 'package:wolvystore/utils/app_themes.dart';

import 'package:wolvystore/view/login_screen.dart';
import 'package:wolvystore/view/home_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      statusBarBrightness: Brightness.light,
    ),
  );

  const supabaseUrl = 'https://ncopodfyeieakbftsuso.supabase.co';
  const supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jb3BvZGZ5ZWllYWtiZnRzdXNvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTA5NTk0OTksImV4cCI6MjA2NjUzNTQ5OX0.GqD5xx9_W_lDO5OmD2uDcPiM4U3QCjmO6Y6J11jWG54';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  Get.put(ThemeController());
  Get.put(CartController());
  Get.put(ProductController());

  final uid = await SessionManager.getUID();
  final email = await SessionManager.getEmail();

  runApp(
    MyApp(
      initialScreen:
          (uid != null && email != null)
              ? const HomeWrapper()
              : const LoginScreen(),
    ),
  );
}

class MyApp extends StatelessWidget {
  final Widget initialScreen;
  const MyApp({super.key, required this.initialScreen});

  @override
  Widget build(BuildContext context) {
    final themeController = Get.find<ThemeController>();

    return Obx(
      () => GetMaterialApp(
        title: 'WolvyStore',
        debugShowCheckedModeBanner: false,
        theme: AppThemes.lightTheme,
        darkTheme: AppThemes.darkTheme,
        themeMode: themeController.themeMode.value,
        home: initialScreen,
        getPages: [
          GetPage(name: '/login', page: () => const LoginScreen()),
          GetPage(name: '/main', page: () => const HomeWrapper()),
        ],
      ),
    );
  }
}
