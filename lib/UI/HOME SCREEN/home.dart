import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/UI/HOME%20SCREEN/SEARCH%20FILTER/SEARCH.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../LOGIC/Home/home_cubit.dart';
import '../../LOGIC/Home/home_state.dart';
import '../Create_Profile_screen/NURSERY/NurseryProfileScreen.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => HomeCubit(),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.white,
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
                  const SizedBox(width: 10),
                  Text(
                    "Hi, $userName",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ],
              );
            },
          ),
          // actions: [
          //   IconButton(
          //     icon: const Icon(Icons.refresh, color: Colors.black),
          //     onPressed: () => context.read<HomeCubit>().refreshData(),
          //   ),
          // ],
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
      backgroundColor: Colors.grey.shade300,
      child: ClipOval(
        child: CachedNetworkImage(
          imageUrl: profileImageUrl ?? '',
          width: 40,
          height: 40,
          fit: BoxFit.cover,
          placeholder: (context, url) => const Icon(Icons.person, color: Colors.grey),
          errorWidget: (context, url, error) => const Icon(Icons.person, color: Colors.grey),
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SearchFilterScreen()


                  )
                );
              },
            ),

            const SizedBox(height: 20),
            _BannerImage(),
            const SizedBox(height: 20),
            _PopularNurseriesSection(nurseries: popularNurseries),
            const SizedBox(height: 20),
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
    return


      GestureDetector(onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.black),
          ),
          child: Row(
            children: [
              Icon(Icons.search, ),
              SizedBox(width: 15),
              Expanded(
                child: Text(
                  'Tap to Search...',
                  style: GoogleFonts.inter(fontSize: 15.sp),
                ),
              ),
            ],
          ),
        ),
      );




    //   TextField(
    //   onTap: onTap,
    //   decoration: InputDecoration(
    //     hintText: 'Type what you want to search...',
    //     prefixIcon: const Icon(Icons.search),
    //     border: OutlineInputBorder(
    //       borderRadius: BorderRadius.circular(10),
    //       borderSide: BorderSide(color: Colors.grey.shade300),
    //     ),
    //     filled: true,
    //     fillColor: Colors.grey.shade100,
    //   ),
    // );
  }
}

class _BannerImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: Image.asset(
        'assets/IMAGES/children.jpg',
        width: double.infinity,
        height: 150,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Container(
          color: Colors.grey.shade200,
          height: 150,
          child: const Icon(Icons.error),
        ),
      ),
    );
  }
}

class _PopularNurseriesSection extends StatelessWidget {
  final List<NurseryProfile> nurseries;

  const _PopularNurseriesSection({required this.nurseries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Nursery',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 120,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: nurseries.length,
            itemBuilder: (context, index) {
              return _PopularNurseryCard(nursery: nurseries[index]);
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
    return GestureDetector(
      onTap: () => _navigateToProfile(context, nursery),
      child: Container(
        width: 80,
        margin: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            _NurseryAvatar(profileImageUrl: nursery.profileImageUrl),
            const SizedBox(height: 8),
            Text(
              nursery.name,
              style: const TextStyle(fontSize: 12),
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

class _NurseryAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const _NurseryAvatar({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'nursery-avatar-$profileImageUrl',
      child: CircleAvatar(
        radius: 30,
        backgroundColor: Colors.grey.shade300,
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileImageUrl ?? '',
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            placeholder: (context, url) => const Icon(Icons.photo, color: Colors.grey),
            errorWidget: (context, url, error) => const Icon(Icons.photo, color: Colors.grey),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Top Rated',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: nurseries.length,
          itemBuilder: (context, index) {
            return _TopRatedCard(nursery: nurseries[index]);
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
                  Text(
                    nursery.rating.toStringAsFixed(1),
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 14,
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