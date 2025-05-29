import 'service_message.dart';
import 'splash_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'notification_service.dart';
import 'etatdeapp.dart';

void subscribeToTopic() {
  FirebaseMessaging.instance.subscribeToTopic("all");
}

/*
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // Affiche ou traite la notification
  await NotificationService.showNotification(
    message.notification?.title ?? 'Titre par défaut',
    message.notification?.body ?? 'Message par défaut',
  );
}
*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();
  await NotificationService.initialize();
  Appobservation.startObserver();
  subscribeToTopic();
  MessageListenerService.listenToNewMessages();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translate', // Assurez-vous que le chemin est correct
      fallbackLocale: Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Train App",
      theme: ThemeData.light(), // Thème clair uniquement
      home: const WelcomeScreen(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
