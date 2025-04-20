import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

import 'edit_profile.dart';
import 'historique_page.dart';
import 'apropos_page.dart';
import 'theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = FirebaseAuth.instance.currentUser;
  final firestore = FirebaseFirestore.instance;
  final storage = FirebaseStorage.instance;

  String nom = '';
  String email = '';
  String age = '';
  String sexe = '';
  String metier = '';
  String profileImageUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  // Fonction pour charger les informations de profil
  Future<void> _loadUserProfile() async {
    final doc = await firestore.collection('users').doc(user!.uid).get();
    final data = doc.data();
    if (data != null) {
      nom = data['nom'] ?? '';
      email = data['email'] ?? '';
      age = data['age']?.toString() ?? '';
      sexe = data['sexe'] ?? '';
      metier = data['metier'] ?? '';
    }

    try {
      // Essayer de récupérer l'URL de l'image de profil
      profileImageUrl =
          await storage
              .ref('profile_pictures/${user!.uid}.jpg')
              .getDownloadURL();
    } catch (_) {
      // Si aucune image n'est trouvée
      profileImageUrl = '';
    }

    setState(() {
      isLoading = false;
    });
  }

  // Fonction pour choisir et télécharger une image depuis la galerie ou la caméra
  Future<void> _pickAndUploadImage(ImageSource source) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: source, imageQuality: 50);
    if (image != null) {
      final ref = storage.ref('profile_pictures/${user!.uid}.jpg');
      await ref.putFile(
        File(image.path),
      ); // Télécharger l'image sur Firebase Storage
      profileImageUrl = await ref.getDownloadURL(); // Obtenir l'URL de l'image
      setState(
        () {}, // Recharger l'interface utilisateur pour afficher l'image mise à jour
      );
    }
  }

  // Fonction pour déconnecter l'utilisateur
  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    SystemNavigator.pop(); // Quitter l'application
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("profile".tr()), // Titre de l'écran, traduit
        backgroundColor: const Color(0xFF2196F3),
      ),
      body:
          isLoading
              ? const Center(
                child: CircularProgressIndicator(),
              ) // Si les données sont en cours de chargement
              : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 6,
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Row(
                          children: [
                            GestureDetector(
                              onTap:
                                  () => showDialog(
                                    context: context,
                                    builder:
                                        (_) => AlertDialog(
                                          title: Text("change_photo".tr()),
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              TextButton(
                                                onPressed: () {
                                                  _pickAndUploadImage(
                                                    ImageSource
                                                        .camera, // Prendre une photo avec la caméra
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: Text("take_photo".tr()),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  _pickAndUploadImage(
                                                    ImageSource
                                                        .gallery, // Choisir une photo depuis la galerie
                                                  );
                                                  Navigator.pop(context);
                                                },
                                                child: Text(
                                                  "choose_gallery".tr(),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                  ),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                                width: 100,
                                height: 100,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  image:
                                      profileImageUrl.isNotEmpty
                                          ? DecorationImage(
                                            image: NetworkImage(
                                              profileImageUrl,
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                          : null,
                                  color: Colors.grey[300],
                                ),
                                child:
                                    profileImageUrl.isEmpty
                                        ? CircleAvatar(
                                          radius: 50,
                                          backgroundColor: Colors.blue,
                                          child: Text(
                                            nom.isNotEmpty
                                                ? nom[0]
                                                : 'U', // Initiales de l'utilisateur
                                            style: const TextStyle(
                                              fontSize: 40,
                                              color: Colors.white,
                                            ),
                                          ),
                                        )
                                        : null,
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    nom,
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    email,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const EditProfilePage(),
                          ),
                        );
                        _loadUserProfile(); // Recharger le profil après modification
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2196F3),
                        minimumSize: const Size.fromHeight(45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: Text(
                        "edit_info".tr(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // 🌐 Nouveau bouton langue
                    _buildOption(Icons.language, "language".tr(), () {
                      showDialog(
                        context: context,
                        builder:
                            (_) => AlertDialog(
                              title: Text("language".tr()),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      context.setLocale(const Locale('en'));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("English"),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      context.setLocale(const Locale('fr'));
                                      Navigator.pop(context);
                                    },
                                    child: const Text("Français"),
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
                    }),

                    // 🌙 Mode sombre
                    ListTile(
                      leading: const Icon(
                        Icons.dark_mode,
                        color: Color(0xFF2196F3),
                      ),
                      title: Text("dark_mode".tr()),
                      trailing: Switch(
                        value: themeProvider.isDarkMode,
                        onChanged: (value) => themeProvider.toggleTheme(),
                      ),
                    ),

                    // 📜 Historique
                    _buildOption(Icons.history, "history".tr(), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoriquePage(),
                        ),
                      );
                    }),

                    // ℹ️ À propos
                    _buildOption(Icons.info_outline, "about".tr(), () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const AProposPage()),
                      );
                    }),

                    const Divider(height: 40),

                    // 🚪 Déconnexion
                    _buildOption(
                      Icons.logout,
                      "logout".tr(),
                      _logout,
                      iconColor: Colors.red,
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildOption(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? iconColor,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: iconColor ?? const Color(0xFF2196F3)),
        title: Text(label),
        onTap: onTap,
      ),
    );
  }
}
