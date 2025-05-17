import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
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
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedLocation;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedAge;
  int? _minRating;

  GeoPoint? _userLocation;

  // Age standardization method
  String? _getAgeLabel(String? age) {
    if (age == null) return null;
    final cleanAge = age.toLowerCase().trim();

    if (cleanAge.contains('6-12 months') ) return '6-12 months';
    if (cleanAge.contains('1 year') ) return '1 year';
    if (cleanAge.contains('2 years') ) return '2 years';
    if (cleanAge.contains('3 years') ) return '3 years';
    if (cleanAge.contains('4years') ) return '4 years';
    return null;
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
    super.dispose();
  }


  // Price parsing method
  double _parsePrice(String priceString) {
    try {
      final numericString = priceString.replaceAll(RegExp(r'[^0-9.]'), '');
      return double.parse(numericString);
    } catch (e) {
      return 0.0;
    }
  }


  Future<GeoPoint?> _getUserSavedLocation() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return null;

    final doc = await FirebaseFirestore.instance.collection("parents").doc(
        userId).get();
    return doc.data()?['location'] as GeoPoint?;
  }

  double _calculateDistance(GeoPoint a, GeoPoint b) {
    const earthRadius = 6371; // km
    final dLat = (b.latitude - a.latitude) * pi / 180;
    final dLon = (b.longitude - a.longitude) * pi / 180;

    final lat1 = a.latitude * pi / 180;
    final lat2 = b.latitude * pi / 180;

    final aCalc = sin(dLat / 2) * sin(dLat / 2) +
        sin(dLon / 2) * sin(dLon / 2) * cos(lat1) * cos(lat2);
    final c = 2 * atan2(sqrt(aCalc), sqrt(1 - aCalc));

    return earthRadius * c;
  }



  void _showFilterDialog() {
    String? tempLocation = _selectedLocation;
    int? tempMinPrice = _minPrice;
    int? tempMaxPrice = _maxPrice;
    String? tempSelectedAge = _selectedAge;
    int tempMinRating = _minRating ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                top: 24,
                left: 16,
                right: 16,
                bottom: MediaQuery
                    .of(context)
                    .viewInsets
                    .bottom + 24,
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = AppGradients.Projectgradient
                                .createShader(
                              const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
                            ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location input
                    const Text("Location"),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: _inputDecoration("Enter location"),
                      controller: TextEditingController(text: tempLocation),
                      onChanged: (value) =>
                          setModalState(() =>
                          tempLocation = value),
                    ),
                    const SizedBox(height: 8),

                    // Detect Location Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text("Detect Location"),
                      onPressed: () async {
                        final userLocation = await _getUserSavedLocation();
                        if (userLocation != null) {
                          setModalState(() {
                            _userLocation = userLocation;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "Location detected successfully!")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "Could not detect saved location.")),
                          );
                        }
                      },
                    ),

                    const SizedBox(height: 16),

                    // Age Dropdown
                    const Text("Child Age"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: tempSelectedAge,
                      decoration: _inputDecoration("Select age group"),
                      items: const [
                        DropdownMenuItem(value: "6-12 months", child: Text("6-12 months")),
                        DropdownMenuItem(value: "1 year", child: Text("1 year")),
                        DropdownMenuItem(value: "2 years", child: Text("2 years")),
                        DropdownMenuItem(value: "3 years", child: Text("3 years")),
                        DropdownMenuItem(value: "4 years", child: Text("4 years")),
                      ],
                      onChanged: (value) => setModalState(() => tempSelectedAge = value),
                    ),

                    const SizedBox(height: 16),

                    // Price Range
                    const Text("Price Range"),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: _inputDecoration("Min Price"),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(
                                decimal: false),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: _inputDecoration("Max Price"),
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

                    const SizedBox(height: 20),

                    // Rating Selector
                    Center(
                      child: Text(
                        "Nursery Rating",
                        style: GoogleFonts.inter(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Center(
                        child: RatingBar.builder(
                          initialRating: tempMinRating.toDouble(),
                          minRating: 1,
                          // Changed from 0 to 1
                          direction: Axis.horizontal,
                          allowHalfRating: false,
                          itemCount: 5,
                          itemSize: 30,
                          itemBuilder: (context, _) =>
                          const Icon(Icons.star, color: Colors.amber),
                          onRatingUpdate: (rating) =>
                              setModalState(() =>
                              tempMinRating = rating.toInt()),
                        )
                    ),

                    const SizedBox(height: 30),

                    // Apply Filters Button
                    GestureDetector(
                      onTap: () {
                        if (tempMinPrice != null && tempMaxPrice != null &&
                            tempMinPrice! > tempMaxPrice!) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text(
                                "Maximum price must be greater than minimum price")),
                          );
                          return;
                        }
                        setState(() {
                          _selectedLocation = tempLocation;
                          _minPrice = tempMinPrice;
                          _maxPrice = tempMaxPrice;
                          _selectedAge = tempSelectedAge;
                          _minRating =
                              tempMinRating; // Remove null check to allow 0
                        });

                        Navigator.pop(context);
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: AppGradients.Projectgradient,
                        ),
                        child: const Center(
                          child: Text(
                            "Apply Filters",
                            style: TextStyle(
                              fontSize: 18,
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

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey.shade100,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
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
              fontSize: 25,
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
                  MaterialPageRoute(
                      builder: (context) => BottombarParentScreen()),
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
              tooltip: 'Reset Search Field',
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _selectedLocation = null;
                  _minPrice = null;
                  _maxPrice = null;
                  _selectedAge = null;
                  _minRating = null;
                  _userLocation = null;
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
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        hintText: 'Search Nursery by Name',
                        hintStyle: const TextStyle(color: Colors.black),
                        prefixIcon: const Icon(
                            Icons.search, color: Colors.deepPurple),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors
                              .black),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors
                              .deepPurple),
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: _showFilterDialog,
                    child: Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: Colors.deepPurple,
                        borderRadius: BorderRadius.circular(25),
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
                    final int? _minPrice = int.tryParse(_minPriceController.text);
                    final int? _maxPrice = int.tryParse(_maxPriceController.text);

                    final filteredNurseries = nurseries.where((nursery) {
                      final nameMatch = nursery.name
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase());

                      // If search is typed, it must match
                      if (_searchController.text.isNotEmpty && !nameMatch) {
                        return false;
                      }

                      // Filters — each can match independently
                      final nurseryAge = _getAgeLabel(nursery.age);
                      final selectedAge = _getAgeLabel(_selectedAge);
                      final ageMatch = _selectedAge != null && nurseryAge == selectedAge;

                      final ratingMatch = _minRating != null &&
                          nursery.rating != null &&
                          nursery.rating!.round() == _minRating!;


                      // Price filter
                      final price = _parsePrice(nursery.price);
                      final priceMatch = (_minPrice == null || price >= _minPrice!) &&
                          (_maxPrice == null || price <= _maxPrice!);

                      // Add more filter options here (e.g., price, distance) using same pattern

                      // If no filters selected, return true (show all)
                      final noFiltersSelected = _selectedAge == null && _minRating == null;

                      // Return true if any filter matches, or no filters at all
                      return noFiltersSelected || ageMatch || ratingMatch || priceMatch ;
                    }).toList();


                    if (filteredNurseries.isEmpty) {
                      return Center(
                        child: Text(
                          "No nurseries found matching the criteria.",
                          style: GoogleFonts.inter(fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: const EdgeInsets.all(16),
                        itemCount: filteredNurseries.length,
                        itemBuilder: (context, index) {
                          final nursery = filteredNurseries[index];
                          return
                            TopRatedCard(nursery: nursery);
                        }
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