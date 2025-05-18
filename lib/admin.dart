import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class AdminListPage extends StatefulWidget {
  const AdminListPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AdminListPageState createState() => _AdminListPageState();
}

class _AdminListPageState extends State<AdminListPage> {
  final TextEditingController _emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Liste des Admins".tr(),
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    decoration: InputDecoration(
                      labelText: "Email utilisateur".tr(),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _addAdmin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  child: Text("Ajouter".tr()),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection('users')
                      .where('isAdmin', isEqualTo: true)
                      .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Center(child: Text("Aucun admin trouvé".tr()));
                }

                var admins = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: admins.length,
                  itemBuilder: (context, index) {
                    var doc = admins[index];
                    var email = doc['email'] ?? "Email inconnu".tr();

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: ListTile(
                        leading: const Icon(
                          Icons.admin_panel_settings,
                          color: Colors.blue,
                        ),
                        title: Text(email),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.blue),
                          onPressed: () => _removeAdmin(doc.id, email),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _addAdmin() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) return;

    // Rechercher l'utilisateur par email
    final query =
        await FirebaseFirestore.instance
            .collection('users')
            .where('email', isEqualTo: email)
            .get();

    if (query.docs.isNotEmpty) {
      final userId = query.docs.first.id;
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isAdmin': true,
      });
      _emailController.clear();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(tr('Admin ajouté avec succès :', args: [email])),
        ),
      );
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Utilisateur introuvable avec cet email.".tr())),
      );
    }
  }

  void _removeAdmin(String userId, String email) async {
    await FirebaseFirestore.instance.collection('users').doc(userId).update({
      'isAdmin': false,
    });
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr('Admin retiré :', args: [email]))),
    );
  }
}
