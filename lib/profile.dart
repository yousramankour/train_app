import 'package:appmob/affigar.dart';
import 'package:appmob/apropos_page.dart';
import 'package:appmob/edit_profile.dart';
import 'package:appmob/historique.dart';
import 'package:appmob/home.dart';
import 'package:appmob/messageri.dart';
import 'package:appmob/notification.dart';
import 'package:appmob/statistique.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class ProfileScreen extends StatelessWidget {
  final Color primaryColor = const Color(0xFF008ECC);

  Widget _buildBottomButton(
    IconData icon,
    String label,
    Function() onPressed, {
    bool isActive = false,
  }) {
    return Stack(
      clipBehavior: Clip.none, // Autorise le shadow à dépasser
      children: [
        if (isActive)
          Positioned(
            top: -6, // Positionne l’ombre un peu au-dessus
            left: 0,
            right: 0,
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromARGB(
                      255,
                      35,
                      109,
                      236,
                    ).withOpacity(0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(icon, color: Colors.white, size: 24),
              onPressed: onPressed,
            ),
            SizedBox(height: 2),
            Text(label, style: TextStyle(color: Colors.white, fontSize: 9)),
          ],
        ),
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
        margin: EdgeInsets.only(bottom: 16),
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
                  fontSize: 16,
                  color: textColor,
                  fontWeight: FontWeight.w500,
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
      return Scaffold(body: Center(child: Text('Veuillez vous connecter.')));
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
          return Scaffold(body: Center(child: Text('Profil introuvable.')));
        }
        final data = snapshot.data!.data() as Map<String, dynamic>;
        final name = data['name'] ?? 'Utilisateur';
        final email = data['email'] ?? '';
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
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    children: [
                      _buildModernCard(
                        LucideIcons.userCog,
                        "modifier profile",
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
                        "historique",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TripHistoryPage()),
                          );
                        },
                      ),
                      _buildModernCard(
                        LucideIcons.globe,
                        "languages",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => GareListPage()),
                          );
                        },
                      ),
                      _buildModernCard(
                        LucideIcons.info,
                        "a propos",
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => AProposPage()),
                          );
                        },
                      ),

                      _buildModernCard(
                        LucideIcons.logOut,
                        "Se déconnecter",
                        iconColor: Colors.blue,
                        textColor: Colors.blue,
                        onTap: () {
                          // Action de déconnexion ici
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
              color: primaryColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(2)),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildBottomButton(LucideIcons.map, "Carte", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => HomeScreen()),
                  );
                }),
                _buildBottomButton(LucideIcons.barChart, "Statistique", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => StatsScreen()),
                  );
                }),
                _buildBottomButton(LucideIcons.bell, "Notifications", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationScreen(),
                    ),
                  );
                }),
                _buildBottomButton(LucideIcons.messageCircle, "Messagerie", () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ChatScreen()),
                  );
                }),
                _buildBottomButton(LucideIcons.user, "Profil", () {
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
