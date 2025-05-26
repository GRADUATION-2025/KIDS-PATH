import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../../LOGIC/booking/cubit.dart';
import '../../../LOGIC/chat/cubit.dart';
import '../../../LOGIC/chat/state.dart';
import '../../../LOGIC/image/img upload/upload img.dart';
import '../../../LOGIC/RATING/rating stats.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../../../THEME/theme_provider.dart';
import '../../BOOKING/Booking.dart';
import '../../CHAT/chat.dart';


class NurseryProfileScreen extends StatefulWidget {
  final NurseryProfile nursery;


  const NurseryProfileScreen({Key? key, required this.nursery, }) : super(key: key);

  @override
  State<NurseryProfileScreen> createState() => _NurseryProfileScreenState();
}

class _NurseryProfileScreenState extends State<NurseryProfileScreen> {
  final NurseryImageService _imageService = NurseryImageService();
  final nurseries = FirebaseFirestore.instance.collection("nurseries");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late Future<List<String>> _imagesFuture;
  bool _isUploading = false;
  double _uploadProgress = 0;
  List<File> _selectedImages = [];
  bool _isPickingImages = false;
  bool _isOwner = false;

  @override
  void initState() {
    super.initState();
    _checkOwnership();
    _loadImages();
  }

  void _checkOwnership() {
    final currentUser = _auth.currentUser;
    if (currentUser != null && widget.nursery.uid == currentUser.uid) {
      setState(() {
        _isOwner = true;
      });
    }
  }

  void _loadImages() {
    setState(() {
      _imagesFuture = _imageService.getNurseryImages(widget.nursery.uid);
    });
  }

  Future<void> _pickAndUploadImages() async {
    try {
      setState(() => _isPickingImages = true);

      final pickedImages = await _imageService.pickMultipleImages();
      if (pickedImages.isEmpty) return;

      setState(() {
        _selectedImages = pickedImages;
        _isPickingImages = false;
        _isUploading = true;
        _uploadProgress = 0;
      });

      final urls = await _imageService.uploadNurseryImages(
        nurseryId: widget.nursery.uid,
        imageFiles: _selectedImages,
        onUploadProgress: (progress) {
          setState(() => _uploadProgress = progress);
        },
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')),
      );

      setState(() {
        _selectedImages.clear();
      });
      _loadImages();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      setState(() {
        _isPickingImages = false;
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    try {
      await _imageService.deleteImage(imageUrl);
      _loadImages();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image deleted successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete image: $e')),
      );
    }
  }

  Future<void> _handleMessageButtonPress() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await context.read<ChatCubit>().joinNurseryChat(
        widget.nursery.uid,
        user.uid,
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            chatRoomId: widget.nursery.uid,
            nurseryName: widget.nursery.name,
            nurseryImageUrl: widget.nursery.profileImageUrl,
            userId: user.uid,
            userImage: user.photoURL,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(20.r),
                  bottomRight: Radius.circular(20.r),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark ? Colors.black26 : Colors.grey.withOpacity(0.2),
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 35.r,
                        backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                        backgroundImage: widget.nursery.profileImageUrl != null
                            ? NetworkImage(widget.nursery.profileImageUrl!)
                            : const AssetImage('assets/profile.jpg') as ImageProvider,
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nursery.name,
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black,
                            ),
                          ),
                          Row(
                            children: [
                              const Icon(Icons.star, color: Colors.yellow, size: 16),
                              StreamBuilder<QuerySnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('ratings')
                                    .where('nurseryId', isEqualTo: widget.nursery.uid)
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return Text(
                                      "Loading... • ${widget.nursery.language}",
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[300] : Colors.black87,
                                      ),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Text(
                                      "Error • ${widget.nursery.language}",
                                      style: TextStyle(
                                        color: isDark ? Colors.grey[300] : Colors.black87,
                                      ),
                                    );
                                  }

                                  final ratings = snapshot.data?.docs ?? [];
                                  final stats = RatingStats.fromRatings(ratings);
                                  final averageRating = _calculateAverageRating(stats.starCounts);

                                  return Text(
                                    "${averageRating.toStringAsFixed(1)} • ${widget.nursery.language}",
                                    style: TextStyle(
                                      color: isDark ? Colors.grey[300] : Colors.black87,
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
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.Projectgradient,
                            borderRadius: BorderRadius.circular(8.r),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.blue.withOpacity(0.3),
                                spreadRadius: 1,
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            onPressed: () => _navigateToBooking(context),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        decoration: BoxDecoration(
                          gradient: AppGradients.Projectgradient,
                          borderRadius: BorderRadius.circular(8.r),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.3),
                              spreadRadius: 1,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: BlocListener<ChatCubit, ChatState>(
                          listener: (context, state) {
                            if (state is ChatError) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(state.message)),
                              );
                            }
                          },
                          child: IconButton(
                            onPressed: _handleMessageButtonPress,
                            icon: const Icon(
                              LucideIcons.messageCircle,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Description Section
            _sectionTitle("About"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.description,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
            ),

            // Images Section
            _sectionTitle("Gallery"),
            _buildImageGallerySection(),

            // Child Age Section
            _sectionTitle("Child Age"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.age,
                style: TextStyle(
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  fontSize: 15.sp,
                  height: 1.4,
                ),
              ),
            ),

            // Programs Section
            _sectionTitle("Programs"),
            if (widget.nursery.programs.isNotEmpty)
              ...widget.nursery.programs.map((program) => Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                color: isDark ? Colors.grey[850] : Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 1,
                child: ListTile(
                  title: Text(
                    program.split(' ')[0],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              )).toList(),

            // Price Section
            _sectionTitle("Interview Price"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.price,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            // Operating Hours
            _sectionTitle("Operating Hours"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.hours,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: isDark ? Colors.grey[300] : Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            // Ratings Section
            _sectionTitle("Ratings & Reviews"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ratings')
                    .where('nurseryId', isEqualTo: widget.nursery.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: isDark ? Colors.blue[400] : Colors.blue,
                      ),
                    );
                  }

                  if (snapshot.hasError) {
                    return Text(
                      'Error loading ratings: ${snapshot.error}',
                      style: TextStyle(
                        color: isDark ? Colors.red[400] : Colors.red,
                      ),
                    );
                  }

                  final ratings = snapshot.data?.docs ?? [];
                  final stats = RatingStats.fromRatings(ratings);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_calculateAverageRating(stats.starCounts).toStringAsFixed(1)} out of 5",
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      ..._buildRatingBars(stats),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black,
        ),
      ),
    );
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _isPickingImages ? null : _pickAndUploadImages,
      child: Container(
        height: 100.h,
        width: 100.w,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.3),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: _isPickingImages
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : const Center(
          child: Icon(Icons.add, size: 40, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildImageGallerySection() {
    return FutureBuilder<List<String>>(
      future: _imagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final images = snapshot.data ?? [];
        final allItems = _isOwner ? [null, ...images] : images;

        return SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: allItems.map((item) {
              if (item == null) {
                return _buildImageUploadSection();
              }
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        item,
                        width: 100.w,
                        height: 100.h,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100.w,
                            height: 100.h,
                            color: Colors.grey[200],
                            child: Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100.w,
                            height: 100.h,
                            color: Colors.grey[200],
                            child: const Icon(Icons.broken_image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    if (_isOwner)
                      Positioned(
                        top: 4,
                        right: 4,
                        child: GestureDetector(
                          onTap: () => _deleteImage(item),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  double _calculateAverageRating(Map<int, int> starCounts) {
    int total = starCounts.values.reduce((a, b) => a + b);
    if (total == 0) return 0.0;

    int sum = starCounts.entries
        .map((entry) => entry.key * entry.value)
        .reduce((a, b) => a + b);

    return sum / total;
  }

  void _navigateToBooking(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (context) => BookingCubit(),
          child: BookingScreen(
            nurseryId: widget.nursery.uid,
            nurseryName: widget.nursery.name,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildRatingBars(RatingStats stats) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return List.generate(5, (index) {
      final starNumber = 5 - index;
      final count = stats.starCounts[starNumber] ?? 0;
      final percentage = stats.totalRatings > 0
          ? (count / stats.totalRatings * 100).toStringAsFixed(1)
          : '0.0';

      return Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Row(
          children: [
            Text(
              '$starNumber',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
            Icon(Icons.star, size: 14.sp, color: Colors.amber),
            SizedBox(width: 8.w),
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: stats.totalRatings > 0 ? count / stats.totalRatings : 0,
                  backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.amber),
                  minHeight: 8.h,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            Text(
              '$percentage%',
              style: TextStyle(
                color: isDark ? Colors.grey[400] : Colors.grey[600],
                fontSize: 14.sp,
              ),
            ),
          ],
        ),
      );
    });
  }
}