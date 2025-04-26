import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greenhand/firebase_options.dart';
import 'package:greenhand/login/signIn.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset('assets/icon/GreenHand_Logo.png', height: 100),
            SizedBox(height: 20),
            // App Name
            Text(
              'GreenHand',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF636B2F), // Olive green color
              ),
            ),
            SizedBox(height: 40),
            // Sign In Button
            SizedBox(
              width: 200, // Set a fixed width for the button
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => Signin()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF636B2F), // Olive green color
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ), // Adjust vertical padding only
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Sign In',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
            SizedBox(height: 20),
            // New User Button
            SizedBox(
              width: 200, // Set the same fixed width for consistency
              child: ElevatedButton(
                onPressed: () {
                  // Handle New User action
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300], // Light grey color
                  padding: EdgeInsets.symmetric(
                    vertical: 15,
                  ), // Adjust vertical padding only
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'New User',
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF636B2F), // Olive green color
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(home: LoginScreen()));
}
