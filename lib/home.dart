import 'package:flutter/material.dart';
import 'package:appmob/chat.dart';
import 'package:appmob/stat.dart';
import 'package:appmob/prfil.dart';
import 'package:appmob/parametere.dart'; // ✅ Importation de la page Paramètres

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String activeDrawer = "menu"; // ✅ Gère l'affichage du menu actuel

  // ✅ Fonction pour afficher le menu principal
  void showMainMenu() {
    setState(() {
      activeDrawer = "menu";
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  // ✅ Fonction pour afficher les paramètres
  void showSettingsMenu() {
    setState(() {
      activeDrawer = "settings";
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  // ✅ Fonction pour afficher le profil
  void showProfileMenu() {
    setState(() {
      activeDrawer = "profile";
    });
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,

      // ✅ Affichage conditionnel du Drawer
      drawer: Drawer(
        child:
            activeDrawer == "settings"
                ? ParametresPage(
                  onBack: showMainMenu,
                ) // ✅ Affiche les paramètres
                : activeDrawer == "profile"
                ? ProfilPage(onBack: showMainMenu) // ✅ Affiche le profil
                : Column(
                  // ✅ Menu principal
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    DrawerHeader(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 172, 219, 241),
                      ),
                      child: Center(
                        child: Text(
                          "Menu",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    ListTile(
                      leading: Icon(Icons.person, color: Colors.blue),
                      title: Text("My Profile"),
                      onTap: showProfileMenu,
                    ),

                    ListTile(
                      leading: Icon(Icons.bar_chart, color: Colors.blue),
                      title: Text("Statistics"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => StatistiquePage(),
                          ),
                        );
                      },
                    ),

                    ListTile(
                      leading: Icon(Icons.chat, color: Colors.blue),
                      title: Text("Chat"),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => ChatScreen()),
                        );
                      },
                    ),

                    Divider(),

                    ListTile(
                      leading: Icon(Icons.settings, color: Colors.grey),
                      title: Text("Settings"),
                      onTap: showSettingsMenu,
                    ),

                    ListTile(
                      leading: Icon(Icons.logout, color: Colors.red),
                      title: Text("Logout"),
                      onTap: () {},
                    ),
                  ],
                ),
      ),

      // ✅ AppBar avec bouton pour ouvrir le menu
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () {
                _scaffoldKey.currentState?.openDrawer();
              },
            );
          },
        ),
      ),

      // ✅ Corps de la page
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 250,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 172, 219, 241),
                    Color(0xFFFFFFFF),
                  ],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const SizedBox(height: 20),
                    const Text(
                      "Welcome back !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      "Where do you want to go",
                      style: TextStyle(fontSize: 17, color: Colors.black),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.bottomLeft,
                      child: Image.asset(
                        "assets/amico.png",
                        width: 250,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
