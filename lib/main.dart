import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme/app_theme.dart';
import 'screens/auth/splash_screen.dart';
import 'screens/profile/notifications_screen.dart';

// Background message handler (Must be a top-level function)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint("Background message received: ${message.messageId}");
  
  if (message.notification != null) {
    await saveNotificationToFirestore(
      message.notification!.title ?? 'Notification',
      message.notification!.body ?? '',
    );
  }
}

// Helper function to save incoming notification to Firestore so it shows in NotificationsScreen
Future<void> saveNotificationToFirestore(String title, String message) async {
  try {
    await FirebaseFirestore.instance.collection('notifications').add({
      'title': title,
      'message': message,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    debugPrint("Error saving notification to Firestore: $e");
  }
}

// Global ValueNotifier to track theme changes across the app
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

// Global Navigator Key to show dialogs or navigate from anywhere without direct context
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Register background messaging handler
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  // Load saved theme preference
  final prefs = await SharedPreferences.getInstance();
  final isDarkMode = prefs.getBool('isDarkMode') ?? false;
  themeNotifier.value = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  runApp(const CampusCareApp());
}

class CampusCareApp extends StatefulWidget {
  const CampusCareApp({super.key});

  @override
  State<CampusCareApp> createState() => _CampusCareAppState();
}

class _CampusCareAppState extends State<CampusCareApp> {
  @override
  void initState() {
    super.initState();
    _setupNotifications();
  }

  void _setupNotifications() async {
    // 1. Request Permission (iOS & Android 13+)
    NotificationSettings settings = await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('User granted notification permission');
    }

    // 2. Subscribe to Topic (Sabhi students ke liye broadcast)
    await FirebaseMessaging.instance.subscribeToTopic('all_students');

    // 3. Foreground message listener to save to Firestore & show alert dialog
    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      if (message.notification != null) {
        String title = message.notification!.title ?? 'Notification';
        String body = message.notification!.body ?? '';

        // Firestore mein save karein taake NotificationsScreen mein show ho
        await saveNotificationToFirestore(title, body);

        final dialogContext = navigatorKey.currentContext;
        
        if (dialogContext != null && dialogContext.mounted) {
          showDialog(
            context: dialogContext,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: Text(title),
              content: Text(body),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    });

    // 4. Background State Tap Handling (Jab app minimize ho aur notification par click ho)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint("Notification clicked from background!");
      if (message.notification != null) {
        // Note: Background handlers ya onBackgroundMessage pehle hi save kar chuke honge,
        // lekin duplicate se bachne ke liye chaho toh yahan check bhi kar sakte ho, 
        // warna safe side save call rehne di ja sakti hai.
      }
      _navigateToNotificationsScreen();
    });

    // 5. Terminated State Handling (Jab app bilkul band ho aur notification se khule)
    FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        debugPrint("App opened from terminated state by notification!");
        Future.delayed(const Duration(milliseconds: 500), () {
          _navigateToNotificationsScreen();
        });
      }
    });
  }

  void _navigateToNotificationsScreen() {
    navigatorKey.currentState?.push(
      MaterialPageRoute(builder: (_) => const NotificationsScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    // ValueListenableBuilder listens to themeNotifier and rebuilds MaterialApp when it changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentThemeMode, child) {
        return MaterialApp(
          navigatorKey: navigatorKey, // <- Yahan navigatorKey properly linked hai
          title: 'Campus Care',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: const SplashScreen(),
        );
      },
    );
  }
}