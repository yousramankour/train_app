import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart'; // Importer Provider
import 'splash_screen.dart';
import 'theme_provider.dart'; // Importer le fichier ThemeProvider
import 'package:firebase_core/firebase_core.dart';
import 'theme.dart'; // Importer le fichier où tu as défini les thèmes

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await Firebase.initializeApp();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fr'), Locale('ar')],
      path: 'assets/translate', // Assurez-vous que le chemin est correct
      fallbackLocale: Locale('en'),
      child: ChangeNotifierProvider(
        create: (context) => ThemeProvider(), // Fournir le thème
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
      themeMode: themeProvider.themeMode, // Appliquer le mode clair/sombre
      theme:
          lightTheme, // Appliquer le thème clair que tu as défini dans theme.dart
      darkTheme:
          darkTheme, // Appliquer le thème sombre que tu as défini dans theme.dart
      home: const SplashScreen(),
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
    );
  }
}
