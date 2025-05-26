
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../../LOGIC/Home/home_cubit.dart';
import '../../../LOGIC/Home/home_state.dart';
import '../../../WIDGETS/BOTTOM NAV BAR/BTM_BAR_NAV_PARENT.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../../../WIDGETS/SeeAllNurseriesCard/AllNurseriesCArd.dart';

class ShowAllNurseries extends StatefulWidget {
  const ShowAllNurseries({super.key});

  @override
  State<ShowAllNurseries> createState() => _ShowAllNurseriesState();
}

class _ShowAllNurseriesState extends State<ShowAllNurseries> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  String? _selectedLocation;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedAge;
  int? _minRating;
  GeoPoint? _selectedGeoPoint;
  double _searchRadius = 10.0; // Default 10km radius

  String normalizeAge(String? age) {
    if (age == null) return '';
    return age
        .toLowerCase()
        .trim()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .replaceAll('months', 'month')
        .replaceAll('years', 'year');
  }

  Query _buildQuery() {
    return _firestore.collection('nurseries');
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _locationController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  double _parsePrice(String priceString) {
    try {
      final numericString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericString);
    } catch (e) {
      return 0.0;
    }
  }

  Future<GeoPoint?> _getSavedLocationFromFirestore() async {
    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return null;

      final docSnapshot = await FirebaseFirestore.instance
          .collection('parents')
          .doc(uid)
          .get();
      final data = docSnapshot.data();
      if (data == null || data['Coordinates'] == null) return null;

      final coordinates = data['Coordinates'] as GeoPoint;
      // Validate coordinates
      if (coordinates.latitude == 0.0 && coordinates.longitude == 0.0) {
        return null;
      }
      return coordinates;
    } catch (e) {
      debugPrint('Error fetching location: $e');
      return null;
    }
  }

  double _calculateDistance(GeoPoint point1, GeoPoint point2) {
    try {
      // Validate coordinates before calculation
      if (point1.latitude == 0.0 && point1.longitude == 0.0 ||
          point2.latitude == 0.0 && point2.longitude == 0.0) {
        return double.infinity; // Return infinity for invalid coordinates
      }
      
      return Geolocator.distanceBetween(
        point1.latitude,
        point1.longitude,
        point2.latitude,
        point2.longitude,
      );
    } catch (e) {
      debugPrint('Error calculating distance: $e');
      return double.infinity;
    }
  }

  // Add this method to validate coordinates
  bool _isValidCoordinates(GeoPoint coordinates) {
    return coordinates.latitude != 0.0 || coordinates.longitude != 0.0;
  }

  void _showFilterDialog() {
    String? tempLocation = _selectedLocation;
    int? tempMinPrice = _minPrice;
    int? tempMaxPrice = _maxPrice;
    String? tempAge = _selectedAge;
    int tempMinRating = _minRating ?? 0;
    GeoPoint? tempGeoPoint = _selectedGeoPoint;
    double tempRadius = _searchRadius;

    showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25))),
    builder: (context) {
    return StatefulBuilder(
    builder: (context, setModalState) {
    return Padding(
    padding: EdgeInsets.only(
    top: 24,
    left: 16,
    right: 16,
    bottom: MediaQuery.of(context).viewInsets.bottom + 24,
    ),
    child: SingleChildScrollView(
    child: Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
    Center(
    child: Text(
    "Filter Options",
    style: TextStyle(
    fontSize: 24.sp,
    fontWeight: FontWeight.bold,
    foreground: Paint()
    ..shader = AppGradients.Projectgradient.createShader(
    const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
    ),
    ),
    ),
     SizedBox(height: 24.h),

    // Location input
    const Text("Location"),
     SizedBox(height: 6.h),
    TextField(
    decoration: _inputDecoration("Enter location", ""),
    controller: _locationController..text = tempLocation ?? '',
    keyboardType: TextInputType.none,
    onChanged: (value) => setModalState(() {
    tempLocation = value;
    tempGeoPoint = null;
  }),
    ),
     SizedBox(height: 8.h),

    ElevatedButton.icon(
    icon: const Icon(Icons.my_location),
    label: const Text("Use Saved Location"),
    onPressed: () async {
    final geoPoint = await _getSavedLocationFromFirestore();
    if (geoPoint != null) {
    setModalState(() {
    tempGeoPoint = geoPoint;
    tempLocation = "My Location (${geoPoint.latitude.toStringAsFixed(4)}, ${geoPoint.longitude.toStringAsFixed(4)})";
    _locationController.text = tempLocation!;
  });
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("No saved location found")),
    );
  }
  },
    ),

     SizedBox(height: 16.h),

    // Search Radius Slider
    const Text("Search Radius (km)"),
    Slider(
    value: tempRadius,
    min: 1,
    max: 50,
    divisions: 49,
    label: "${tempRadius.round()} km",
    onChanged: (value) => setModalState(() => tempRadius = value),
    ),

     SizedBox(height: 16.h),

    // Age Dropdown
    const Text("Child Age"),
     SizedBox(height: 6.h),
    DropdownButtonFormField<String>(
    value: tempAge,
    decoration: _inputDecoration("Select age group", ""),
    items: const [
    DropdownMenuItem(value: "6-12 months", child: Text("6-12 months")),
    DropdownMenuItem(value: "1 year", child: Text("1 year")),
    DropdownMenuItem(value: "2 years", child: Text("2 years")),
    DropdownMenuItem(value: "3 years", child: Text("3 years")),
    DropdownMenuItem(value: "4 years", child: Text("4 years")),
    ],
    onChanged: (value) => setModalState(() => tempAge = value),
    ),

     SizedBox(height: 16.h),

    // Price Range
    const Text("Price Range"),
     SizedBox(height: 6.h),
    Row(
    children: [
    Expanded(
    child: TextField(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: _inputDecoration("Min Price", "K EGP"),
    controller: _minPriceController,
    onChanged: (value) {
    if (value.isEmpty) {
    setModalState(() => tempMinPrice = null);
    return;
  }
    final parsed = int.tryParse(value);
    setModalState(() => tempMinPrice = parsed);
  },
    ),
    ),
     SizedBox(width: 12.w),
    Expanded(
    child: TextField(
    keyboardType: TextInputType.number,
    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
    decoration: _inputDecoration("Max Price", "K EGP"),
    controller: _maxPriceController,
    onChanged: (value) {
    if (value.isEmpty) {
    setModalState(() => tempMaxPrice = null);
    return;
  }
    final parsed = int.tryParse(value);
    setModalState(() => tempMaxPrice = parsed);
  },
    ),
    ),
    ],
    ),

     SizedBox(height: 20.h),

    // Rating Selector
    Center(
    child: Text(
    "Minimum Rating",
    style: GoogleFonts.inter(
    fontSize: 20.sp, fontWeight: FontWeight.bold),
    ),
    ),
     SizedBox(height: 8.h),
    Center(
    child: RatingBar.builder(
    initialRating: tempMinRating.toDouble(),
    minRating: 0,
    direction: Axis.horizontal,
    allowHalfRating: false,
    itemCount: 5,
    itemSize: 30,
    itemBuilder: (context, _) =>
    const Icon(Icons.star, color: Colors.amber),
    onRatingUpdate: (rating) =>
    setModalState(() => tempMinRating = rating.toInt()),
    )),

     SizedBox(height: 30.h),

    // Apply Filters Button
    GestureDetector(
    onTap: () {
    setState(() {
    _selectedLocation = tempLocation;
    _selectedGeoPoint = tempGeoPoint;
    _minPrice = tempMinPrice;
    _maxPrice = tempMaxPrice;
    _selectedAge = tempAge;
    _minRating = tempMinRating == 0 ? null : tempMinRating;
    _searchRadius = tempRadius;
  });
    Navigator.pop(context);
  },
    child: Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 14),
    decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
    gradient: AppGradients.Projectgradient,
    ),
    child:  Center(
    child: Text(
    "Apply Filters",
    style: TextStyle(
    fontSize: 18.sp,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 0.5,
    ),
    ),
    ),
    ),
    ),
    ],
    ),
    ),
    );
  },
    );
  },
        );
  }

  InputDecoration _inputDecoration(String hint, String suffix) {
    return InputDecoration(
      hintText: hint,
      suffixText: suffix,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          title: Text(
            "All Nurseries",
            style: GoogleFonts.inter(
              fontSize: 25.sp,
              foreground: Paint()
                ..shader = AppGradients.Projectgradient.createShader(
                  const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                ),
            ),
          ),
          leading: Padding(
            padding: const EdgeInsets.all(8.0),
            child: InkWell(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => BottombarParentScreen()),
                      (route) => false,
                );
              },
              child: const Icon(Icons.arrow_back, size: 30),
            ),
          ),
          leadingWidth: 35,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Reset Filters',
              onPressed: () {
                _searchController.clear();
                _minPriceController.clear();
                _maxPriceController.clear();
                _locationController.clear();
                setState(() {
                  _selectedLocation = null;
                  _minPrice = null;
                  _maxPrice = null;
                  _selectedAge = null;
                  _minRating = null;
                  _selectedGeoPoint = null;
                  _searchRadius = 10.0;
                });
                FocusScope.of(context).unfocus();
              },
            ),
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      keyboardType: TextInputType.name,
                        inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Search Nursery by Name',
                        hintStyle: const TextStyle(color: Colors.black),
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.deepPurple),
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                      ),
                    ),
                  ),
                   SizedBox(width: 8.w),
                  InkWell(
                    onTap: _showFilterDialog,
                    child: Container(
                      height: 50.h,
                      width: 50.w,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(25.r),
                      ),
                      child: const Icon(Icons.filter_alt, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: BlocBuilder<HomeCubit, HomeState>(
                builder: (context, state) {
                  if (state is HomeLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is HomeLoaded) {
                    final nurseries = state.nurseries;

                    final filteredNurseries = nurseries.where((nursery) {
                      // Name Filter
                      final nameMatch = nursery.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());
                      if (_searchController.text.isNotEmpty && !nameMatch) {
                        return false;
                      }

                      // Age Filter
                      if (_selectedAge != null) {
                        final nurseryAge = normalizeAge(nursery.age);
                        final selectedAge = normalizeAge(_selectedAge);
                        if (nurseryAge != selectedAge) {
                          return false;
                        }
                      }

                      // Ratings Filter
                      if (_minRating != null) {
                        if (nursery.rating == null ||
                            nursery.rating!.round() != _minRating!) {
                          return false;
                        }
                      }

                      // Price Filter
                      final price = _parsePrice(nursery.price);
                      if (_minPrice != null && price < _minPrice!) {
                        return false;
                      }
                      if (_maxPrice != null && price > _maxPrice!) {
                        return false;
                      }

                      // Location Filter
                      if (_selectedGeoPoint != null) {
                        // Skip if nursery has invalid coordinates
                        if (!_isValidCoordinates(nursery.Coordinates)) {
                          return false;
                        }

                        final distance = _calculateDistance(
                            _selectedGeoPoint!,
                            nursery.Coordinates
                        );

                        // Skip if distance calculation failed
                        if (distance == double.infinity) {
                          return false;
                        }

                        debugPrint('Distance to ${nursery.name}: ${(distance/1000).toStringAsFixed(2)} km');

                        // Filter by search radius (convert km to meters)
                        if (distance > (_searchRadius * 1000)) {
                          return false;
                        }
                      }

                      return true;
                    }).toList();

                    if (filteredNurseries.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
                             SizedBox(height: 16.h),
                            Text(
                              "No nurseries found matching your criteria",
                              style: GoogleFonts.inter(
                                fontSize: 18.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                             SizedBox(height: 8.h),
                            if (_selectedGeoPoint != null)
                              Text(
                                "Try increasing your search radius",
                                style: GoogleFonts.inter(
                                  fontSize: 14.sp,
                                  color: Colors.grey[500],
                                ),
                              ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredNurseries.length,
                      itemBuilder: (context, index) {
                        final nursery = filteredNurseries[index];
                        return TopRatedCard(
                          nursery: nursery,
                          distance: _selectedGeoPoint != null
                              ? _calculateDistance(_selectedGeoPoint!, nursery.Coordinates)
                              : null,
                        );
                      },
                    );
                  }
                  if (state is NurseryHomeError) {
                    return Center(
                      child: Text("Failed to load nurseries: ${state.message}"),
                    );
                  }
                  return const Center(child: Text("No data available"));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
