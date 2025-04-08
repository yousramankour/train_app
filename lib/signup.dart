import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // Import pour easy_localization
import 'login_page.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  String? selectedGender;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController jobController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "create_account".tr(), // Traduction de "Create Account"
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildTextField("name_surname".tr(), nameController),
                buildTextField(
                  "age".tr(),
                  ageController,
                  keyboardType: TextInputType.number,
                ),
                buildDropdownField("sex".tr()),
                buildTextField("job".tr(), jobController),
                buildTextField(
                  "email".tr(),
                  emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                buildTextField(
                  "password".tr(),
                  passwordController,
                  obscureText: true,
                ),
                buildTextField(
                  "confirm_password".tr(),
                  confirmPasswordController,
                  obscureText: true,
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color.fromARGB(255, 172, 219, 241),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {},
                      child: Text(
                        "sign_up".tr(), // Traduction de "SIGN UP"
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "already_have_account"
                            .tr(), // Traduction de "Already have an account?"
                        style: TextStyle(color: Colors.black),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => LoginPage(),
                            ),
                          );
                        },
                        child: Text(
                          "sign_in".tr(), // Traduction de "SIGN IN"
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
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
    TextEditingController controller, {
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDropdownField(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.black, fontSize: 16)),
        DropdownButtonFormField<String>(
          value: selectedGender,
          items: [
            DropdownMenuItem(value: "Homme", child: Text("Homme")),
            DropdownMenuItem(value: "Femme", child: Text("Femme")),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
