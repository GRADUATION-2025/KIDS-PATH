import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../LOGIC/Home/home_cubit.dart';
import '../../LOGIC/Home/home_state.dart';
import '../../LOGIC/RATING/rating stats.dart';

import '../../THEME/theme_provider.dart';
import '../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../Create_Profile_screen/NURSERY/NurseryProfileScreen.dart';
import 'ALL Nurseriers Screen/show_all_nurseries.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: BlocBuilder<HomeCubit, HomeState>(
            builder: (context, state) {
              final userName = state is HomeLoaded
                  ? state.userName
                  : state is HomeLoading
                  ? state.userName
                  : 'Guest';
              final profileImageUrl = state is HomeLoaded
                  ? state.profileImageUrl
                  : state is HomeLoading
                  ? state.profileImageUrl
                  : null;
              return Row(
                children: [
                  _UserAvatar(profileImageUrl: profileImageUrl),
                  SizedBox(width: 10.w),
                  Text(
                    "Hi, $userName",
                    style:  TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        body: _HomeBody(),
      ),
    );
  }
}
class _UserAvatar extends StatelessWidget {
  final String? profileImageUrl;
  const _UserAvatar({required this.profileImageUrl});
  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Theme.of(context).cardColor,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImageUrl ?? '',
          width: 40.w,
          height: 40.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Icon(Icons.person, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          errorWidget: (context, url, error) => Icon(Icons.person, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
        ),
      ),
    );
  }
}

class _HomeBody extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is NurseryHomeError) {
          return _ErrorView(message: state.message);
        }

        if (state is HomeLoaded) {
          if (state.nurseries.isEmpty) {
            return _EmptyView(message: "No nurseries found");
          }

          return _HomeContentView(
            nurseries: state.nurseries,
            popularNurseries: state.popularNurseries,
            topRatedNurseries: state.topRatedNurseries,
          );
        }

        return _EmptyView(message: "Loading...");
      },
    );
  }
}

class _HomeContentView extends StatelessWidget {
  final List<NurseryProfile> nurseries;
  final List<NurseryProfile> popularNurseries;
  final List<NurseryProfile> topRatedNurseries;

  const _HomeContentView({
    required this.nurseries,
    required this.popularNurseries,
    required this.topRatedNurseries,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => context.read<HomeCubit>().refreshData(),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SearchBar(
              onTap: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => ShowAllNurseries()),
                      (route) => false,
                );

              },
            ),

            SizedBox(height: 10.h),
            _BannerImage(),
            SizedBox(height: 15.h),
            _PopularNurseriesSection(nurseries: popularNurseries),
            SizedBox(height: 5.h),
            _TopRatedSection(nurseries: topRatedNurseries),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {


  final VoidCallback? onTap;

  const _SearchBar({this.onTap});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: isDark ? Colors.white : Colors.black),
        ),
        child: Row(
          children: [
            Icon(Icons.search, color: isDark ? Colors.white : Colors.black),
            SizedBox(width: 15.w),
            Expanded(
              child: Text(
                  'Tap to Search...',
                  style: GoogleFonts.inter(fontSize: 15.sp,color: isDark ? Colors.white : Colors.black )
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/IMAGES/banner.png',
        width: double.infinity,
        height: 160.h,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Theme.of(context).cardColor,
          height: 160.h,
          child: Icon(Icons.error, color: Theme.of(context).iconTheme.color),
        ),
      ),
    );
  }
}
class _PopularNurseriesSection extends StatefulWidget {
  final List<NurseryProfile> nurseries;

  const _PopularNurseriesSection({required this.nurseries});

  @override
  State<_PopularNurseriesSection> createState() => _PopularNurseriesSectionState();
}

class _PopularNurseriesSectionState extends State<_PopularNurseriesSection> {
  late final PageController _pageController;
  Timer? _autoScrollTimer;
  int _currentPage = 5000; // Start in middle of large range

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: _currentPage,
      viewportFraction: 0.25, // Show 4 items at a time
    );
    if (widget.nurseries.isNotEmpty) {
      _startAutoScroll();
    }
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (!mounted) return;

      _currentPage++;
      _pageController.animateToPage(
        _currentPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );

      // Jump to middle position when approaching edges
      if (_currentPage > 9000 || _currentPage < 1000) {
        _currentPage = 5000;
        _pageController.jumpToPage(_currentPage);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.nurseries.isEmpty) {
      return SizedBox(
        height: 110.h,
        child: Center(
          child: Text(
            'No premium nurseries',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          children: [
            Text(
              'Premium Nurseries',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 10.h),
        SizedBox(
          height: 110.h,
          child: PageView.builder(
            controller: _pageController,
            itemCount: 10000, // Large number for infinite effect
            onPageChanged: (index) => _currentPage = index,
            itemBuilder: (context, index) {
              final nurseryIndex = index % widget.nurseries.length;
              final nursery = widget.nurseries[nurseryIndex];
              return _PopularNurseryCard(nursery: nursery);
            },
          ),
        ),
      ],
    );
  }
}

class _PopularNurseryCard extends StatelessWidget {
  final NurseryProfile nursery;

  const _PopularNurseryCard({required this.nursery});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return GestureDetector(
      onTap: () => _navigateToProfile(context, nursery),
      child: Container(
        width: 80.w,
        margin: const EdgeInsets.only(right: 7),
        child: Column(
          children: [
            Stack(
              children: [
                _NurseryAvatar(profileImageUrl: nursery.profileImageUrl),
                if (nursery.subscriptionStatus == 'premium')
                  Positioned(
                    top: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                      decoration: BoxDecoration(
                        gradient: AppGradients.Projectgradient,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'Premium',
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 8.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              nursery.name,
              style: GoogleFonts.inter(
                color: isDark ? Colors.white : Colors.black,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
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

class _NurseryAvatar extends StatefulWidget {
  final String? profileImageUrl;

  const _NurseryAvatar({required this.profileImageUrl});

  @override
  State<_NurseryAvatar> createState() => _NurseryAvatarState();
}

class _NurseryAvatarState extends State<_NurseryAvatar> {


  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    return Hero(
      tag: 'nursery-avatar-${widget.profileImageUrl}',
      child: CircleAvatar(
        radius: 30.r,
        backgroundColor: isDark ? Colors.grey[600]:Colors.grey.shade300 ,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: widget.profileImageUrl ?? '',
            width: 60.w,
            height: 60.h,
            fit: BoxFit.cover,
            placeholder: (context, url) => Icon(Icons.photo, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
            errorWidget: (context, url, error) => Icon(Icons.photo, color: Theme.of(context).iconTheme.color?.withOpacity(0.5)),
          ),
        ),
      ),
    );
  }
}

class _TopRatedSection extends StatelessWidget {
  final List<NurseryProfile> nurseries;

  const _TopRatedSection({required this.nurseries});

  @override
  Widget build(BuildContext context) {
    // Filter nurseries with rating exactly 5.0
    final topRatedNurseries = nurseries.where((n) => n.averageRating == 5.0).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Top Rated',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10.h),
        if (topRatedNurseries.isEmpty)
          Text(
            'No 5-star nurseries yet.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
          )
        else
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: topRatedNurseries.length > 4 ? 4 : topRatedNurseries.length,
            itemBuilder: (context, index) {
              return _TopRatedCard(nursery: topRatedNurseries[index]);
            },
          ),
      ],
    );
  }
}

class _TopRatedCard extends StatelessWidget {
  final NurseryProfile nursery;

  const _TopRatedCard({required this.nursery});

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
          height: 150.h,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            color: Theme.of(context).cardColor,
            height: 150.h,
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            color: Theme.of(context).cardColor,
            height: 150.h,
            child: Icon(Icons.error, color: Theme.of(context).iconTheme.color),
          ),
        ),
      ),
    );
  }
}

num _calculateAverageRating(Map<int, int> starCounts) {
  int total = starCounts.values.fold(0, (a, b) => a + b);
  if (total == 0) return 0.0;

  int sum = starCounts.entries.fold(
      0,
          (sum, entry) => sum + entry.key * entry.value
  );

  return (sum / total).round();
}


class _NurseryInfo extends StatelessWidget {
  final NurseryProfile nursery;

  const _NurseryInfo({required this.nursery});

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
            style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Icon(Icons.location_on, size: 16, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
              SizedBox(width: 4.w),
              Text('Filter will show Distance',  style: TextStyle(
                color: isDark ? Colors.white : Colors.black,),),
              const Spacer(),
              Row(
                children: [
                  const Icon(LucideIcons.star, size: 16, color: Colors.amber),
                  SizedBox(width: 4.w),
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('ratings')
                        .where('nurseryId', isEqualTo: nursery.uid)

                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Text(
                          '...',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                        );
                      }

                      if (snapshot.hasError) {
                        return Text(
                          '?',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14.sp),
                        );
                      }

                      final ratings = snapshot.data?.docs ?? [];
                      final stats = RatingStats.fromRatings(ratings);
                      final averageRating = _calculateAverageRating(stats.starCounts);

                      return Text(
                        averageRating.toStringAsFixed(1),
                        style: TextStyle(
                            color: isDark ? Colors.white : Colors.grey.shade700,
                            fontSize: 14.sp),
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
          Icon(Icons.search_off, size: 48, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
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
          Icon(Icons.search_off, size: 48, color: Theme.of(context).iconTheme.color?.withOpacity(0.6)),
          SizedBox(height: 16.h),
          Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16.sp),
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