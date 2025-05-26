import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';

import '../../../../DATA MODELS/Child Model/Child Model.dart';
import '../../../../LOGIC/child/child_cubit.dart';
import '../../../../LOGIC/child/child_state.dart';
import '../../../../THEME/theme_provider.dart';

class ChildDataScreen extends StatefulWidget {
  const ChildDataScreen({super.key});

  @override
  State<ChildDataScreen> createState() => _ChildDataScreenState();
}

class _ChildDataScreenState extends State<ChildDataScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  String? selectedGender;

  final List<String> genderOptions = ['Male', 'Female'];

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ChildCubit>().fetchChildren(user.uid);
    }
    selectedGender = null; // start with no selection
  }

  void _showChildForm({Child? child}) {
    final isEditing = child != null;
    final isDark = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;

    if (isEditing) {
      nameController.text = child.name;
      ageController.text = child.age.toString();
      selectedGender = child?.gender;
    } else {
      nameController.clear();
      ageController.clear();
      selectedGender = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: isDark ? Colors.grey[850] : Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titlePadding: const EdgeInsets.all(0),
          title: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(isEditing ? Icons.edit : Icons.person_add, color: Colors.white),
                SizedBox(width: 10.w),
                Text(
                  isEditing ? 'Edit Child' : 'Add New Child',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18.sp),
                ),
              ],
            ),
          ),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 10.h),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    maxLength: 42,
                    inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.person, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      labelText: 'Child Name',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.blue[400]! : Colors.blue),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  SizedBox(height: 16.h),
                  TextFormField(
                    controller: ageController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.cake, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      labelText: 'Child Age',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12.r)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.blue[400]! : Colors.blue),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    validator: (value) => value == null || value.isEmpty ? 'Enter age' : null,
                  ),
                  SizedBox(height: 16.h),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    isExpanded: true,
                    hint: Text(
                      'Select Gender',
                      style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    ),
                    items: genderOptions.map((gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          gender,
                          style: GoogleFonts.poppins(
                            fontSize: 16.sp,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedGender = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Gender',
                      labelStyle: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      prefixIcon: Icon(Icons.wc, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.blue[400]! : Colors.blue),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                        borderSide: BorderSide(color: isDark ? Colors.grey[700]! : Colors.grey[300]!),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[50],
                    ),
                    icon: Icon(Icons.arrow_drop_down, color: isDark ? Colors.grey[400] : Colors.grey[600]),
                    dropdownColor: isDark ? Colors.grey[850] : Colors.white,
                    style: GoogleFonts.poppins(color: isDark ? Colors.white : Colors.black),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12.r),
                    validator: (value) => value == null || value.isEmpty ? 'Select gender' : null,
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel', style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey[600])),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0D41E1),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final user = FirebaseAuth.instance.currentUser;
                  final parentId = user?.uid;

                  if (parentId == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('User not logged in')),
                    );
                    return;
                  }

                  final childData = Child(
                    id: isEditing ? child!.id : '',
                    name: nameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    gender: selectedGender!,
                  );

                  if (isEditing) {
                    await context.read<ChildCubit>().updateChild(parentId, childData);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child updated!')));
                  } else {
                    await context.read<ChildCubit>().addChild(parentId, childData);
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Child added!')));
                  }

                  Navigator.pop(context);
                }
              },
              child: Text(
                isEditing ? 'Save' : 'Add',
                style: GoogleFonts.inter(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Provider.of<ThemeProvider>(context).isDarkMode;
    
    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: AppGradients.Projectgradient),
          child: AppBar(
            title: Text(
              "Child Data",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 22.sp, fontWeight: FontWeight.bold),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.white),
          ),
        ),
      ),
      body: BlocConsumer<ChildCubit, ChildState>(
        listener: (context, state) {
          if (state is ChildError) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: ListView(
              children: [
                if (state is ChildLoading)
                  Center(child: CircularProgressIndicator(
                    color: isDark ? Colors.blue[400] : Colors.blue,
                  )),
                if (state is ChildLoaded)
                  ...state.children.map(
                    (child) => Card(
                      elevation: 5,
                      margin: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(15.r),
                        ),
                        child: ListTile(
                          title: Text(
                            child.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18.sp,
                            ),
                          ),
                          subtitle: Text(
                            'Age: ${child.age}\nGender: ${child.gender}',
                            style: GoogleFonts.poppins(
                              color: Colors.white70,
                              fontSize: 16,
                            ),
                          ),
                          contentPadding: const EdgeInsets.all(16),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.white),
                                onPressed: () => _showChildForm(child: child),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.white),
                                onPressed: () async {
                                  final user = FirebaseAuth.instance.currentUser;
                                  final parentId = user?.uid;

                                  if (parentId != null) {
                                    await context.read<ChildCubit>().deleteChild(parentId, child.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Child deleted!')),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                SizedBox(height: 20.h),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF07C8F9),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                  onPressed: () => _showChildForm(),
                  child: Text(
                    "Add New Child",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
