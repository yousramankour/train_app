import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
import 'historique_page.dart';
import 'apropos_page.dart';
import 'theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? _image;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.gallery);
    if (img != null) setState(() => _image = File(img.path));
  }

  Future<void> _takePhoto() async {
    final picker = ImagePicker();
    final XFile? img = await picker.pickImage(source: ImageSource.camera);
    if (img != null) setState(() => _image = File(img.path));
  }

  void _openEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text("profile".tr()),
        backgroundColor:
            isDark
                ? const Color.fromARGB(255, 0, 2, 116)
                : const Color(0xFF2196F3),
      ),
      body: SingleChildScrollView(
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
                                          _takePhoto();
                                          Navigator.pop(context);
                                        },
                                        child: Text("take_photo".tr()),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          _pickImage();
                                          Navigator.pop(context);
                                        },
                                        child: Text("choose_gallery".tr()),
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
                              _image != null
                                  ? DecorationImage(
                                    image: FileImage(_image!),
                                    fit: BoxFit.cover,
                                  )
                                  : null,
                          color: isDark ? Colors.black : Colors.white,
                        ),
                        child:
                            _image == null
                                ? const Icon(
                                  Icons.camera_alt,
                                  size: 40,
                                  color: Color(0xFF2196F3),
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
                            "John Doe",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 5),
                          Text(
                            "john.doe@example.com",
                            style: Theme.of(context).textTheme.bodyMedium,
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
              onPressed: _openEditPage,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isDark
                        ? const Color.fromARGB(255, 0, 2, 116)
                        : const Color(0xFF2196F3),
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
            _buildOption(Icons.language, "language".tr(), _changeLanguage),
            _buildOption(Icons.dark_mode, "dark_mode".tr(), () {
              Provider.of<ThemeProvider>(context, listen: false).toggleTheme();
            }),
            _buildOption(Icons.history, "historique".tr(), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoriquePage()),
              );
            }),
            _buildOption(Icons.info_outline, "a_propos".tr(), () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AProposPage()),
              );
            }),
            const Divider(height: 40),
            _buildOption(Icons.logout, "logout".tr(), () {
              // TODO: Ajouter déconnexion Firebase
            }, iconColor: Colors.red),
          ],
        ),
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text("language".tr()),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: () => context.setLocale(const Locale('en')),
                  child: const Text("English"),
                ),
                TextButton(
                  onPressed: () => context.setLocale(const Locale('fr')),
                  child: const Text("Français"),
                ),
                TextButton(
                  onPressed: () => context.setLocale(const Locale('ar')),
                  child: const Text("العربية"),
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
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: Icon(
          icon,
          color:
              iconColor ??
              (isDark
                  ? const Color.fromARGB(255, 0, 2, 116)
                  : const Color(0xFF2196F3)),
        ),
        title: Text(label),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}

class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Scaffold(
      appBar: AppBar(
        title: Text("edit_info".tr()),
        backgroundColor:
            isDark
                ? const Color.fromARGB(255, 0, 2, 116)
                : const Color(0xFF2196F3),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(decoration: InputDecoration(labelText: 'name'.tr())),
            TextField(decoration: InputDecoration(labelText: 'email'.tr())),
            TextField(decoration: InputDecoration(labelText: 'age'.tr())),
            TextField(decoration: InputDecoration(labelText: 'gender'.tr())),
            TextField(decoration: InputDecoration(labelText: 'job'.tr())),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: null,
              style: ButtonStyle(
                backgroundColor: MaterialStatePropertyAll(
                  isDark
                      ? const Color.fromARGB(255, 0, 2, 116)
                      : const Color(0xFF2196F3),
                ),
              ),
              child: Text(
                "save".tr(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
