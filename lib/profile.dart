import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'historique_page.dart';
import 'apropos_page.dart';
import 'settings_page.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';
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

  void _openSettings() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SettingsPage()),
    );
  }

  void _openEditPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const EditProfilePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("profile".tr()), // Translated text
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _openSettings,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Card(
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
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
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _image != null ? FileImage(_image!) : null,
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
                const SizedBox(height: 20),
                _buildInfoRow("name".tr(), "John Doe"),
                _buildInfoRow("email".tr(), "john.doe@example.com"),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _openEditPage,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2196F3),
                    minimumSize: const Size.fromHeight(40),
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
                const Divider(),
                ListTile(
                  title: Text("dark_mode".tr()), // Traduction du texte
                  trailing: Switch(
                    value: context.watch<ThemeProvider>().isDarkMode,
                    onChanged: (value) {
                      Provider.of<ThemeProvider>(
                        context,
                        listen: false,
                      ).toggleTheme();
                    },
                  ),
                  onTap: () {
                    // Alternativement, tu peux aussi utiliser cette action pour changer le thème
                    Provider.of<ThemeProvider>(
                      context,
                      listen: false,
                    ).toggleTheme();
                  },
                ),

                ListTile(
                  leading: const Icon(Icons.language, color: Color(0xFF2196F3)),
                  title: Text("language".tr()),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder:
                          (_) => AlertDialog(
                            title: Text("language".tr()),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                TextButton(
                                  onPressed:
                                      () =>
                                          context.setLocale(const Locale('en')),
                                  child: const Text("English"),
                                ),
                                TextButton(
                                  onPressed:
                                      () =>
                                          context.setLocale(const Locale('fr')),
                                  child: const Text("Français"),
                                ),
                                TextButton(
                                  onPressed:
                                      () =>
                                          context.setLocale(const Locale('ar')),
                                  child: const Text("العربية"),
                                ),
                              ],
                            ),
                          ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: Text("logout".tr()),
                  onTap: () {
                    /* TODO */
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              "$label :",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(flex: 3, child: Text(value)),
        ],
      ),
    );
  }
}

// Page d’édition
class EditProfilePage extends StatelessWidget {
  const EditProfilePage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text("edit_info".tr()), // Translated text
      backgroundColor: const Color(0xFF2196F3),
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
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: null,
            style: ButtonStyle(
              backgroundColor: MaterialStatePropertyAll(Color(0xFF2196F3)),
            ),
            child: Text("save".tr(), style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    ),
  );
}
