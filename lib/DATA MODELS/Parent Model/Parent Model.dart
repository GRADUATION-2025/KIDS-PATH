
class Parent {
  final String uid;
  final String name;
  final String email;
  final String role;
  final String phoneNumber;
  final List<String> paymentCards;
  final String location;
  final String? profileImageUrl;

  Parent({
    required this.uid,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.role,
    required this.paymentCards,
    required this.location,
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
      profileImageUrl: map['profileImageUrl'],
    );
  }
}