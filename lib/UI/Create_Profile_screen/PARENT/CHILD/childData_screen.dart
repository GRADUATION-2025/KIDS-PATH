import 'package:flutter/material.dart';
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
  final TextEditingController genderController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    ageController.dispose();
    genderController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      context.read<ChildCubit>().fetchChildren(user.uid);
    }
  }

  // Function to show the edit form with pre-populated data
  void _showEditForm(Child child) {
    nameController.text = child.name;
    ageController.text = child.age.toString();
    genderController.text = child.gender;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Child Data', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Name Field
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Child Name',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter name' : null,
                ),
                const Divider(),
                const SizedBox(height: 16),
                // Age Field
                TextFormField(
                  controller: ageController,
                  decoration: const InputDecoration(
                    labelText: 'Child Age',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  keyboardType: TextInputType.number,
                  style: const TextStyle(fontSize: 18),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter age' : null,
                ),
                const Divider(),
                const SizedBox(height: 16),
                // Gender Field
                TextFormField(
                  controller: genderController,
                  decoration: const InputDecoration(
                    labelText: 'Gender',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  ),
                  style: const TextStyle(fontSize: 18),
                  validator: (value) =>
                  value == null || value.isEmpty ? 'Enter gender' : null,
                ),
                const Divider(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
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

                  Child updatedChild = Child(
                    id: child.id,
                    name: nameController.text,
                    age: int.tryParse(ageController.text) ?? 0,
                    gender: genderController.text,
                  );

                  await context.read<ChildCubit>().updateChild(parentId, updatedChild);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Child info updated!')),
                  );

                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Function to show the add new child form
  void _showAddChildForm() {
    nameController.clear();
    ageController.clear();
    genderController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: AlertDialog(
              title: Text('Add New Child', style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
              content: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Name Field
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Child Name',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      style: const TextStyle(fontSize: 18),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter name' : null,
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Age Field
                    TextFormField(
                      controller: ageController,
                      decoration: const InputDecoration(
                        labelText: 'Child Age',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 18),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter age' : null,
                    ),
                    const Divider(),
                    const SizedBox(height: 16),
                    // Gender Field
                    TextFormField(
                      controller: genderController,
                      decoration: const InputDecoration(
                        labelText: 'Gender',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                      ),
                      style: const TextStyle(fontSize: 18),
                      validator: (value) =>
                      value == null || value.isEmpty ? 'Enter gender' : null,
                    ),
                    const Divider(),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
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
            
                      Child newChild = Child(
                        id: '',
                        name: nameController.text,
                        age: int.tryParse(ageController.text) ?? 0,
                        gender: genderController.text,
                      );
            
                      await context.read<ChildCubit>().addChild(parentId, newChild);
            
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Child info added!')),
                      );
            
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ),
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
          decoration:  BoxDecoration(
            gradient: AppGradients.Projectgradient

          ),
          child: AppBar(
            title: Text(
              "Child Data",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
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
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
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
                                onPressed: () {
                                  _showEditForm(child);
                                },
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
                    foregroundColor: Colors.white, backgroundColor: const Color(0xFF07C8F9), // Text color
                    padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                  ),
                  onPressed: _showAddChildForm,
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
