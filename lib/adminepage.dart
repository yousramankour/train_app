import 'package:appmob/feeduser.dart';
import 'package:appmob/station.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'admin.dart';
import 'affigars.dart';
import 'line.dart';

class AdminPanelPage extends StatefulWidget {
  const AdminPanelPage({super.key});

  @override
  State<AdminPanelPage> createState() => _AdminPanelPageState();
}

class _AdminPanelPageState extends State<AdminPanelPage> {
  void navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text("admin_panel_title".tr()),
        centerTitle: true,
        backgroundColor: Colors.white10,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            buildAdminCard(
              icon: Icons.place,
              label: 'gares'.tr(),
              color: Colors.blue.shade400,
              onTap: () => navigateTo(GareListPage()),
            ),
            buildAdminCard(
              icon: Icons.admin_panel_settings,
              label: 'admin'.tr(),
              color: const Color.fromARGB(255, 206, 201, 201),
              onTap: () => navigateTo(AdminListPage()),
            ),
            buildAdminCard(
              icon: Icons.timeline,
              label: 'lignes'.tr(),
              color: const Color.fromARGB(255, 206, 201, 201),
              onTap: () => navigateTo(RailLinesScreen()),
            ),
            buildAdminCard(
              icon: Icons.location_on,
              label: 'stations'.tr(),
              color: Colors.blue.shade400,
              onTap: () => navigateTo(AddCoordinatesPage()),
            ),
            buildAdminCard(
              icon: Icons.feedback,
              label: 'feedback'.tr(),
              color: Colors.blueAccent,
              onTap: () => navigateTo(FeedbackAdminScreen()),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildAdminCard({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 50, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
