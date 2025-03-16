import 'package:flutter/material.dart';

class SignUpPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Top gradient
                Container(
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.white],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  "Create Account",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Times New Roman',
                  ),
                ),
                SizedBox(height: 20),

                // Form fields
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
                      buildTextField("First Name", Icons.person),
                      buildTextField("Last Name", Icons.person_outline),
                      buildTextField("Email", Icons.email),
                      buildTextField("Password", Icons.lock, obscureText: true),
                      buildTextField(
                        "Confirm Password",
                        Icons.lock,
                        obscureText: true,
                      ),
                      buildTextField(
                        "Age",
                        Icons.calendar_today,
                        keyboardType: TextInputType.number,
                      ),
                      buildDropdown("Gender", ["Male", "Female"]),
                      buildTextField("Job", Icons.work),
                    ],
                  ),
                ),

                SizedBox(height: 20),

                // Sign Up Button (sans padding autour)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade100, Colors.blue.shade300],
                    ),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 9,
                      ), // Largeur du bouton
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      backgroundColor: Colors.lightBlueAccent.shade100,
                    ),
                    onPressed: () {},
                    child: Text(
                      "SIGN UP",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Bottom Bar sans padding autour
                Container(
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.lightBlueAccent.shade100,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Already have an account?",
                          style: TextStyle(color: Colors.black),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            "SIGN IN",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextField(
    String label,
    IconData icon, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: TextField(
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
      ),
    );
  }

  Widget buildDropdown(String label, List<String> options) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 5),
      child: DropdownButtonFormField(
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          filled: true,
          fillColor: Colors.white,
        ),
        items:
            options.map((String value) {
              return DropdownMenuItem(value: value, child: Text(value));
            }).toList(),
        onChanged: (value) {},
      ),
    );
  }
}
