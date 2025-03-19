import 'package:flutter/material.dart';

class ParametresPage extends StatefulWidget {
  final VoidCallback onBack; // ✅ Ajout du paramètre

  const ParametresPage({super.key, required this.onBack});

  @override
  State<ParametresPage> createState() => _ParametresPageState();
}

class _ParametresPageState extends State<ParametresPage> {
  bool _notificationsEnabled = true;
  bool _darkModeEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      // ✅ Remplacé Scaffold par Drawer
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 172, 219, 241),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Paramètres",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: widget.onBack, // ✅ Appelle la fonction de retour
                ),
              ],
            ),
          ),
          ListTile(
            leading: Icon(Icons.notifications, color: Colors.blue),
            title: Text("Notifications"),
            trailing: Switch(
              value: _notificationsEnabled,
              onChanged: (bool value) {
                setState(() {
                  _notificationsEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.dark_mode, color: Colors.blue),
            title: Text("Thème sombre"),
            trailing: Switch(
              value: _darkModeEnabled,
              onChanged: (bool value) {
                setState(() {
                  _darkModeEnabled = value;
                });
              },
            ),
          ),
          ListTile(
            leading: Icon(Icons.language, color: Colors.blue),
            title: Text("Langue et région"),
            onTap: () {},
          ),
          ListTile(
            leading: Icon(Icons.info, color: Colors.blue),
            title: Text("À propos"),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
