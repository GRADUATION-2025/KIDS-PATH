  import 'dart:async';
  import 'dart:convert'; // For json decoding
  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:firebase_auth/firebase_auth.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:geolocator/geolocator.dart';
  import 'package:google_fonts/google_fonts.dart';
  import 'package:google_maps_flutter/google_maps_flutter.dart';
  import 'package:http/http.dart' as http; // For HTTP requests

  import 'package:kidspath/WIDGETS/CONSTANTS/constants.dart';
  import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';
  import 'package:permission_handler/permission_handler.dart';
  import '../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_NURSERY.dart';
  import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';


  class GoogleMapsLocationx extends StatefulWidget {

    const GoogleMapsLocationx({super.key,});

    @override
    State<GoogleMapsLocationx> createState() => GoogleMapsLocationxState();
  }

  class GoogleMapsLocationxState extends State<GoogleMapsLocationx> {
    final Completer<GoogleMapController> _controller = Completer<GoogleMapController>();
    LatLng _centerLocation = LatLng(31.202075277264964, 29.92506760994049); // Default location
    bool _isPermissionGranted = false;
    Set<Marker> _markers = {}; // Store the marker
    StreamSubscription<Position>? _positionStream; // For tracking location
    String _streetAddress = ""; // Variable to store the address
    TextEditingController _addressController = TextEditingController(); // Controller for address input
    Timer? _debounceTimer; // Timer to implement debounce for the search input
    Timer? _inactivityTimer; // Timer to track inactivity
    bool _showPopup = false; // To control the popup visibility


    Marker? _centerMarker; // Marker to move with the map
    @override
    void initState() {
      _checkPermissionRequest();
      super.initState();

    }

    @override
    void dispose() {
      _positionStream?.cancel();
      _addressController.dispose();
      _debounceTimer?.cancel(); // Cancel the timer when disposing the widget
      _inactivityTimer?.cancel(); // Cancel inactivity timer
      super.dispose();


    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(100.h),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient,
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                    child: Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.arrow_back_ios_new_outlined,
                              color: Colors.transparent, size: 22.r),
                          onPressed: () {},
                        ),
                        SizedBox(width: 79.w),
                        Text(
                          "Your Location",
                          style: GoogleFonts.inter(
                              fontSize: 16.sp, color: Colors.white),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15.w),
                    child: SizedBox(
                      height: 40.h,
                      child: TextFormField(
                        controller: _addressController,
                        keyboardType: TextInputType.none,
                        decoration: InputDecoration(
                          prefixIcon: Icon(
                              Icons.search, size: 20.r, color: Colors.grey),
                          hintText: "Enter Location...",
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: EdgeInsets.symmetric(horizontal: 15.w),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20.r),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) {
                          _debounceSearchLocation(value); // Call debounce search
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
              gradient: AppGradients.Projectgradient, shape: BoxShape.circle),
          child: FloatingActionButton(
            onPressed: _getUserLocation,
            child: Icon(
                Icons.my_location_rounded, color: Colors.white, size: 30.r),
            backgroundColor: Colors.transparent,
            shape: OutlineInputBorder(borderRadius: BorderRadius.circular(25.r),
                borderSide: BorderSide.none),
          ),
        ),
        body: Stack(
          children: [
            GoogleMap(
              myLocationEnabled: _isPermissionGranted,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              initialCameraPosition: CameraPosition(
                  target: _centerLocation, zoom: 15),
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onCameraMove: (CameraPosition position) {
                setState(() {
                  _centerLocation = position.target;
                  // Update the center marker position
                  _centerMarker = Marker(
                    markerId: MarkerId("user_location"),
                    position: _centerLocation,
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
                  );
                });
                _resetInactivityTimer();
              },
              onCameraIdle: () {
                _fetchLocationDetails(_centerLocation); // Fetch address when the camera stops moving
              },
              markers: _centerMarker != null ? {_centerMarker!} : {}, // Show the center marker
            ),
            // Overlaying a location pin on the center
            Align(
              alignment: Alignment.center,
              child: Icon(Icons.location_on, size: 40.r, color: Colors.transparent),
            ),
            _showPopup ? _buildPopup() : SizedBox.shrink(), // Show popup if inactive
          ],
        ),
      );
    }

    _checkPermissionRequest() async {
      PermissionStatus status = await Permission.location.request();
      if (status.isGranted) {
        setState(() {
          _isPermissionGranted = true;
        });
        _getUserLocation();
      }
    }

    void _getUserLocation() async {
      if (!_isPermissionGranted) return;

      Position position = await Geolocator.getCurrentPosition(
          locationSettings: LocationSettings(accuracy: LocationAccuracy.high));
      setState(() {
        _centerLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(position); // Update the marker
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: _centerLocation, zoom: 15)));
      _startTracking(); // Start tracking user location
    }

    void _startTracking() async {
      _positionStream = Geolocator.getPositionStream(
        locationSettings: LocationSettings(
            accuracy: LocationAccuracy.high, distanceFilter: 5),
      ).listen((Position position) async {
        setState(() {
          _centerLocation = LatLng(position.latitude, position.longitude);
          _updateMarker(position); // Update the marker position smoothly
        });

        final GoogleMapController controller = await _controller.future;
        controller.animateCamera(CameraUpdate.newCameraPosition(
            CameraPosition(target: _centerLocation, zoom: 16)));
      });
    }

    void _updateMarker(Position position) {
      // Create or update the marker at the new position
      _centerMarker = Marker(
        markerId: MarkerId("user_location"),
        position: LatLng(position.latitude, position.longitude),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      );
      setState(() {});
    }

    // Fetch the address from the reverse geocoding API
    Future<void> _fetchLocationDetails(LatLng position) async {
      final String apiKey = Constants().apikey; // Use your own API key
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          setState(() {
            _streetAddress = data['results'][0]['formatted_address']; // Extract formatted address
            _addressController.text = _streetAddress; // Auto-fill the address in the text field
          });
        }
      } else {
        setState(() {
          _streetAddress = 'Failed to fetch address';
        });
      }
    }

    // Debounced search function to prevent marker update while typing
    void _debounceSearchLocation(String value) {
      if (_debounceTimer?.isActive ?? false) _debounceTimer?.cancel();

      _debounceTimer = Timer(const Duration(milliseconds: 1000), () {
        _searchLocation(value); // Call the search function after debounce
      });
    }

    // Search and move the marker based on the entered address
    Future<void> _searchLocation(String address) async {
      final String apiKey = Constants().apikey; // Use your own API key
      final String url = 'https://maps.googleapis.com/maps/api/geocode/json?address=$address&key=$apiKey';

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final latLng = data['results'][0]['geometry']['location'];
          final LatLng newLocation = LatLng(latLng['lat'], latLng['lng']);

          setState(() {
            _centerLocation = newLocation;
            _centerMarker = Marker(
              markerId: MarkerId("searched_location"),
              position: _centerLocation,
              icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
            );
          });

          // Move the camera smoothly to the new location
          final GoogleMapController controller = await _controller.future;
          controller.animateCamera(CameraUpdate.newCameraPosition(
              CameraPosition(target: _centerLocation, zoom: 15)));
        }
      } else {
        setState(() {
          _streetAddress = 'Failed to fetch address';
        });
      }
    }

    // Reset the inactivity timer
    void _resetInactivityTimer() {
      if (_inactivityTimer?.isActive ?? false) _inactivityTimer?.cancel();
      _inactivityTimer = Timer(const Duration(seconds: 7), () {
        setState(() {
          _showPopup = true; // Show the popup after inactivity
        });
      });
    }
    //----------------------------------------------------//
    Future<void> _saveLocationToFirebase() async {
      try {
        final user = FirebaseAuth.instance.currentUser;

        if (user == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User not authenticated')),
          );
          return;
        }

        // Fetch the user's role from Firestore
        final userDoc = await FirebaseFirestore.instance
            .collection('users') // Make sure 'users' is the correct collection
            .doc(user.uid)
            .get();

        if (!userDoc.exists || !userDoc.data()!.containsKey('role')) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User role not found')),
          );
          return;
        }

        final String role = userDoc['role'];

        // Save location only to the correct collection
        final targetCollection = role == 'Parent' ? 'parents' : role == 'Nursery' ? 'nurseries' : null;

        if (targetCollection == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid user role')),
          );
          return;
        }

        await FirebaseFirestore.instance
            .collection(targetCollection)
            .doc(user.uid)
            .set({
          'location': _streetAddress,
          'Coordinates':GeoPoint(_centerLocation.latitude,_centerLocation.longitude)
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Location saved to $targetCollection')),
        );

        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving location: $e')),
        );
      }
    }



    // Popup Dialog
    Widget _buildPopup() {
      return Padding(
        padding: EdgeInsets.all(20.w),
        child: Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Do you want to use this location as your current location?',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          _showPopup = false; // Close the popup
                        });

                        // Save location to Firebase


                        // Fetch the role and navigate based on it
                        final user = FirebaseAuth.instance.currentUser;
                        if (user != null) {
                          DocumentSnapshot userDoc = await FirebaseFirestore.instance
                              .collection('users')
                              .doc(user.uid)
                              .get();

                          if (userDoc.exists) {
                            String role = userDoc['role'];

                            // Navigate based on the role after frame is built
                            WidgetsBinding.instance.addPostFrameCallback((_) {
                              if (role == "Parent") {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottombarParentScreen()),
                                    (route)=>false
                                );
                              } else if (role == "Nursery") {
                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => BottombarNurseryScreen()),
                                    (route)=>false
                                );
                              } else {
                                print('Unknown role');
                              }
                            });
                          } else {
                            print('No role found for user');
                          }
                        }
                        await _saveLocationToFirebase();
                      },
                      child: Text("Yes"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _showPopup = false; // Hide the popup
                        });
                      },
                      child: Text("No"),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
  }

