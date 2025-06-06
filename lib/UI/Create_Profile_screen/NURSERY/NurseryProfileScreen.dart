import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../../LOGIC/Nursery/nursery_cubit.dart';
import '../../../LOGIC/Nursery/nursery_state.dart';
import '../../../LOGIC/booking/cubit.dart';
import '../../../LOGIC/chat/cubit.dart';
import '../../../LOGIC/chat/state.dart';
import '../../../LOGIC/image/img upload/upload img.dart';
import '../../../LOGIC/RATING/rating stats.dart';
import '../../../THEME/theme_provider.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import '../../BOOKING/Booking.dart';
import '../../CHAT/chat.dart';
import '../../PREMIUM/PremiumFeaturesScreen.dart';

class NurseryProfileScreen extends StatefulWidget {
  final NurseryProfile nursery;

  const NurseryProfileScreen({Key? key, required this.nursery}) : super(key: key);

  @override
  State<NurseryProfileScreen> createState() => _NurseryProfileScreenState();
}

class _NurseryProfileScreenState extends State<NurseryProfileScreen> {
  final NurseryImageService _imageService = NurseryImageService();
  final nurseries = FirebaseFirestore.instance.collection("nurseries");
  final FirebaseAuth _auth = FirebaseAuth.instance;
  List<String> _imageUrls = [];
  bool _isUploading = false;
  double _uploadProgress = 0;
  List<File> _selectedImages = [];
  bool _isPickingImages = false;
  bool _isOwner = false;
  bool _isLoadingImages = false;
  late NurseryProfile _currentNursery;

  @override
  void initState() {
    super.initState();
    _currentNursery = widget.nursery;
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

  Future<void> _loadImages() async {
    setState(() => _isLoadingImages = true);
    try {
      final images = await _imageService.getNurseryImages(widget.nursery.uid);
      setState(() => _imageUrls = images);
    } catch (e) {
      print('Error loading images: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load images: ${e.toString()}')),
      );
    } finally {
      setState(() => _isLoadingImages = false);
    }
  }

  Future<void> _pickAndUploadImages() async {
    try {
      setState(() => _isPickingImages = true);

      final nurseryDoc = await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(widget.nursery.uid)
          .get();

      final subscriptionStatus = (nurseryDoc['subscriptionStatus'] as String?) ?? 'regular';
      final isPremium = subscriptionStatus == 'premium';

      if (!isPremium && _imageUrls.length >= 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Regular nurseries can only upload up to 4 images. Upgrade to premium for unlimited uploads.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isPickingImages = false);
        return;
      }

      final pickedImages = await _imageService.pickMultipleImages();
      if (pickedImages.isEmpty) return;

      if (!isPremium && (_imageUrls.length + pickedImages.length) > 4) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You can only upload up to 4 images total. Please select fewer images.'),
            duration: Duration(seconds: 3),
          ),
        );
        setState(() => _isPickingImages = false);
        return;
      }

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

      setState(() {
        _imageUrls.addAll(urls);
        _selectedImages.clear();
        _isUploading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Images uploaded successfully!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
      setState(() {
        _isPickingImages = false;
        _isUploading = false;
      });
    }
  }

  Future<void> _deleteImage(String imageUrl) async {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final isDark = themeProvider.isDarkMode;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Image'),
          content: const Text('Are you sure you want to delete this image?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(context).pop(false),
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () => Navigator.of(context).pop(true),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      await _imageService.deleteImage(imageUrl);

      // Optimistic update - remove the image immediately
      setState(() {
        _imageUrls.remove(imageUrl);
      });

      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark ? Colors.white : Colors.black,
          content: Text(
            'Image deleted successfully',
            style: TextStyle(color: isDark ? Colors.black : Colors.white),
          ),
        ),
      );
    } catch (e) {
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: isDark ? Colors.white : Colors.black,
          content: Text(
            'Failed to delete image: ${e.toString()}',
            style: TextStyle(color: isDark ? Colors.black : Colors.white),
          ),
        ),
      );
    } finally {
      // Refresh the list from server to ensure consistency
      _loadImages();
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return BlocListener<NurseryCubit, NurseryState>(
      listener: (context, state) {
        if (state is NurseryLoaded) {
          setState(() {
            _currentNursery = state.nursery;
          });
        }
      },
      child: Scaffold(
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                padding: const EdgeInsets.only(
                    top: 50, bottom: 20, left: 16, right: 16),
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
                        _UserAvatar(profileImageUrl: widget.nursery.profileImageUrl),
                        SizedBox(width: 12.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.nursery.name,
                              style: GoogleFonts.inter(
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
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      );
                                    }

                                    if (snapshot.hasError) {
                                      return Text(
                                        "Error • ${widget.nursery.language}",
                                        style: TextStyle(
                                          color: isDark ? Colors.white : Colors.black,
                                        ),
                                      );
                                    }

                                    final ratings = snapshot.data?.docs ?? [];
                                    final stats = RatingStats.fromRatings(ratings);
                                    final averageRating = _calculateAverageRating(stats.starCounts);

                                    return Text(
                                      "${averageRating.toStringAsFixed(1)} • ${widget.nursery.language}",
                                      style: TextStyle(
                                        color: isDark ? Colors.white : Colors.black,
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
                          child: StreamBuilder<DocumentSnapshot>(
                            stream: FirebaseFirestore.instance
                                .collection('nurseries')
                                .doc(_currentNursery.uid)
                                .snapshots(),
                            builder: (context, snapshot) {
                              if (!snapshot.hasData) {
                                return Container(
                                  height: 48,
                                  alignment: Alignment.center,
                                  child: CircularProgressIndicator(color: Colors.white),
                                );
                              }

                              final nurseryDoc = snapshot.data!;
                              final subscriptionStatus =
                                  (nurseryDoc['subscriptionStatus'] as String?) ?? 'basic';

                              return Container(
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
                                  onPressed: () {
                                    if (_isOwner) {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => PremiumFeaturesScreen(
                                            nurseryId: _currentNursery.uid,
                                          ),
                                        ),
                                      );
                                    } else {
                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => BlocProvider(
                                            create: (context) => BookingCubit(),
                                            child: BookingScreen(
                                              nurseryId: _currentNursery.uid,
                                              nurseryName: _currentNursery.name,
                                            ),
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                  child: Text(
                                    _isOwner
                                        ? (subscriptionStatus == 'premium' ? 'Premium' : 'Go Premium')
                                        : 'Book Now',
                                    style: GoogleFonts.inter(
                                      color: Colors.white,
                                      fontSize: 13.sp,
                                      fontWeight: _isOwner ? FontWeight.bold : FontWeight.normal,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        SizedBox(width: 12.w),
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
                            child: MessageButton(nursery: _currentNursery),
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15.sp,
                    height: 1.4,
                  ),
                ),
              ),

              _sectionTitle("Location"),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        widget.nursery.location,
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                          fontSize: 15.sp,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
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
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 15.sp,
                    height: 1.4,
                  ),
                ),
              ),

              // Programs Section
              _sectionTitle("Programs"),
              if (widget.nursery.programs.isNotEmpty)
                ...widget.nursery.programs.map((program) =>
                    _programCard(program.split(' ')[0])).toList(),

              // Price Section
              _sectionTitle("Interview Price"),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  '${widget.nursery.price} EGP',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: isDark ? Colors.white : Colors.black87,
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
                    color: isDark ? Colors.white : Colors.black87,
                    height: 1.4,
                  ),
                ),
              ),

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
                      return Center(child: CircularProgressIndicator(
                          color: isDark ? Colors.blue[400] : Colors.blue));
                    }

                    if (snapshot.hasError) {
                      return Text('Error loading ratings: ${snapshot.error}',
                        style: TextStyle(
                          color: isDark ? Colors.red[400] : Colors.red,
                        ),
                      );
                    }

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
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black),
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
    if (_isLoadingImages) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_imageUrls.isEmpty && !_isOwner) {
      return const Center(child: Text('No images available'));
    }

    return SizedBox(
      height: 120,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          if (_isOwner) _buildImageUploadSection(),
          ..._imageUrls.map((imageUrl) => Padding(
            padding: const EdgeInsets.all(4.0),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: imageUrl,
                    width: 100.w,
                    height: 100.h,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.broken_image, color: Colors.grey),
                    ),
                  ),
                ),
                if (_isOwner)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: GestureDetector(
                      onTap: () => _deleteImage(imageUrl),
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
          )).toList(),
        ],
      ),
    );
  }

  num _calculateAverageRating(Map<int, int> starCounts) {
    int total = starCounts.values.reduce((a, b) => a + b);
    if (total == 0) return 0.0;

    int sum = starCounts.entries
        .map((entry) => entry.key * entry.value)
        .reduce((a, b) => a + b);

    return (sum / total).round();
  }

  List<Widget> _buildRatingBars(RatingStats stats) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return [5, 4, 3, 2, 1].map((stars) {
      final percentage = stats.starPercentages[stars] ?? 0.0;
      final count = stats.starCounts[stars] ?? 0;

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            SizedBox(
                width: 100.w,
                child: Text('${'⭐'} $stars Stars', style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black))),
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
                  style: TextStyle(fontSize: 14.sp,
                      color: isDark ? Colors.white : Colors.black)),
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

  Widget _programCard(String title) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: isDark ? Colors.grey[850] : Colors.grey[300],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      elevation: 1,
      child: ListTile(
        title: Text(
          title,
          style: GoogleFonts.inter(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.black),
        ),
      ),
    );
  }

  Future<void> _updateAverageRating(String nurseryId) async {
    try {
      final ratingsSnapshot = await FirebaseFirestore.instance
          .collection('ratings')
          .where('nurseryId', isEqualTo: nurseryId)
          .get();

      final ratings = ratingsSnapshot.docs;
      final stats = RatingStats.fromRatings(ratings);
      final averageRating = _calculateAverageRating(stats.starCounts);

      await FirebaseFirestore.instance
          .collection('nurseries')
          .doc(nurseryId)
          .update({
        'rating': widget.nursery.rating,
        'totalRatings': stats.totalRatings,
        "averageRating": averageRating
      });
    } catch (e) {
      print('Error updating average rating: $e');
    }
  }
}

class _UserAvatar extends StatelessWidget {
  final String? profileImageUrl;

  const _UserAvatar({required this.profileImageUrl});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 35.r,
      backgroundColor: Colors.transparent,
      backgroundImage: const AssetImage('assets/profile.jpg') as ImageProvider,
      child: ClipOval(
        child: SizedBox(
          width: 80.w,
          height: 80.h,
          child: CachedNetworkImage(
            imageUrl: profileImageUrl ?? '',
            fit: BoxFit.cover,
            placeholder: (context, url) => Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
            errorWidget: (context, url, error) => Icon(
              Icons.person,
              color: Theme.of(context).iconTheme.color?.withOpacity(0.5),
            ),
          ),
        ),
      ),
    );
  }
}

class MessageButton extends StatefulWidget {
  final NurseryProfile nursery;

  const MessageButton({
    super.key,
    required this.nursery,
  });

  @override
  State<MessageButton> createState() => _MessageButtonState();
}

class _MessageButtonState extends State<MessageButton> {
  bool _isLoading = false;

  Future<void> _handleMessageButtonPress() async {
    if (_isLoading) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please sign in to start chatting')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      await context.read<ChatCubit>().joinNurseryChat(
        widget.nursery.uid,
        user.uid,
      );

      if (!mounted) return;

      await Navigator.push(
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to start chat: ${e.toString()}')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: _handleMessageButtonPress,
      icon: _isLoading
          ? const SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : const Icon(
        LucideIcons.messageCircle,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}