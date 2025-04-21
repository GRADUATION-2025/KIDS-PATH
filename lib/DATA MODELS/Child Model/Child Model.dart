class Child {
  final String id;
  final String name;
  final int age;
  final String gender;

  Child({
    required this.id,
    required this.name,
    required this.age,
    required this.gender,
  });

  factory Child.fromMap(Map<String, dynamic> data, String docId) {
    return Child(
      id: docId,
      name: data['name'] ?? '',
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'gender': gender,
    };
  }
}
