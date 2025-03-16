import 'package:flutter/material.dart';
import 'package:appmob/chat.dart'; // Assurez-vous que ce fichier existe

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      drawer: Drawer(
        child: Column(
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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.bar_chart, color: Colors.blue),
              title: Text("Statistics"),
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.chat, color: Colors.blue),
              title: Text("Chat"),
              onTap: () {
                Navigator.pop(context); // ✅ Ferme le Drawer avant de naviguer
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
              onTap: () {},
            ),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text("Logout"),
              onTap: () {},
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) {
            return IconButton(
              icon: Icon(Icons.menu, color: Colors.black, size: 30),
              onPressed: () {
                Scaffold.of(
                  context,
                ).openDrawer(); // ✅ Ouvre correctement le menu
              },
            );
          },
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
