import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:greenhand/services/firestoreService.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latlong2/latlong.dart';

class Adddevice extends StatefulWidget {
  const Adddevice({super.key});

  @override
  _AddDeviceState createState() => _AddDeviceState();
}

class _AddDeviceState extends State<Adddevice> {
  final FirestoreService _firestoreService = FirestoreService();
  List<String> categories = [];
  String? selectedCategory;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  DateTime? startDate;
  DateTime? endDate;

  bool formComplete = false;

  XFile? deviceImage;

  double? latitude;
  double? longitude;

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
    fetchCategories();

    nameController.addListener(validateForm);
    descriptionController.addListener(validateForm);
    priceController.addListener(validateForm);
  }

  Future<void> fetchCategories() async {
    final options = await _firestoreService.fetchCategories();
    setState(() {
      categories = options;
    });
  }

  void validateForm() {
    setState(() {
      formComplete =
          nameController.text.isNotEmpty &&
          descriptionController.text.isNotEmpty &&
          priceController.text.isNotEmpty &&
          selectedCategory != null &&
          startDate != null &&
          endDate != null;
    });
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: source);

      if (image != null) {
        setState(() {
          deviceImage = image;
        });
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Failed to pick image: $error")));
    }
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(vertical: 40, horizontal: 20),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF636B2F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(7)),
                      ),
                      padding: EdgeInsets.zero,
                    ),
                    child: Icon(
                      Icons.chevron_left,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                  SizedBox(width: 20),
                  Text(
                    "Add New Device",
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return SafeArea(
                        child: Wrap(
                          children: <Widget>[
                            ListTile(
                              leading: Icon(Icons.camera),
                              title: Text("Take a photo"),
                              onTap: () {
                                Navigator.of(context).pop();
                                pickImage(ImageSource.camera);
                              },
                            ),
                            ListTile(
                              leading: Icon(Icons.photo_library),
                              title: Text("Choose from gallery"),
                              onTap: () {
                                Navigator.of(context).pop();
                                pickImage(ImageSource.gallery);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                child: Container(
                  width: double.infinity,
                  height: 200,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(75, 99, 107, 47),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child:
                      deviceImage != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.file(
                              File(deviceImage!.path),
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                            ),
                          )
                          : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Icon(
                                  Icons.add_a_photo,
                                  color: Color(0xFF636B2F),
                                  size: 30,
                                ),
                                SizedBox(height: 6),
                                Text(
                                  "add photo",
                                  style: TextStyle(
                                    color: const Color.fromARGB(
                                      255,
                                      77,
                                      77,
                                      77,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Category",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  border: Border.all(color: Colors.grey[600]!, width: 1),
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    hint: Text(
                      "Select a category",
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    items:
                        categories.map((String categoryOption) {
                          return DropdownMenuItem<String>(
                            value: categoryOption,
                            child: Text(
                              categoryOption,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black,
                              ),
                            ),
                          );
                        }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCategory = newValue;
                        validateForm();
                      });
                    },
                    dropdownColor: Colors.white,
                    icon: Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text("Name", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 3),
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText: "Device name",
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "Description",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 3),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText: "Description",
                ),
              ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text("Price", style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              SizedBox(height: 3),
              TextField(
                controller: priceController,
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*[.,]?\d*')),
                ],
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  hintText: "Price",
                ),
              ),
              SizedBox(height: 20),
              Row(
                children: [
                  Text(
                    "Location",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () async {
                        // Fetch current location
                        try {
                          LocationPermission permission =
                              await Geolocator.requestPermission();
                          if (permission == LocationPermission.denied ||
                              permission == LocationPermission.deniedForever) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Location permission denied"),
                              ),
                            );
                            return;
                          }

                          Position position =
                              await Geolocator.getCurrentPosition(
                                desiredAccuracy: LocationAccuracy.high,
                              );

                          setState(() {
                            latitude = position.latitude;
                            longitude = position.longitude;
                          });

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Current location selected"),
                            ),
                          );
                        } catch (error) {
                          print(error);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Failed to fetch location: $error"),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF636B2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "Use Current Location",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return SizedBox(
                              height: 600,
                              child: FlutterMap(
                                options: MapOptions(
                                  center: LatLng(
                                    latitude ??
                                        51.509865, // Default latitude if none is selected
                                    longitude ??
                                        -0.118092, // Default longitude if none is selected
                                  ),
                                  zoom: 13.0,
                                  onTap: (tapPosition, point) {
                                    setState(() {
                                      latitude = point.latitude;
                                      longitude = point.longitude;
                                    });
                                    Navigator.pop(context);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Location selected"),
                                      ),
                                    );
                                  },
                                ),
                                children: [
                                  TileLayer(
                                    urlTemplate:
                                        "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                                    subdomains: ['a', 'b', 'c'],
                                  ),
                                  MarkerLayer(
                                    markers: [
                                      if (latitude != null && longitude != null)
                                        Marker(
                                          width: 80.0,
                                          height: 80.0,
                                          point: LatLng(latitude!, longitude!),
                                          builder:
                                              (ctx) => Icon(
                                                Icons.location_pin,
                                                color: Colors.red,
                                                size: 40,
                                              ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF636B2F),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.all(Radius.circular(7)),
                        ),
                        padding: EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: Text(
                        "Select on Map",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              if (latitude != null && longitude != null)
                Text(
                  "Selected Location: ($latitude, $longitude)",
                  style: TextStyle(color: Colors.grey[700]),
                ),
              SizedBox(height: 15),
              Row(
                children: [
                  Text(
                    "Availability",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              SizedBox(height: 3),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: startDate ?? DateTime.now(),
                          firstDate: DateTime(2000), // Earliest date
                          lastDate: DateTime(2100), // Latest date
                        );
                        if (pickedDate != null) {
                          setState(() {
                            startDate = pickedDate;
                            validateForm();
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          startDate != null
                              ? "Start: ${DateFormat('dd-MM-yyyy').format(startDate!)}"
                              : "Select Start Date",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () async {
                        if (startDate == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Please select a start date first"),
                            ),
                          );
                          return;
                        }

                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: endDate ?? startDate!,
                          firstDate: startDate!,
                          lastDate: DateTime(2100),
                        );
                        if (pickedDate != null) {
                          setState(() {
                            endDate = pickedDate;
                            validateForm();
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          vertical: 15,
                          horizontal: 10,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          endDate != null
                              ? "End: ${DateFormat('dd-MM-yyyy').format(endDate!)}"
                              : "Select End Date",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed:
                      formComplete
                          ? () async {
                            try {
                              // 1. Price --> double
                              double? price = double.tryParse(
                                priceController.text.replaceAll(',', '.'),
                              );

                              // 2. User ID
                              var userId =
                                  FirebaseAuth.instance.currentUser?.uid;
                              // (Temp ID for testing)
                              userId ??= "-12";

                              // // 3. Upload image
                              // String? imageUrl;
                              // if (deviceImage != null) {
                              //   imageUrl = await _firestoreService.uploadImage(
                              //     deviceImage!,
                              //   );
                              //   if (imageUrl == null) {
                              //     ScaffoldMessenger.of(context).showSnackBar(
                              //       SnackBar(
                              //         content: Text("Failed to upload image"),
                              //       ),
                              //     );
                              //     imageUrl = "";
                              //   }
                              // }

                              // 3. Convert image to base64
                              String? imageUrl;
                              if (deviceImage != null) {
                                imageUrl = imageToBase64(deviceImage!);
                              }

                              // 4. Device object
                              final device = {
                                "name": nameController.text,
                                "description": descriptionController.text,
                                "price": price,
                                "category": selectedCategory,
                                "startDate": startDate!.toIso8601String(),
                                "endDate": endDate!.toIso8601String(),
                                "userId": userId,
                                "imageUrl": imageUrl,
                                "latitude": latitude,
                                "longitude": longitude,
                              };

                              // 5. Send to service
                              await _firestoreService.addDevice(device);

                              // 6. Success
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Device added successfully"),
                                ),
                              );

                              // 7. Clear form
                              setState(() {
                                nameController.clear();
                                descriptionController.clear();
                                priceController.clear();
                                selectedCategory = null;
                                startDate = null;
                                endDate = null;
                                deviceImage = null;
                                latitude = null;
                                longitude = null;
                              });

                              // 8. Navigate
                              Navigator.pop(context);
                            } catch (error) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text("Failed to add device: $error"),
                                ),
                              );
                            }
                          }
                          : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF636B2F),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(Radius.circular(7)),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 15),
                  ),
                  child: Text("Add", style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String imageToBase64(XFile image) {
    try {
      final bytes = File(image.path).readAsBytesSync();
      return base64Encode(bytes);
    } catch (e) {
      print("Error converting image to Base64: $e");
      return "";
    }
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(home: Adddevice()));
}
