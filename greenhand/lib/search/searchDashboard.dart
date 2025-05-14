import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/firestoreService.dart';
import 'deviceDetail.dart';
import 'categoryPicker.dart';

class SearchDashboard extends StatefulWidget {
  const SearchDashboard({super.key});

  @override
  State<SearchDashboard> createState() => _SearchDashboardState();
}

class _SearchDashboardState extends State<SearchDashboard> {
  final FirestoreService _firestoreService = FirestoreService();
  final List<Marker> _markers = [];
  final MapController _mapController = MapController();
  LatLng? _currentLocation; // Variable to store the user's current location

  @override
  void initState() {
    super.initState();
    _loadListings();
    _getCurrentLocation(); // Fetch the user's current location
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

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Could not fetch location: $e')));
    }
  }

  Future<void> _centerToUserLocation() async {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 15.0);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User location not available')),
      );
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
        iconTheme: const IconThemeData(color: Colors.white),
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
          MarkerLayer(
            markers: [
              ..._markers,
              if (_currentLocation != null)
                Marker(
                  point: _currentLocation!,
                  builder:
                      (ctx) => const Icon(
                        Icons.circle,
                        color: Colors.blue,
                        size: 15,
                      ),
                ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Navigate to the CategoryPicker screen
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CategoryPicker()),
          );
        },
        backgroundColor: const Color(0xFF636B2F),
        child: const Icon(Icons.search, color: Colors.white),
      ),
    );
  }
}
