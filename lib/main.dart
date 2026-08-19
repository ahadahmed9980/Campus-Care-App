import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';

import 'bindings/initial_binding.dart';
import 'data/repositories/campus_repositories.dart';
import 'firebase_options.dart';
import 'routes/app_pages.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

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

  runApp(const CampusCareApp());
}

class CampusCareApp extends StatelessWidget {
  const CampusCareApp({super.key});

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
        themeMode: ThemeMode.light,
        defaultTransition: Transition.fadeIn,
      ),
    );
  }
}

