
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';

import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';
import 'dart:io';

import '../../../DATA MODELS/Parent Model/Parent Model.dart';
import '../../../LOGIC/Parent/parent_cubit.dart';
import '../../../LOGIC/Parent/parent_state.dart';
import '../../../LOGIC/image/profile_service.dart';
import '../../GOOGLE_MAPS/GOOGLE_MAPS_LOCATION.dart';


class EditProfileScreen extends StatefulWidget {
  final Parent parent;
  final String role;
  final VoidCallback onProfileComplete;
  final bool fromRegistration;


  EditProfileScreen({
    super.key,
    required this.parent,
    required this.role,
    required this.onProfileComplete,
    required this.fromRegistration,
  });

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  File? _imageFile;
  final ProfileService _profileService = ProfileService();



  @override
  void initState() {
    super.initState();
    _nameController.text = widget.parent.name;
    _phoneController.text = widget.parent.phoneNumber ?? "";
  }

  Future<void> _pickImage() async {
    final pickedFile = await _profileService.pickImage();
    if (pickedFile != null) {
      setState(() {
        _imageFile = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    if (newName.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details")),
      );
      return;
    }
    try {
      String? imageUrl;
      if (_imageFile != null) {
        imageUrl = await _profileService.uploadProfileImage(widget.parent.uid, _imageFile!);
      }
      final parentCubit = context.read<ParentCubit>();
      await parentCubit.updateParentName(widget.parent.uid, newName);
      await parentCubit.updatePhoneNumber(widget.parent.uid, newPhone);
      if (imageUrl != null) {
        await parentCubit.updateProfileImage(widget.parent.uid, imageUrl);
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),

      );

      if(widget.fromRegistration) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => GoogleMapsLocationx(),));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottombarParentScreen(),));
      }

      //widget.onProfileComplete();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Edit Profile",
                  style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                ),
                Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: Colors.grey[300],
                      backgroundImage: _imageFile != null
                          ? FileImage(_imageFile!)
                          : widget.parent.profileImageUrl != null
                          ? NetworkImage(widget.parent.profileImageUrl!)
                          : null,
                      child: _imageFile == null && widget.parent.profileImageUrl == null
                          ? Icon(Icons.person, size: 50, color: Colors.white)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 14,
                            backgroundColor: Color(0xFF07C8F9),
                            child: Icon(Icons.add, color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Name", style: TextStyle(color: Colors.grey, fontSize: 16)),
            TextField(
              controller: _nameController,
              keyboardType: TextInputType.text,
              maxLength: 17,
              inputFormatters: [
                FilteringTextInputFormatter.singleLineFormatter
              ],

              decoration: InputDecoration(border: UnderlineInputBorder(),hintText: "Ex: John Mark",hintStyle: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
            SizedBox(height: 20),
            Text("Email", style: TextStyle(color: Colors.grey, fontSize: 16)),
            TextField(
              controller: TextEditingController(text: widget.parent.email),
              decoration: InputDecoration(border: UnderlineInputBorder()),
              readOnly: true,
            ),
            SizedBox(height: 20),
            Text("Phone number", style: TextStyle(color: Colors.grey, fontSize: 16)),
            TextField(
              controller: _phoneController,
              keyboardType:TextInputType.number ,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly
              ],
              decoration: InputDecoration(border: UnderlineInputBorder(),hintText: "Ex: 015501478874",hintStyle: TextStyle(color: Colors.grey, fontSize: 15)),
            ),
            SizedBox(height: 20),
            Row(
              children: [
                Checkbox(
                  value: true,
                  onChanged: (value) {},
                  activeColor: Color(0xFF07C8F9),
                ),
                Text("I agree to the ", style: TextStyle(fontSize: 14)),
                Text(
                  "Terms of Service",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveProfile,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
child: BlocBuilder<ParentCubit, ParentState>(
  builder: (context, state) {
    final isLoading = state is ParentLoading;

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton(
        onPressed: isLoading ? null : _saveProfile, // Disable when loading
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Ink(
          decoration: BoxDecoration(
            gradient: AppGradients.Projectgradient
            ,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.center,
            child: isLoading
                ? SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white
                    ),
                  )
                : Text(
                    "Save Profile",
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
          ),
        ),
      ),
    );
  },
),

    )
            )
          ]
        )
      )
    );
  }

}
