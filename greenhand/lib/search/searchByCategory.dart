import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:greenhand/search/deviceDetail.dart';
import 'package:greenhand/services/firestoreService.dart';
import 'package:intl/intl.dart';
import 'package:geocoding/geocoding.dart';

class SearchByCategory extends StatefulWidget {
  final String category;

  const SearchByCategory({Key? key, required this.category}) : super(key: key);

  @override
  _SearchByCategoryState createState() => _SearchByCategoryState();
}

class _SearchByCategoryState extends State<SearchByCategory> {
  final FirestoreService _firestoreService = FirestoreService();
  List<Map<String, dynamic>> items = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    fetchItems();
  }

  Future<void> fetchItems() async {
    try {
      final fetchedItems = await _firestoreService.fetchItemsByCategory(
        widget.category,
      );
      setState(() {
        items = fetchedItems;
        loading = false;
      });
    } catch (e) {
      print("Error fetching items: $e");
      setState(() {
        loading = false;
      });
    }
  }

  IconData getIconFromName(String catName) {
    switch (catName) {
      case 'Kitchen':
        return Icons.kitchen;
      case 'Garden':
        return Icons.outdoor_grill;
      case 'Tools':
        return Icons.hardware;
      case 'Cleaning':
        return Icons.sanitizer_outlined;
      case 'Electronics':
        return Icons.electrical_services;
      case 'Camping':
        return Icons.forest_outlined;
      default:
        return Icons.help_outline;
    }
  }

  String formatDate(String date) {
    try {
      final parsedDate = DateTime.parse(date);
      return DateFormat('MMM dd').format(parsedDate);
    } catch (e) {
      return "Invalid date";
    }
  }

  Future<String> getRegionAndCountryFromCoordinates(
    double lat,
    double lng,
  ) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        final country = placemarks[0].country ?? 'Country not found';
        final region =
            placemarks[0].subAdministrativeArea ?? 'Region not found';
        return "${region}, ${country}";
      }
      return 'Location not found';
    } catch (error) {
      print("Error: $error");
      return 'Error fetching location';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(getIconFromName(widget.category), color: Colors.white),
            SizedBox(width: 5),
            Text(widget.category, style: TextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor: Color(0xFF636B2F),
      ),
      body:
          loading
              ? Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? Center(
                child: Text(
                  "No items found for this category.",
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
              )
              : Padding(
                padding: EdgeInsets.only(top: 15),
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DeviceDetail(device: item),
                          ),
                        );
                      },
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 8,
                              horizontal: 16,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(
                                    item['imageUrl'],
                                    width: 110,
                                    height: 110,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Icon(
                                        Icons.broken_image,
                                        size: 40,
                                        color: Color(0xFF636B2F),
                                      );
                                    },
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item['name'],
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Color(0xFF636B2F),
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "€${item['price']}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        "Available ${formatDate(item['startDate'])} - ${formatDate(item['endDate'])}",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color: Color(0xFF636B2F),
                                          ),
                                          FutureBuilder<String>(
                                            future:
                                            // ToDo: Store and get coördinates from db
                                            getRegionAndCountryFromCoordinates(
                                              51.229778,
                                              4.417200,
                                            ),
                                            builder: (context, snapshot) {
                                              if (snapshot.connectionState ==
                                                  ConnectionState.waiting) {
                                                return Text("Loading...");
                                              } else if (snapshot.hasError) {
                                                return Text("Error");
                                              } else {
                                                return Text(
                                                  snapshot.data ??
                                                      "Unknown location",
                                                );
                                              }
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Divider(
                            color: Colors.grey[300],
                            thickness: 1,
                            indent: 16,
                            endIndent: 16,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: SearchByCategory(category: 'Kitchen')));
}
