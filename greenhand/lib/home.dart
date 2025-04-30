import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhand/firebase_options.dart';
import 'package:greenhand/login/login.dart';
import 'package:greenhand/rentOut/rentOutDashboard.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white, // Match background
        statusBarIconBrightness: Brightness.dark, // Black icons
        statusBarBrightness: Brightness.light, // For iOS
      ),
    );
  }

  Future<void> signOutUser() async {
    await FirebaseAuth.instance.signOut();

    // ToDo: Fix navigating after logging out
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Home",
                  style: TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 100),
                Image(
                  image: AssetImage("assets/icon/GreenHand_Logo.png"),
                  width: screenWidth * 0.4,
                ),
                SizedBox(height: 100),
                ElevatedButton(
                  onPressed: () {
                    // ToDo: Navigate
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF636B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                    ), // Only vertical padding
                  ),
                  child: SizedBox(
                    width:
                        screenWidth *
                        0.65, // Set a fixed width for both buttons
                    child: Center(
                      child: Text(
                        "Search in area",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Rentoutdashboard(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF636B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 15,
                    ), // Only vertical padding
                  ),
                  child: SizedBox(
                    width:
                        screenWidth * 0.65, // Same fixed width for consistency
                    child: Center(
                      child: Text(
                        "Rent out",
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 100),
              ],
            ),
          ),
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              onPressed: () {
                // ToDo: Implement logout functionality
                print("User logged out");
              },
              backgroundColor: Color(0xFF636B2F),
              child: Icon(Icons.logout, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MaterialApp(home: Home()));
}
