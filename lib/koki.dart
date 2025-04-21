/*import 'package:flutter/material.dart';

class loginepage extends StatefulWidget {
  const loginepage({super.key});

  @override
  State<loginepage> createState() => _loginepageState();
}

class _loginepageState extends State<loginepage> {
  @override
   final textColor = isDark ? Colors.white : Colors.black;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              children: [
                Container(
                  height: 180,
                  child: Image.asset('assets/logoapp.png'),
                ),
                Text(
                  'My Train',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF008ECC),
                  ),
                ),
              ],
            ),
            SizedBox(height: 24),
            Center(
                    child: Text(
                      'sign_in'.tr(),
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                  ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Material(
                elevation: 5,
                color: Color(0xFF008ECC),
                borderRadius: BorderRadius.circular(10),
                child: MaterialButton(
                  onPressed: () {},
                  minWidth: 200,
                  height: 20,
                  child: Text(
                    'sign in ',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*/
