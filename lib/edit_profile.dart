import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart'; // ajouté

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _jobController = TextEditingController();
  final _sexController = TextEditingController();
  String email = "";
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (user != null) {
      final doc =
          await FirebaseFirestore.instance
              .collection('users')
              .doc(user!.uid)
              .get();
      if (doc.exists) {
        setState(() {
          email = user!.email ?? '';
          _nameController.text = doc['name'] ?? '';
          _ageController.text = doc['age']?.toString() ?? '';
          _jobController.text = doc['job'] ?? '';
          _sexController.text = doc['sex'] ?? '';
        });
      }
    }
  }

  void _saveChanges() async {
    final name = _nameController.text.trim();
    final age = _ageController.text.trim();
    final job = _jobController.text.trim();
    final sex = _sexController.text.trim();
    if (name.isEmpty || age.isEmpty || job.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('fill_all_fields'.tr())));
      return;
    }

    await FirebaseFirestore.instance.collection('users').doc(user!.uid).set({
      'name': name,
      'age': int.tryParse(age),
      'job': job,
      'sex': sex,
    }, SetOptions(merge: true));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('profile_updated'.tr())));
    }
  }

  void _changePassword() async {
    if (user != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user!.email!);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('reset_link_sent'.tr())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'edit_profile'.tr(),
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.black),
        elevation: 0,
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildReadOnlyField('email'.tr(), email),
              const SizedBox(height: 20),
              _buildEditableField('name'.tr(), _nameController),
              const SizedBox(height: 20),
              _buildEditableField(
                'age'.tr(),
                _ageController,
                type: TextInputType.number,
              ),
              const SizedBox(height: 20),
              _buildEditableField('job'.tr(), _jobController),
              const SizedBox(height: 20),
              _buildEditableField('gender'.tr(), _sexController),
              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  'save'.tr(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              OutlinedButton.icon(
                onPressed: _changePassword,
                icon: const Icon(Icons.lock_reset, color: Colors.blue),
                label: Text(
                  'change_password'.tr(),
                  style: const TextStyle(color: Colors.blue),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.blue),
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType type = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: type,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return TextField(
      controller: TextEditingController(text: value),
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        fillColor: Colors.grey[100],
        filled: true,
      ),
    );
  }
}
