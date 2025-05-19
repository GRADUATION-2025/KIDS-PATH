import 'package:cloud_firestore/cloud_firestore.dart';

class RatingStats {
  final int totalRatings;
  final Map<int, int> starCounts;
  final Map<int, double> starPercentages;

  RatingStats({
    required this.totalRatings,
    required this.starCounts,
    required this.starPercentages,
  });

  factory RatingStats.fromRatings(List<QueryDocumentSnapshot> ratings) {
    final counts = {1: 0, 2: 0, 3: 0, 4: 0, 5: 0};

    for (final rating in ratings) {
      final stars = rating['rating'] as int;
      counts[stars] = counts[stars]! + 1;
    }

    final total = ratings.length;
    final percentages = counts.map((star, count) => MapEntry(
        star,
        total > 0 ? (count / total * 100) : 0.0
    ));

    return RatingStats(
      totalRatings: total,
      starCounts: counts,
      starPercentages: percentages,
    );
  }
}