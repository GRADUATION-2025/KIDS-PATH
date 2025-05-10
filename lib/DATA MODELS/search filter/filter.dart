// filter_params.dart
import 'package:flutter/material.dart';

class FilterParams {
  final double minRating;
  final RangeValues priceRange;
  final String ageGroup;
  final String schedule;
  final String curriculum;
  final double startTime;
  final double endTime;
  final bool overnight;
  final bool weekend;
  final bool afterCare;

  FilterParams({
    required this.minRating,
    required this.priceRange,
    required this.ageGroup,
    required this.schedule,
    required this.curriculum,
    required this.startTime,
    required this.endTime,
    required this.overnight,
    required this.weekend,
    required this.afterCare,
  });
}