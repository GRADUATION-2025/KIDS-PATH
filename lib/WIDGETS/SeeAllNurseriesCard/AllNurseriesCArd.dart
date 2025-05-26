import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';

import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../LOGIC/Home/home_cubit.dart';
import '../../THEME/theme_provider.dart';
import '../../UI/Create_Profile_screen/NURSERY/NurseryProfileScreen.dart';

class TopRatedCard extends StatelessWidget {
  final NurseryProfile nursery;
  final double? distance;

  const TopRatedCard({
    required this.nursery,
    this.distance,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _navigateToProfile(context, nursery),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _NurseryMainImage(profileImageUrl: nursery.profileImageUrl),
              _NurseryInfo(nursery: nursery, distance: distance),
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
          height: 150.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Colors.grey.shade200,
            height: 150.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Colors.grey.shade200,
            height: 150.h,
            child: const Icon(Icons.error),
          ),
        ),
      ),
    );
  }
}

class _NurseryInfo extends StatelessWidget {
  final NurseryProfile nursery;
  final double? distance;

  const _NurseryInfo({
    required this.nursery,
    this.distance,
  });

  String _formatDistance(double? distanceInMeters) {
    if (distanceInMeters == null) return 'Filter Will Show Distance';
    if (distanceInMeters == double.infinity) return 'Location not available';

    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m away';
    } else {
      return '${(distanceInMeters / 1000).toStringAsFixed(1)} km away';
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            nursery.name,
            style:  TextStyle(
              fontSize: 16.sp,
              color: isDark ? Colors.white : Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              SizedBox(width: 4.w),
              Text(
                _formatDistance(distance),
                style: TextStyle(
                  color: isDark ? Colors.white : Colors.grey.shade700,
                  fontSize: 14.sp,
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4.w),
                  Text(
                    nursery.rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: isDark ? Colors.white : Colors.grey.shade700,
                      fontSize: 14.sp,
                    ),
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
          SizedBox(height: 16.h),
          Text(
            'Error loading nurseries',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          SizedBox(height: 8.h),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              message,
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 16.h),
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
          SizedBox(height: 16.h),
          Text(
            message,
            style:  TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () => context.read<HomeCubit>().refreshData(),
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }
}