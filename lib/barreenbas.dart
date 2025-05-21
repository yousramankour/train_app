import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';
import 'home.dart';
import 'statistiques.dart';
import 'notification.dart';
import 'chat.dart';
import 'profile.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int selectedIndex;

  const CustomBottomNavBar({super.key, required this.selectedIndex});

  Color get primaryColor => const Color(0xFF008ECC);

  @override
  Widget build(BuildContext context) {
    Widget buildNavItem({
      required IconData icon,
      required String label,
      required Function() onTap,
      required bool isActive,
    }) {
      final color = isActive ? Colors.black : Colors.white;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(icon, color: color, size: 24),
            onPressed: onTap,
          ),
          const SizedBox(height: 2),
          Text(label, style: TextStyle(color: color, fontSize: 9)),
        ],
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(2)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          buildNavItem(
            icon: LucideIcons.map,
            label: "Carte".tr(),
            onTap: () {
              if (selectedIndex != 0) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => HomeScreen()),
                );
              }
            },
            isActive: selectedIndex == 0,
          ),
          buildNavItem(
            icon: LucideIcons.barChart,
            label: "Statistique".tr(),
            onTap: () {
              if (selectedIndex != 1) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => StatistiqueGareScreen()),
                );
              }
            },
            isActive: selectedIndex == 1,
          ),
          buildNavItem(
            icon: LucideIcons.bell,
            label: "Notifications".tr(),
            onTap: () {
              if (selectedIndex != 2) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => NotificationScreen()),
                );
              }
            },
            isActive: selectedIndex == 2,
          ),
          buildNavItem(
            icon: LucideIcons.messageCircle,
            label: "Messagerie".tr(),
            onTap: () {
              final user = FirebaseAuth.instance.currentUser;
              if (user != null && selectedIndex != 3) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => ChatScreend()),
                );
              }
            },
            isActive: selectedIndex == 3,
          ),
          buildNavItem(
            icon: LucideIcons.user,
            label: "Profil".tr(),
            onTap: () {
              if (selectedIndex != 4) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const ProfileScreen()),
                );
              }
            },
            isActive: selectedIndex == 4,
          ),
        ],
      ),
    );
  }
}
