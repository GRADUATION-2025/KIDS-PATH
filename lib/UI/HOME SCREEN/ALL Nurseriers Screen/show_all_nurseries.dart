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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  String? _selectedLocation;
  int? _minPrice;
  int? _maxPrice;
  String? _selectedAge;
  int? _minRating;

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

  void _showFilterDialog() {
    String? tempLocation = _selectedLocation;
    int? tempMinPrice = _minPrice;
    int? tempMaxPrice = _maxPrice;
    String? tempAge = _selectedAge;
    int tempMinRating = _minRating ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),),
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          foreground: Paint()
                            ..shader = AppGradients.Projectgradient.createShader(
                                const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Location input
                    const Text("Location"),
                    const SizedBox(height: 6),
                    TextField(
                      decoration: _inputDecoration("Enter location", ""),
                      controller: TextEditingController(text: tempLocation),
                      onChanged: (value) => setModalState(() => tempLocation = value),
                    ),
                    const SizedBox(height: 8),

                    // Detect Location Button
                    ElevatedButton.icon(
                      icon: const Icon(Icons.my_location),
                      label: const Text("Detect Location"),
                      onPressed: () async {},
                    ),

                    const SizedBox(height: 16),

                    // Age Dropdown - Fixed value and onChanged
                    const Text("Child Age"),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: tempAge, // Use tempAge here
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

                    const SizedBox(height: 16),

                    // Price Range
                    const Text("Price Range"),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(decimal: false),
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
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            keyboardType: TextInputType.numberWithOptions(decimal: false),
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

                    const SizedBox(height: 30),

                    // Apply Filters Button
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedLocation = tempLocation;
                          _minPrice = tempMinPrice;
                          _maxPrice = tempMaxPrice;
                          _selectedAge = tempAge;
                          _minRating = tempMinRating == 0 ? null : tempMinRating; // Convert 0 to null
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

  InputDecoration _inputDecoration(String hint, String thousand) {
    return InputDecoration(
      hintText: hint,
      suffixText: thousand,
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
              tooltip: 'Reset Search Field',
              onPressed: () {
                _searchController.clear();
                _minPriceController.clear();
                _maxPriceController.clear();
                setState(() {
                  _selectedLocation = null;
                  _minPrice = null;
                  _maxPrice = null;
                  _selectedAge = null;
                  _minRating = null;
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
                        prefixIcon: const Icon(Icons.search, color: Colors.deepPurple),
                        enabledBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.black),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: const BorderSide(color: Colors.deepPurple),
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

                      if (_searchController.text.isNotEmpty && !nameMatch) {
                        return false;
                      }

                      // Age filter - using normalized values
                      if (_selectedAge != null) {
                        final nurseryAge = normalizeAge(nursery.age);
                        final selectedAge = normalizeAge(_selectedAge);
                        if (nurseryAge != selectedAge) {
                          return false;
                        }
                      }

                      if (_minRating != null) {
                        if (nursery.averageRating == null ||
                            nursery.averageRating! < _minRating!.toDouble()) {
                          return false;
                        }
                      }
                      // Price filter
                      final price = _parsePrice(nursery.price);
                      if (_minPrice != null && price < _minPrice!) {
                        return false;
                      }
                      if (_maxPrice != null && price > _maxPrice!) {
                        return false;
                      }

                      return true;
                    }).toList();

                    if (filteredNurseries.isEmpty) {
                      return Center(
                        child: Text(
                            "No nurseries found matching the criteria.",
                            style: GoogleFonts.inter(fontSize: 18)),
                      );
                    }

                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      itemCount: filteredNurseries.length,
                      itemBuilder: (context, index) {
                        final nursery = filteredNurseries[index];
                        return TopRatedCard(nursery: nursery);
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