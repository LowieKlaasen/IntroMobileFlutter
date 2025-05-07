import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:greenhand/search/searchByCategory.dart';
import 'package:greenhand/services/firestoreService.dart';

class CategoryPicker extends StatelessWidget {
  const CategoryPicker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarIconBrightness: Brightness.dark),
    );

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Stack(
        children: [
          // Main content
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  const Text(
                    "Choose Category",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 36),
                  ),
                  const SizedBox(height: 42),
                  Image(
                    image: const AssetImage("assets/icon/GreenHand_Logo.png"),
                    width: screenWidth * 0.35,
                  ),
                  const SizedBox(height: 21),
                  Expanded(child: CategoryListWidget()),
                ],
              ),
            ),
          ),
          // Back button
          Positioned(
            top: 70,
            left: 10,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black, size: 30),
              onPressed: () {
                Navigator.pop(context); // Navigate back to the previous screen
              },
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryListWidget extends StatefulWidget {
  @override
  _CategoryListState createState() => _CategoryListState();
}

class _CategoryListState extends State<CategoryListWidget> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> categories = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    try {
      final fetchedCategories =
          await _firestoreService.fetchCategoriesWithIcons();
      setState(() {
        categories = fetchedCategories;
        loading = false;
      });
    } catch (error) {
      print("Error getting categories: $error");
      setState(() {
        loading = false;
      });
    }
  }

  IconData getIconFromName(String iconName) {
    switch (iconName) {
      case 'kitchen':
        return Icons.kitchen;
      case 'outdoor_grill':
        return Icons.outdoor_grill;
      case 'hardware':
        return Icons.hardware;
      case 'sanitizer_outlined':
        return Icons.sanitizer_outlined;
      case 'electrical_services':
        return Icons.electrical_services;
      case 'forest_outlined':
        return Icons.forest_outlined;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(child: CircularProgressIndicator());
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: AlwaysScrollableScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (context, index) {
        final category = categories[index];
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.symmetric(
                vertical: 15,
                horizontal: 20,
              ),
              leading: Icon(
                getIconFromName(category['icon']),
                size: 40,
                color: Color(0xFF636B2F),
              ),
              title: Text(
                category['name'],
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF636B2F),
                ),
              ),
              trailing: Icon(Icons.arrow_forward_ios, color: Color(0xFF636B2F)),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (context) =>
                            SearchByCategory(category: category['name']),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: CategoryPicker()));
}
