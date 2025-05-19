import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../LOGIC/Home/home_cubit.dart';
import '../../LOGIC/rating stats.dart';
import '../../UI/Create_Profile_screen/NURSERY/NurseryProfileScreen.dart';

class TopRatedCard extends StatelessWidget {
  final NurseryProfile nursery;

  const TopRatedCard({required this.nursery});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context, nursery),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NurseryMainImage(profileImageUrl: nursery.profileImageUrl),
              _NurseryInfo(nursery: nursery),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToProfile(BuildContext context, NurseryProfile nursery) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NurseryProfileScreen(nursery: nursery),
      ),
    );
  }
}

class _NurseryMainImage extends StatelessWidget {
  final String? profileImageUrl;

  const _NurseryMainImage({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: Hero(
        tag: 'nursery-image-$profileImageUrl',
        child: CachedNetworkImage(
          imageUrl: profileImageUrl ?? 'https://via.placeholder.com/400x200',
          width: double.infinity,
          height: 150,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            height: 150,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            height: 150,
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}
double _calculateAverageRating(Map<int, int> starCounts) {
  int total = starCounts.values.fold(0, (a, b) => a + b);
  if (total == 0) return 0.0;

  int sum = starCounts.entries.fold(
      0,
          (sum, entry) => sum + entry.key * entry.value
  );

  return sum / total;
}
class _NurseryInfo extends StatelessWidget {
  final NurseryProfile nursery;

  const _NurseryInfo({required this.nursery});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nursery.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text('0.48 mi away'),
              const Spacer(),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                  const SizedBox(width: 4),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('ratings')
                        .where('nurseryId', isEqualTo: nursery.uid)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          '...',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          '?',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 14,
                          ),
                        );
                      }

                      final ratings = snapshot.data?.docs ?? [];
                      final stats = RatingStats.fromRatings(ratings);
                      final averageRating = _calculateAverageRating(stats.starCounts);

                      return Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;

  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error loading nurseries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().refreshData(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String message;

  const _EmptyView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.search_off, size: 48, color: Colors.grey),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().refreshData(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}