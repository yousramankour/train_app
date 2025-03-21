import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:appmob/chat.dart';
import 'package:appmob/stat.dart';
import 'package:appmob/prfil.dart';
import 'package:appmob/theme_provider.dart'; // Pour ThemeProvider

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            color: themeProvider.isDarkMode ? Colors.white : Colors.black,
            size: 30,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),

      drawer: Drawer(
        backgroundColor: themeProvider.isDarkMode ? Colors.black : Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color:
                    themeProvider.isDarkMode
                        ? Colors.blue.shade900
                        : Colors.blue.shade300,
              ),
              child: Center(
                child: Text(
                  "Menu",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color:
                        themeProvider.isDarkMode ? Colors.white : Colors.black,
                  ),
                ),
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.person,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "My Profile",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) => ProfilPage(
                          onBack: () {
                            Navigator.pop(context);
                          },
                        ),
                  ),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.bar_chart,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "Statistics",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatistiquePage()),
                );
              },
            ),

            ListTile(
              leading: Icon(
                Icons.chat,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "Chat",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ChatScreen()),
                );
              },
            ),

            const Divider(),

            // ✅ SWITCH POUR LE MODE SOMBRE
            ListTile(
              leading: Icon(
                Icons.dark_mode,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "Thème sombre",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              trailing: Switch(
                value: themeProvider.isDarkMode,
                onChanged: (bool value) {
                  themeProvider.toggleTheme();
                },
              ),
            ),

            ListTile(
              leading: Icon(
                Icons.language,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "Langue et région",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(
                Icons.info,
                color: themeProvider.isDarkMode ? Colors.white : Colors.blue,
              ),
              title: Text(
                "À propos",
                style: TextStyle(
                  color: themeProvider.isDarkMode ? Colors.white : Colors.black,
                ),
              ),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),

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
                  colors:
                      themeProvider.isDarkMode
                          ? [
                            Colors.blue.shade900,
                            Colors.black,
                          ] // Bleu foncé → Noir
                          : [
                            Colors.blue.shade300,
                            Colors.white,
                          ], // Bleu clair → Blanc
                ),
                borderRadius: const BorderRadius.only(
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
                    Text(
                      "Welcome back !",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white
                                : Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      "Where do you want to go",
                      style: TextStyle(
                        fontSize: 17,
                        color:
                            themeProvider.isDarkMode
                                ? Colors.white70
                                : Colors.black,
                      ),
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
