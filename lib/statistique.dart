import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Statistiques")),
      body: Center(child: Text('Page des statistiques'.tr())),
    );
  }
}
