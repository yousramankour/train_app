import 'package:flutter/widgets.dart';
import 'dart:developer' as developer;

class Appobservation with WidgetsBindingObserver {
  static bool isAppInForeground = true;

  static void startObserver() {
    WidgetsBinding.instance.addObserver(Appobservation());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    isAppInForeground = (state == AppLifecycleState.resumed);
    developer.log("App is in foreground: $isAppInForeground");
  }
}
