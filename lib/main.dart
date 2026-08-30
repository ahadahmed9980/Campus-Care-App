import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'bindings/initial_binding.dart';
import 'controllers/connectivity_controller.dart';
import 'data/repositories/campus_repositories.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'screens/connectivity/no_internet_screen.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';
import 'utils/preferences_keys.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint(details.exceptionAsString());
  };

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization failed: $e');
  }

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  ThemeMode initialThemeMode = ThemeMode.light;
  try {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool(PreferencesKeys.isDarkMode) ?? false;
    initialThemeMode = isDark ? ThemeMode.dark : ThemeMode.light;
  } catch (e) {
    debugPrint('Failed to load initial theme: $e');
  }

  runApp(CampusCareApp(initialThemeMode: initialThemeMode));
}

class CampusCareApp extends StatelessWidget {
  final ThemeMode initialThemeMode;
  const CampusCareApp({super.key, required this.initialThemeMode});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider(create: (_) => UserRepository()),
        Provider(create: (_) => RequestRepository()),
        Provider(create: (_) => CategoryRepository()),
        Provider(create: (_) => AnnouncementRepository()),
      ],
      child: GetMaterialApp(
        title: 'Campus Care',
        debugShowCheckedModeBanner: false,
        initialBinding: InitialBinding(),
        initialRoute: '/',
        getPages: AppPages.routes,
        unknownRoute: AppPages.routes.first,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: initialThemeMode,
        defaultTransition: Transition.fadeIn,
        builder: (context, child) {
          return Obx(() {
            final isRegistered = Get.isRegistered<ConnectivityController>();
            if (!isRegistered) {
              return child ?? const SizedBox.shrink();
            }
            final connectivityCtrl = Get.find<ConnectivityController>();
            return Stack(
              children: [
                // ignore: use_null_aware_elements
                if (child != null) child,
                if (!connectivityCtrl.isConnected.value)
                  const Positioned.fill(child: NoInternetScreen()),
              ],
            );
          });
        },
      ),
    );
  }
}
