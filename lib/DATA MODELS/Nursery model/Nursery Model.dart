import 'package:cloud_firestore/cloud_firestore.dart';

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
    required ownerId,
  });

  factory NurseryProfile.fromMap(Map<String, dynamic> map) {
    return NurseryProfile(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      name: map['name'] ?? 'Nursery Name',
      phoneNumber: map['phoneNumber'] ?? '', // Added phone number
      rating: (map['rating'] as num?)?.toDouble() ?? 0.0,
      description: map['description'] ?? 'Description',
      programs: List<String>.from(map['programs'] ?? []),
      schedules: List<String>.from(map['schedules'] ?? []),
      calendar: map['calendar'] ?? '',
      hours: map['hours'] ?? '9 AM - 5 PM',
      age: map['age'] ?? '',
      averageRating: map['averageRating'] ?? '',
      totalRatings: map['totalRatings'] ?? '',
      language: map['language'] ?? 'English',
      Coordinates: map['Coordinates'] ?? GeoPoint(0, 0),
      price: map['price'] ?? '\$500/month',
      location: map['location'] ?? '',
      profileImageUrl: map['profileImageUrl'], ownerId: null,
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

    };
  }
}