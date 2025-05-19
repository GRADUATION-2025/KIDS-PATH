import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../../DATA MODELS/bookingModel/bookingModel.dart';
import '../../../LOGIC/ image/img upload/upload img.dart';
import '../../../LOGIC/booking/cubit.dart';
import '../../../LOGIC/chat/cubit.dart';
import '../../../LOGIC/chat/state.dart';
import '../../../LOGIC/rating stats.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
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
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
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
                        radius: 35,
                        backgroundImage: widget.nursery.profileImageUrl != null
                            ? NetworkImage(widget.nursery.profileImageUrl!)
                            : const AssetImage('assets/profile.jpg') as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.nursery.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
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
                                      style: const TextStyle(color: Colors.black),
                                    );
                                  }

                                  if (snapshot.hasError) {
                                    return Text(
                                      "Error • ${widget.nursery.language}",
                                      style: const TextStyle(color: Colors.black),
                                    );
                                  }

                                  final ratings = snapshot.data?.docs ?? [];
                                  final stats = RatingStats.fromRatings(ratings);
                                  final averageRating = _calculateAverageRating(stats.starCounts);

                                  return Text(
                                    "${averageRating.toStringAsFixed(1)} • ${widget.nursery.language}",
                                    style: const TextStyle(color: Colors.black),
                                  );
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child:
                        Container(
                          decoration: BoxDecoration(
                            gradient: AppGradients.Projectgradient,
                            borderRadius: BorderRadius.circular(8),
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
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            onPressed: () => Navigator.push(
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
                            ),
                            child: const Text(
                              'Book Now',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        )
                      ),
                      const SizedBox(width: 12),
                      Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(8),
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

            // About Section
            _sectionTitle("About"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.description,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            // Images Section
            _sectionTitle("Gallery"),
            _buildImageGallerySection(),
            _sectionTitle("Child Age"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.age,
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 15,
                  height: 1.4,
                ),
              ),
            ),

            // Programs Section
            _sectionTitle("Programs"),
            if (widget.nursery.programs.isNotEmpty)
              ...widget.nursery.programs.map((program) => _programCard(
                  program.split(' ')[0],

              )).toList(),

            // Price Section
            _sectionTitle("Pricing"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                widget.nursery.price,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
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
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),

            // Client Feedback
            // Client Feedback Section
            _sectionTitle("Clients Ratings"),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('ratings')
                    .where('nurseryId', isEqualTo: widget.nursery.uid)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Text('Error loading ratings: ${snapshot.error}');
                  }

                  // Update the average rating in Firestore whenever ratings change
                  if (snapshot.hasData) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _updateAverageRating(widget.nursery.uid);
                    });
                  }

                  final ratings = snapshot.data?.docs ?? [];
                  final stats = RatingStats.fromRatings(ratings);

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${_calculateAverageRating(stats.starCounts).toStringAsFixed(1)} out of 5  /  ${stats.totalRatings} Ratings",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._buildRatingBars(stats),
                    ],
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
// Add this method to calculate average rating
  double _calculateAverageRating(Map<int, int> starCounts) {
    int total = starCounts.values.reduce((a, b) => a + b);
    if (total == 0) return 0.0;

    int sum = starCounts.entries
        .map((entry) => entry.key * entry.value)
        .reduce((a, b) => a + b);

    return sum / total;
  }

  Widget _buildImageUploadSection() {
    return GestureDetector(
      onTap: _isPickingImages ? null : _pickAndUploadImages,
      child: Container(
        height: 100,
        width: 100,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
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

  List<Widget> _buildRatingBars(RatingStats stats) {
    return [5, 4, 3, 2, 1].map((stars) {
      final percentage = stats.starPercentages[stars] ?? 0.0;
      final count = stats.starCounts[stars] ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
          SizedBox(
          width: 100,
          child: Text('${'⭐' }  $stars Stars', style: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.bold))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 12,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  _getProgressBarColor(stars),
                ),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
          SizedBox(
            width: 60,
            child: Text(
                '${percentage.toStringAsFixed(1)}%',
                style: const TextStyle(fontSize: 14)),
          ),

          ],
        ),
      );
    }).toList();
  }

  Color _getProgressBarColor(int stars) {
    return const [
      Color(0xFFFF0000), // 1 star - red
      Color(0xFFFF4500), // 2 stars - orange red
      Color(0xFFFFA500), // 3 stars - orange
      Color(0xFF9ACD32), // 4 stars - yellow green
      Color(0xFF32CD32), // 5 stars - green
    ][stars - 1];
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
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Container(
                            width: 100,
                            height: 100,
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
                            width: 100,
                            height: 100,
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

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _programCard(String title,) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1,
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),

      ),
    );
  }
  Future<void> _updateAverageRating(String nurseryId) async {
    try {
      // Get all ratings for this nursery
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      final ratings = ratingsSnapshot.docs;
      final stats = RatingStats.fromRatings(ratings);
      final averageRating = _calculateAverageRating(stats.starCounts);

      // Update the nursery document with the new average rating
      await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(nurseryId)
          .update({
        'averageRating': averageRating,
        'totalRatings': stats.totalRatings,
      });
    } catch (e) {
      print('Error updating average rating: $e');
      // You might want to handle this error in your UI
    }
  }

}