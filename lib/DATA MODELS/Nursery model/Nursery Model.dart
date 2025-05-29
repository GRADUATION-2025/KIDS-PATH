import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class NurseryProfile {
  final String uid;
  final String email;
  final String role;
  final String name;
  final String phoneNumber; // Added phone number
  final double rating;
  final String description;
  final List<String> programs;
  final List<String> schedules;
  final String calendar;
  final String hours;
  final String language;
  final String price;
  final String age;
  final String location;
  final GeoPoint Coordinates;
  final String? profileImageUrl;
  final double averageRating;
  final int totalRatings;
  final String subscriptionStatus; // Added subscription status

  var ownerId;


  NurseryProfile({
    required this.uid,
    required this.email,
    required this.role,
    required this.name,
    required this.phoneNumber, // Added as required parameter
    this.rating = 0.0,
    required this.description,
    required this.programs,
    required this.schedules,
    required this.calendar,
    required this.hours,
    required this.age,
    required this.language,
    required this.price,
    required this.location,
    required this.Coordinates,
    required this.averageRating,
    required this.totalRatings,
    this.profileImageUrl,
    required this.ownerId,
    this.subscriptionStatus = 'regular', // Default to regular
  });

  // Add a getter for valid coordinates
  bool get hasValidCoordinates =>
      Coordinates.latitude != 0.0 || Coordinates.longitude != 0.0;

  // Add a method to validate coordinates
  bool isValidCoordinate(GeoPoint coordinate) {
    return coordinate.latitude != 0.0 || coordinate.longitude != 0.0;
  }

  factory NurseryProfile.fromMap(Map<String, dynamic> map) {
    // Validate coordinates
    GeoPoint coordinates;
    if (map['Coordinates'] != null && map['Coordinates'] is GeoPoint) {
      coordinates = map['Coordinates'] as GeoPoint;
      // Validate that coordinates are not (0,0)
      if (coordinates.latitude == 0.0 && coordinates.longitude == 0.0) {
        coordinates = GeoPoint(0.0, 0.0); // Mark as invalid
      }
    } else {
      coordinates = GeoPoint(0.0, 0.0); // Mark as invalid
    }

    return NurseryProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      name: map['name'] ?? 'Nursery Name',
      phoneNumber: map['phoneNumber'] ?? '',
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? 'Description',
      programs: List<String>.from(map['programs'] ?? []),
      schedules: List<String>.from(map['schedules'] ?? []),
      calendar: map['calendar'] ?? '',
      hours: map['hours'] ?? '9 AM - 5 PM',
      age: map['age'] ?? '',
      averageRating: (map['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (map['totalRatings'] as num?)?.toInt() ?? 0,
      language: map['language'] ?? 'English',
      Coordinates: coordinates,
      price: map['price'] ?? '\$500/month',
      location: map['location'] ?? '',
      profileImageUrl: map['profileImageUrl'],
      ownerId: map['ownerId'] ?? '',
      subscriptionStatus: map['subscriptionStatus'] ?? 'regular',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'role': role,
      'name': name,
      'phoneNumber': phoneNumber, // Added phone number
      'rating': rating,
      'description': description,
      'programs': programs,
      'schedules': schedules,
      'calendar': calendar,
      'hours': hours,
      'averageRating': averageRating,
      'totalRatings': totalRatings,
      'language': language,
      'price': price,
      'age': age,
      'location':location,
      'Coordinates':Coordinates,
      'profileImageUrl': profileImageUrl,
      'ownerId': ownerId,
      'subscriptionStatus': subscriptionStatus,
    };
  }
  LatLng get latLng => LatLng(Coordinates.latitude, Coordinates.longitude);

}