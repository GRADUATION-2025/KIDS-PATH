import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class NurseryImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ImagePicker _picker = ImagePicker();

  Future<List<String>> uploadNurseryImages({
    required String nurseryId,
    required List<File> imageFiles,
    Function(double)? onUploadProgress,
  }) async {
    List<String> downloadUrls = [];

    try {
      for (int i = 0; i < imageFiles.length; i++) {
        String fileName = 'image_${DateTime.now().millisecondsSinceEpoch}_$i.jpg';
        Reference ref = _storage.ref('nursery_images/$nurseryId/$fileName');

        UploadTask uploadTask = ref.putFile(imageFiles[i]);

        if (onUploadProgress != null) {
          uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
            double progress = snapshot.bytesTransferred / snapshot.totalBytes;
            onUploadProgress(progress);
          });
        }

        TaskSnapshot snapshot = await uploadTask;
        String downloadURL = await snapshot.ref.getDownloadURL();
        downloadUrls.add(downloadURL);
      }
      return downloadUrls;
    } catch (e) {
      print('Error uploading images: $e');
      throw Exception('Failed to upload images: $e');
    }
  }

  Future<List<String>> getNurseryImages(String nurseryId) async {
    try {
      ListResult result = await _storage.ref('nursery_images/$nurseryId').listAll();
      return await Future.wait(
          result.items.map((ref) => ref.getDownloadURL()).toList()
      );
    } catch (e) {
      print('Error fetching images: $e');
      return [];
    }
  }

  Future<List<File>> pickMultipleImages() async {
    try {
      final pickedFiles = await _picker.pickMultiImage(
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 85,
      );

      if (pickedFiles == null) return [];
      return pickedFiles.map((file) => File(file.path)).toList();
    } catch (e) {
      print('Error picking images: $e');
      throw Exception('Failed to pick images: $e');
    }
  }

  Future<void> deleteImage(String imageUrl) async {
    try {
      Reference ref = _storage.refFromURL(imageUrl);
      await ref.delete();
    } catch (e) {
      print('Error deleting image: $e');
      throw Exception('Failed to delete image');
    }
  }
}