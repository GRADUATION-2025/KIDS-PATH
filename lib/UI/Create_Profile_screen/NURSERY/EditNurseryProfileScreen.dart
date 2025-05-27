import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kidspath/LOGIC/Nursery/nursery_state.dart';
import 'package:kidspath/UI/GOOGLE_MAPS/GOOGLE_MAPS_LOCATION.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_NURSERY.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../../DATA MODELS/Nursery model/Nursery Model.dart';
import '../../../LOGIC/Nursery/nursery_cubit.dart';
import '../../../THEME/theme_provider.dart';


class EditNurseryProfileScreen extends StatefulWidget {
  final NurseryProfile nursery;
  final String role;
  final VoidCallback onProfileComplete;
  final bool fromRegistration;

  const EditNurseryProfileScreen({
    Key? key,
    required this.nursery,
    required this.role,
    required this.onProfileComplete,
    required this.fromRegistration,
  }) : super(key: key);

  @override
  _EditNurseryProfileScreenState createState() => _EditNurseryProfileScreenState();
}

class _EditNurseryProfileScreenState extends State<EditNurseryProfileScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _hoursController = TextEditingController();
  final TextEditingController _languageController = TextEditingController();
  final List<TextEditingController> _programControllers = [];
  File? _imageFile;
  bool _agreeToTerms = true;
  String _selectedAge=  "";



  @override
  void initState() {
    super.initState();
    _nameController.text = widget.nursery.name;
    _emailController.text = widget.nursery.email;
    _phoneController.text = widget.nursery.phoneNumber;
    _descriptionController.text = widget.nursery.description;
    _priceController.text = widget.nursery.price;
    _hoursController.text = widget.nursery.hours;
    _languageController.text = widget.nursery.language;
    _selectedAge = widget.nursery.age;


    // Initialize program controllers
    if (widget.nursery.programs.isNotEmpty) {
      for (var program in widget.nursery.programs) {
        _programControllers.add(TextEditingController(text: program));
      }
    } else {
      _programControllers.add(TextEditingController());
    }
  }

  void _addProgramField() {
    setState(() {
      _programControllers.add(TextEditingController());
    });
  }

  void _removeProgramField(int index) {
    if (_programControllers.length > 1) {
      setState(() {
        _programControllers.removeAt(index);
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please enter valid details")),
      );      return;
    }

    try {
      String? imageUrl;
      if (_imageFile != null) {
        final storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${widget.nursery.uid}.jpg');
        await storageRef.putFile(_imageFile!);
        imageUrl = await storageRef.getDownloadURL();
      }
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please agree to the Terms of Service")),
        );
        return;
      }

      final programs = _programControllers
          .map((controller) => controller.text.trim())
          .where((text) => text.isNotEmpty)
          .toList();

      await context.read<NurseryCubit>().updateNurseryData(
        uid: widget.nursery.uid,
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        description: _descriptionController.text.trim(),
        price: _priceController.text.trim(),
        hours: _hoursController.text.trim(),
        age: _selectedAge,
        language: _languageController.text.trim(),
        programs: programs,
        schedules: widget.nursery.schedules,
        calendar: widget.nursery.calendar,
        profileImageUrl: imageUrl,
        
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
      if(widget.fromRegistration) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => GoogleMapsLocationx(),));
      }
      else{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => BottombarNurseryScreen(),));
      }
      //widget.onProfileComplete();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.grey.shade900 : Colors.white,
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Edit Profile",
                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(fontSize: 32.sp, fontWeight: FontWeight.bold),
                  ),
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 50.r,
                        backgroundColor: Theme.of(context).cardColor,
                        backgroundImage: _getProfileImage(),
                        child: _imageFile == null && widget.nursery.profileImageUrl == null
                            ? Icon(Icons.business, size: 50, color: Theme.of(context).iconTheme.color?.withOpacity(0.5))
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 16.r,
                            backgroundColor: Theme.of(context).cardColor,
                            child: CircleAvatar(
                              radius: 14.r,
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
              SizedBox(height: 20.h),
              _buildFormField("Name", _nameController,"Your Nursery Name",maxlength: 18,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],keyboardtype: TextInputType.name,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Name' : null,),
              SizedBox(height: 20),
              _buildFormField("Email", _emailController,"Email", readOnly: true,),
              SizedBox(height: 20),
              _buildFormField("Phone number", _phoneController,"Phone Number",maxlength: 11,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],keyboardtype: TextInputType.phone,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Phone Number' : null,),
              SizedBox(height: 20),
              _buildFormField("Description", _descriptionController,"Describe your nursery", maxLines: 3,maxlength: 100,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Description' : null,),
              SizedBox(height: 20),
              _buildFormField("Interview Price", _priceController,"Interview Price",maxlength: 5,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],keyboardtype:TextInputType.number,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Interview Price' : null,),
              SizedBox(height: 20),
              _buildFormField("Operating Hours", _hoursController,"Operating Hours",maxlength: 10,keyboardtype: TextInputType.text,
                inputFormatters: [
                  FilteringTextInputFormatter.deny(RegExp(r'[a-zA-Z\s]'))],
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Hours' : null,),
              SizedBox(height: 20),
              _buildFormField("Language", _languageController,"Language",maxlength: 50,keyboardtype: TextInputType.text,
                  inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Languages' : null,),
              SizedBox(height: 20),
              _buildAgeGroupSelector(),

              // Programs Section - Added this part
              SizedBox(height: 20.h),
              Text("Programs", style: TextStyle(color: isDark ? Colors.white:Colors.grey,fontSize: 16)),
              ..._buildProgramFields(),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _addProgramField,
                  child: Text(
                    "+ Add Program",
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),

              SizedBox(height: 20.h),
              Row(
                children: [
                  Checkbox(
                    value: _agreeToTerms,
                    onChanged: (value) => setState(() => _agreeToTerms = value ?? false),
                    activeColor: Color(0xFF07C8F9),
                  ),
                  Text("I agree to the ", style: TextStyle(fontSize: 14.sp,color: isDark?Colors.white:Colors.black)),
                  Text(
                    "Terms of Service",
                    style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold,color: isDark?Colors.white:Colors.black),
                  ),
                ],
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                height: 50.h,
                  child: ElevatedButton(
                      onPressed: _saveProfile,
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      child: BlocBuilder<NurseryCubit, NurseryState>(
                          builder: (context, state) {
                            final isLoading = state is NurseryLoading;

                            return SizedBox(
                              width: double.infinity,
                              height: 50.h,
                              child: ElevatedButton(
                                onPressed: isLoading ? null : _saveProfile,
                                // Disable when loading
                                style: ElevatedButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                ),
                                child: Ink(
                                  decoration: BoxDecoration(
                                    gradient: AppGradients.Projectgradient
                                    ,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Container(
                                    width: double.infinity,
                                    height: 50.h,
                                    alignment: Alignment.center,
                                    child: isLoading
                                        ? SizedBox(
                                      width: 24.w,
                                      height: 24.h,
                                      child: CircularProgressIndicator(
                                          color: Colors.white
                                      ),
                                    )
                                        : Text(
                                      "Save Profile",
                                      style: TextStyle(
                                          fontSize: 18.sp, color: Colors.white),
                                    ),
                                  ),
                                ),

                              ),

                            );
                          }
                          )
                  )
              )
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildProgramFields() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return List<Widget>.generate(_programControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _programControllers[index],
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z\s]'))
                ],
                keyboardType: TextInputType.name,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter Programs' : null,
                style: TextStyle(color: isDark?Colors.white:Colors.black),
                decoration: InputDecoration(
                  hintText: "Enter program name",
                  hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () => _removeProgramField(index),
            ),
          ],
        ),
      );
    });
  }

  ImageProvider? _getProfileImage() {
    if (_imageFile != null) {
      return FileImage(_imageFile!);
    } else if (widget.nursery.profileImageUrl != null &&
        widget.nursery.profileImageUrl!.isNotEmpty) {
      return NetworkImage(widget.nursery.profileImageUrl!);
    }
    return null;
  }

  Widget _buildFormField(String label, TextEditingController controller, String hint,
      {bool readOnly = false, int maxLines = 1, maxlength, inputFormatters,keyboardtype,validator}) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: isDark ? Colors.white:Colors.grey,fontSize: 16.sp)),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxlength,
          readOnly: readOnly,
          inputFormatters: inputFormatters,
          keyboardType: keyboardtype,
          validator: validator,
          style: Theme.of(context).textTheme.bodyLarge,
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).dividerColor),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
            ),
            hintText: hint,
            hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).hintColor),
          ),
        ),
      ],
    );
  }


  Widget _buildAgeGroupSelector() {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;
    const ageGroups = {
      '6-12 Months': '6-12 Months',
      '1 year': '1 year',
      '2 years ': '2 years',
      '3 years ': '3 years',
      '4 years': '4 years',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Text("Age Group",style: TextStyle(color: isDark ? Colors.white:Colors.grey,fontSize: 16.sp)),
        Column(
          children: ageGroups.entries.map((entry) {
            return RadioListTile<String>(

              title: Text(entry.value,style: TextStyle(color: isDark ? Colors.white:Colors.grey,fontSize: 15.sp,fontWeight: FontWeight.bold),),
              value: entry.key,
              groupValue: _selectedAge,
              onChanged: (value) {
                setState(() {
                  _selectedAge = value!;
                });
              },
              activeColor: Colors.red,
              dense: true,
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ),
      ],
    );
  }


  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _hoursController.dispose();
    _languageController.dispose();
    for (var controller in _programControllers) {
      controller.dispose();
    }
    super.dispose();
  }
}