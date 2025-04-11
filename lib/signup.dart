import 'package:appmob/login_page.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

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
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "create_account".tr(),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                buildTextField(
                  "name_surname".tr(),
                  nameController,
                  isDark: isDark,
                ),
                buildTextField(
                  "age".tr(),
                  ageController,
                  keyboardType: TextInputType.number,
                  isDark: isDark,
                ),
                buildDropdownField("sex".tr(), isDark),
                buildTextField("job".tr(), jobController, isDark: isDark),
                buildTextField(
                  "email".tr(),
                  emailController,
                  keyboardType: TextInputType.emailAddress,
                  isDark: isDark,
                ),
                buildTextField(
                  "password".tr(),
                  passwordController,
                  obscureText: true,
                  isDark: isDark,
                ),
                buildTextField(
                  "confirm_password".tr(),
                  confirmPasswordController,
                  obscureText: true,
                  isDark: isDark,
                ),
                SizedBox(height: 20),
                Center(
                  child: SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            isDark
                                ? Colors.blueGrey
                                : Color.fromARGB(255, 172, 219, 241),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () {
                        // TODO: Ajouter logique de création de compte
                      },
                      child: Text(
                        "sign_up".tr(),
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Divider(color: isDark ? Colors.grey : Colors.black),
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "already_have_account".tr(),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black,
                        ),
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
                          "sign_in".tr(),
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
    required bool isDark,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
        ),
        SizedBox(height: 15),
      ],
    );
  }

  Widget buildDropdownField(String label, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isDark ? Colors.white : Colors.black,
            fontSize: 16,
          ),
        ),
        DropdownButtonFormField<String>(
          value: selectedGender,
          dropdownColor: isDark ? Colors.grey[900] : Colors.white,
          items: [
            DropdownMenuItem(value: "Homme", child: Text("man".tr())),
            DropdownMenuItem(value: "Femme", child: Text("woman".tr())),
          ],
          onChanged: (value) {
            setState(() {
              selectedGender = value;
            });
          },
          decoration: InputDecoration(
            border: UnderlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 10),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
          ),
          style: TextStyle(color: isDark ? Colors.white : Colors.black),
        ),
        SizedBox(height: 15),
      ],
    );
  }
}
