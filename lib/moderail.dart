import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';

class EditLineScreen extends StatefulWidget {
  final String docId;
  final String initialName;
  final List<String> initialGares;

  const EditLineScreen({
    super.key,
    required this.docId,
    required this.initialName,
    required this.initialGares,
  });

  @override
  State<EditLineScreen> createState() => _EditLineScreenState();
}

class _EditLineScreenState extends State<EditLineScreen> {
  late TextEditingController _nameController;
  List<TextEditingController> _gareControllers = [];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName);
    _gareControllers =
        widget.initialGares
            .map((gare) => TextEditingController(text: gare))
            .toList();
  }

  @override
  void dispose() {
    _nameController.dispose();
    for (var controller in _gareControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _saveChanges() async {
    String newName = _nameController.text.trim();
    List<String> newGares = _gareControllers.map((c) => c.text.trim()).toList();

    if (newName.isEmpty || newGares.any((gare) => gare.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez remplir tous les champs.'.tr())),
      );
      return;
    }

    await FirebaseFirestore.instance.collection('rail').doc(widget.docId).set({
      'gares': newGares,
    });

    if (newName != widget.initialName) {
      // Renommer le document si le nom a changé
      await FirebaseFirestore.instance
          .collection('rail')
          .doc(widget.docId)
          .delete();
      await FirebaseFirestore.instance.collection('rail').doc(newName).set({
        'gares': newGares,
      });
    }
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ligne mise à jour avec succès".tr())),
      );
    }
  }

  void _addGare() {
    setState(() {
      _gareControllers.add(TextEditingController());
    });
  }

  void _removeGare(int index) {
    setState(() {
      _gareControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Modifier la Ligne".tr(),
          style: TextStyle(color: Colors.black),
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
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nom de la ligne'.tr(),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ListView.separated(
                separatorBuilder:
                    (context, index) =>
                        const SizedBox(height: 15), // espace entre les gares
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _gareControllers.length,
                itemBuilder: (context, index) {
                  return Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _gareControllers[index],
                          decoration: InputDecoration(
                            labelText: 'Gare ${index + 1}',
                            border: const OutlineInputBorder(),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.blue),
                        onPressed: () => _removeGare(index),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 25),
              ElevatedButton.icon(
                onPressed: _addGare,
                icon: const Icon(Icons.add, color: Colors.white),
                label: Text(
                  "Ajouter une gare".tr(),
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // bouton noir
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _saveChanges,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue, // bouton noir
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(
                  "Enregistrer".tr(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
