import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

Future<List<Map<String, dynamic>>> getFilteredNurseries(Map<String, dynamic> filters) async {
  Query query = FirebaseFirestore.instance.collection('nurseries');

  if (filters['showNearby']) {
    // Requires user's location and GeoQuery integration (e.g., geoflutterfire)
  }

  if (filters['ageOfChildren'] != '') {
    query = query.where('acceptedAges', arrayContains: filters['ageOfChildren']);
  }

  if (filters['opening'] != '') {
    query = query.where('openingStatus', isEqualTo: filters['opening']);
  }

  if (filters['schedule'] != '') {
    query = query.where('schedule', isEqualTo: filters['schedule']);
  }

  if (!filters['anyHours']) {
    query = query
        .where('availableFrom', isLessThanOrEqualTo: filters['startTime'].format( TimeOfDay.now()))
        .where('availableTo', isGreaterThanOrEqualTo: filters['endTime'].format( TimeOfDay.now()));
  }

  if (filters['overnight']) query = query.where('overnight', isEqualTo: true);
  if (filters['weekend']) query = query.where('weekend', isEqualTo: true);
  if (filters['afterCare']) query = query.where('afterCare', isEqualTo: true);

  query = query.where('curriculum', isEqualTo: filters['curriculum']);
  query = query
      .where('price', isGreaterThanOrEqualTo: filters['priceRange'].start)
      .where('price', isLessThanOrEqualTo: filters['priceRange'].end);

  query = query.where('rating', isGreaterThanOrEqualTo: filters['starRating']);

  // Apply sorting
  switch (filters['sortBy']) {
    case 'Star Rating (highest first)':
      query = query.orderBy('rating', descending: true);
      break;
    case 'Star Rating (lowest first)':
      query = query.orderBy('rating', descending: false);
      break;
    case 'Price (lowest first)':
      query = query.orderBy('price', descending: false);
      break;
    case 'Price (highest first)':
      query = query.orderBy('price', descending: true);
      break;
    case 'Popularity':
      query = query.orderBy('popularity', descending: true);
      break;
    case 'Best Reviewed First':
      query = query.orderBy('reviewsCount', descending: true);
      break;
  }

  final snapshot = await query.get();
  return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
}
