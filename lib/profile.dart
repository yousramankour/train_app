import 'package:appmob/adminepage.dart';

import 'package:appmob/edit_profile.dart';
import 'package:appmob/enquette_satisfaction.dart';
import 'package:appmob/historique_page.dart';
import 'package:appmob/home.dart';
import 'package:appmob/login_page.dart';
import 'package:appmob/notification.dart';
import 'package:appmob/statistiques.dart';
import 'package:appmob/verschat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatelessWidget {
  final Color primaryColor = const Color(0xFF008ECC);

  const ProfileScreen({super.key});

  Widget _buildBottomButton(
    IconData icon,
    String label,
    Function() onPressed, {
    bool isActive = false,
  }) {
    final color = isActive ? Colors.black : Colors.white;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color, size: 24),
          onPressed: onPressed,
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(color: color, fontSize: 9)),
      ],
    );
  }

  Widget _buildModernCard(
    IconData icon,
    String title, {
    Color iconColor = const Color(0xFF008ECC),
    Color textColor = Colors.black,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        margin: EdgeInsets.only(bottom: 3),
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor),
            SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si non connecté, redirige ou affiche message
      return Scaffold(
        body: Center(child: Text("Veuillez vous connecter.".tr())),
      );
    }
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('users')
              .doc(user.uid)
              .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Scaffold(
            body: Center(child: Text("Profil introuvable.".tr())),
          );
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Utilisateur';
        final email = data['email'] ?? '';
        final isAdmin = data['isAdmin'] ?? false;
        return Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Column(
              children: [
                SizedBox(height: 40),
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.shade300, width: 2),
                  ),
                  child: Icon(
                    Icons.person,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
                SizedBox(height: 15),
                Text(
                  name,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(email, style: TextStyle(color: Colors.grey)),
                SizedBox(height: 30),

                Expanded(
                  child: ListView(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 10),
                    children: [
                      _buildModernCard(
                        LucideIcons.userCog,
                        "modifier profile".tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => EditProfileScreen(),
                            ),
                          );
                        },
                      ),
                      _buildModernCard(
                        LucideIcons.history,
                        "historique".tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => TripHistoryPage(),
                            ),
                          );
                        },
                      ),
                      _buildModernCard(
                        LucideIcons.globe,
                        "languages".tr(),
                        onTap: () {
                          showDialog(
                            context: context,
                            builder:
                                (_) => AlertDialog(
                                  title: Text("Choisir la langue".tr()),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          // Change la langue
                                          context.setLocale(const Locale('en'));
                                          Navigator.pop(context);
                                        },
                                        child: Text("English".tr()),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.setLocale(const Locale('fr'));
                                          Navigator.pop(context);
                                        },
                                        child: Text("Français"),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          context.setLocale(const Locale('ar'));
                                          Navigator.pop(context);
                                        },
                                        child: const Text("العربية"),
                                      ),
                                    ],
                                  ),
                                ),
                          );
                        },
                      ),
                      _buildModernCard(
                        LucideIcons.info,
                        "feedback".tr(),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => SatisfactionSurveyPage(),
                            ),
                          );
                        },
                      ),
                      if (isAdmin) // Affichage conditionnel
                        _buildModernCard(
                          LucideIcons.userCog,
                          "Ajouts & Création".tr(),
                          onTap: () {
                            // Naviguer vers la page de gestion des admins
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AdminPanelPage(),
                              ),
                            );
                          },
                        ),

                      _buildModernCard(
                        LucideIcons.logOut,
                        "Se déconnecter".tr(),
                        iconColor: Colors.blue,
                        textColor: Colors.blue,
                        onTap: () async {
                          // Déconnexion de Firebase
                          await FirebaseAuth.instance.signOut();

                          // Redirection vers la page de connexion
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginPage(),
                              ), // Assure-toi que LoginPage est bien ta page de connexion
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Color(0xFF008ECC),
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
            padding: EdgeInsets.symmetric(vertical: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomButton(LucideIcons.map, "Carte".tr(), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }),

                _buildBottomButton(LucideIcons.bell, "Notifications".tr(), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                }),
                _buildBottomButton(
                  LucideIcons.messageCircle,
                  "Messagerie".tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LinesListScreen(),
                      ),
                    );
                  },
                ),
                _buildBottomButton(
                  LucideIcons.barChart,
                  "Statistique".tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatistiqueGareScreen(),
                      ),
                    );
                  },
                ),
                _buildBottomButton(LucideIcons.user, "Profil".tr(), () {
                  // Ne rien faire
                }, isActive: true),
              ],
            ),
          ),
        );
      },
    );
  }
}
