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
      final dynamic ratingValue = rating['rating'];

      // Handle different possible types
      int stars;
      if (ratingValue is int) {
        stars = ratingValue.clamp(1, 5); // Ensure between 1-5
      } else if (ratingValue is double) {
        stars = ratingValue.round().clamp(1, 5); // Round and clamp
      } else {
        continue; // Skip invalid ratings
      }

      counts[stars] = counts[stars]! + 1;
    }

    final total = ratings.length;
    final percentages = counts.map((star, count) =>
        MapEntry(
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