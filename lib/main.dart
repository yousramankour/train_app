import 'package:appmob/splash__2.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // Importer Provider
import 'theme_provider.dart'; // Importer le fichier ThemeProvider
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart';
import 'etatdeapp.dart';
import 'dart:async';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Affiche ou traite la notification
  await NotificationService.showNotification(
    message.notification?.title ?? 'Titre par défaut',
    message.notification?.body ?? 'Message par défaut',
  );
}

void subscibetotopic() {
  FirebaseMessaging.instance.subscribeToTopic("all");
}

void sendNotificationAfterDelay() async {
  NotificationService.showNotification("welcome!", "bienvenus dans notre app");
  await Future.delayed(Duration(milliseconds: 100));
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  Appobservation.startObserver();
  subscibetotopic();
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  sendNotificationAfterDelay();
  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translate', // Assurez-vous que le chemin est correct
      fallbackLocale: Locale('en'),
      child: ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyApp(),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Train App",
      themeMode: themeProvider.currentTheme,
      theme: ThemeData.light(),
      darkTheme:
          ThemeData.dark(), // Appliquer le thème sombre que tu as défini dans theme.dart
      home: const WelcomeScreen(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
