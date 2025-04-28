

import 'package:flutter/material.dart';

import '../../DATA MODELS/bookingModel/bookingModel.dart';

@immutable
sealed class BookingState {}

final class BookingInitial extends BookingState {}

final class BookingLoading extends BookingState {}

final class BookingsLoaded extends BookingState {
  final List<Booking> bookings;

  BookingsLoaded(this.bookings);
}

final class BookingCreated extends BookingState {}

final class BookingStatusUpdated extends BookingState {}

final class BookingError extends BookingState {
  final String message;

  BookingError(this.message);
}