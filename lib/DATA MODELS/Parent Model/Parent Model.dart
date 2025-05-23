
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Parent {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phoneNumber;
  final List<String> paymentCards;
  final String location;
  final GeoPoint Coordinates;
  final String? profileImageUrl;

  Parent({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.paymentCards,
    required this.location,
    required this.Coordinates,
    this.profileImageUrl,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      "phoneNumber": phoneNumber,
      "paymentCards": paymentCards,
      "role": role,
      'location': location,
      'Coordinates': Coordinates,
      'profileImageUrl': profileImageUrl,

    };
  }

  factory Parent.fromMap(Map<String, dynamic> map) {
    return Parent(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      role: map['role'] ?? '',
      phoneNumber: map["phoneNumber"] ?? '',
      paymentCards: List<String>.from(map["paymentCards"] ?? []),
      location: map['location'] ?? '',
      Coordinates: map['Coordinates'] as GeoPoint? ?? GeoPoint(0.0, 0.0),
      profileImageUrl: map['profileImageUrl'],
    );
  }
  LatLng get latLng => LatLng(Coordinates.latitude, Coordinates.longitude);

}