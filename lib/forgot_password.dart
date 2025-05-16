import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:easy_localization/easy_localization.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController emailController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String message = '';
  bool isLoading = false;

  Future<void> resetPassword() async {
    final email = emailController.text.trim();
    setState(() {
      message = '';
    });

    if (email.isEmpty) {
      setState(() {
        message = 'forgot.enter_email'.tr();
      });
      return;
    }

    try {
      setState(() => isLoading = true);

      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isEmpty) {
        setState(() {
          message = 'forgot.no_account'.tr();
        });
        return;
      }

      await _auth.sendPasswordResetEmail(email: email);
      setState(() {
        message = 'forgot.email_sent'.tr();
      });
    } on FirebaseAuthException catch (e) {
      setState(() {
        message = e.message ?? 'forgot.error_occurred'.tr();
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;

    return Scaffold(
      appBar: AppBar(title: Text('forgot.title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'forgot.email_label'.tr()),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                  onPressed: resetPassword,
                  child: Text('forgot.send_button'.tr()),
                ),
            const SizedBox(height: 20),
            if (message.isNotEmpty)
              Text(message, style: TextStyle(color: textColor)),
          ],
        ),
      ),
    );
  }
}
