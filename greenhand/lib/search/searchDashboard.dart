import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:greenhand/search/categoryPicker.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestoreService.dart';
import 'deviceDetail.dart';
import 'searchByCategory.dart'; // Import the SearchByCategory screen

class SearchDashboard extends StatefulWidget {
  const SearchDashboard({super.key});

  @override
  State<SearchDashboard> createState() => _SearchDashboardState();
}

class _SearchDashboardState extends State<SearchDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    final listings = await _firestoreService.fetchListingsWithLocation();
    setState(() {
      _markers.addAll(
        listings.map(
          (listing) => Marker(
            point: LatLng(listing['latitude'], listing['longitude']),
            builder:
                (ctx) => GestureDetector(
                  onTap: () {
                    // Navigate to the DeviceDetail screen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DeviceDetail(device: listing),
                      ),
                    );
                  },
                  child: Icon(Icons.location_pin, color: Colors.red, size: 30),
                ),
          ),
        ),
      );
    });
  }

  Future<void> _centerToUserLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.low,
      );
      _mapController.move(LatLng(position.latitude, position.longitude), 15.0);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not fetch location: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Search Dashboard",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF636B2F),
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerToUserLocation,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(center: LatLng(37.7749, -122.4194), zoom: 12),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(markers: _markers),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the SearchByCategory screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CategoryPicker()),
          );
        },
        backgroundColor: const Color(0xFF636B2F),
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
