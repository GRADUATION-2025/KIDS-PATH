import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kidspath/WIDGETS/GRADIENT_COLOR/gradient%20_color.dart';

import '../../../../DATA MODELS/Child Model/Child Model.dart';
import '../../../../LOGIC/child/child_cubit.dart';
import '../../../../LOGIC/child/child_state.dart';

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

    if (isEditing) {
      nameController.text = child.name;
      ageController.text = child.age.toString();
      selectedGender = child?.gender; // set from existing child or null
    } else {
      nameController.clear();
      ageController.clear();
      selectedGender = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
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
                const SizedBox(width: 10),
                Text(
                  isEditing ? 'Edit Child' : 'Add New Child',
                  style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
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
                  const SizedBox(height: 10),
                  TextFormField(
                    controller: nameController,
                    keyboardType: TextInputType.name,
                    maxLength: 42,
                      inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.person),
                      labelText: 'Child Name',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    validator: (value) => value == null || value.isEmpty ? 'Enter name' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: ageController,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.cake),
                      labelText: 'Child Age',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    validator: (value) => value == null || value.isEmpty ? 'Enter age' : null,
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: selectedGender,
                    isExpanded: true,
                    hint: Text(
                      'Select Gender',
                      style: GoogleFonts.inter(color: Colors.black),
                    ),
                    items: genderOptions.map((gender) {
                      return DropdownMenuItem<String>(
                        value: gender,
                        child: Text(
                          gender,
                          style: GoogleFonts.poppins(fontSize: 16),
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
                      prefixIcon: const Icon(Icons.wc),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down),
                    dropdownColor: Colors.white,
                    style: GoogleFonts.poppins(color: Colors.black),
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    validator: (value) => value == null || value.isEmpty ? 'Select gender' : null,
                  )
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
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
              child: Text(isEditing ? 'Save' : 'Add',style: GoogleFonts.inter(color: Colors.white,fontWeight: FontWeight.bold),),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Container(
          decoration: BoxDecoration(gradient: AppGradients.Projectgradient),
          child: AppBar(
            title: Text(
              "Child Data",
              style: GoogleFonts.poppins(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
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
                  const Center(child: CircularProgressIndicator()),
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
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            child.name,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
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
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xFF07C8F9),
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.0)),
                  ),
                  onPressed: () => _showChildForm(),
                  child: const Text(
                    "Add New Child",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
