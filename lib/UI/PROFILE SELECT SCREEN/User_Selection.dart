import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


import '../Create_Profile_screen/NURSERY_PAGE.dart';
import '../Create_Profile_screen/PARENTS_PAGE.dart';


class UserSelection extends StatefulWidget {
  const UserSelection({super.key});

  @override
  State<UserSelection> createState() => _UserSelectionState();

}

class _UserSelectionState extends State<UserSelection> {
  String selectedOption = ''; // To track selected option

  void navigateToNextPage() {
    if (selectedOption == "Parent") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => ParentsPage()),
      );
    } else if (selectedOption == "Nursery") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => NurseryPage()),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            Expanded( // This centers the content vertically
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ensures tight wrapping
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "Continue as",
                          style: GoogleFonts.inter(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          "To continue to the next page, please\n"
                              "select which one you are",
                          style: GoogleFonts.inter(fontSize: 17),
                        ),
                      ],
                    ),

                    SizedBox(height: 50),

                    Center(
                      child: Column(
                        children: [
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "Parent";
                              });
                            },
                            child: Container(
                              height: 116.32,
                              width: 354.95,
                              decoration: BoxDecoration(
                                gradient: selectedOption == "Parent"
                                    ? LinearGradient(
                                  colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)], // Your gradient colors
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                                    : null, // No gradient when not selected
                                color: selectedOption == "Parent" ? null : Colors.white, // Default white color when not selected
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30, // Avatar size
                                  backgroundColor: Color(0xFF7AABFF), // Optional
                                  child: Container(
                                    width: 30,  // Custom width
                                    height:30, // Custom height
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/IMAGES/Icon User.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "Parent",
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  "I am a parent/guardian seeking care",
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                                ),
                                trailing: selectedOption == "Parent"
                                    ? Icon(Icons.check_circle, color: Color(0xFF4CD964))
                                    : null,
                              ),
                            ),
                          ),
                          SizedBox(height: 20),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedOption = "Nursery";
                              });
                            },
                            child: Container(
                              height: 116.32,
                              width: 354.95,
                              decoration: BoxDecoration(
                                gradient: selectedOption == "Nursery"
                                    ? LinearGradient(
                                  colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)], // Your gradient colors
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                )
                                    : null, // No gradient when not selected
                                color: selectedOption == "Nursery" ? null : Colors.white, // Default white color when not selected
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                leading: CircleAvatar(
                                  radius: 30, // Avatar size
                                  backgroundColor: Color(0xFFEFEFF4), // Optional
                                  child: Container(
                                    width: 30,  // Custom width
                                    height:30, // Custom height
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage('assets/IMAGES/nursery.png'),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  "Nursery",
                                  style: GoogleFonts.inter(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                subtitle: Text(
                                  "I am a preschool & day care provider",
                                  style: GoogleFonts.inter(fontSize: 14, color: Colors.black),
                                ),
                                trailing: selectedOption == "Nursery"
                                    ? Icon(Icons.check_circle, color: Color(0xFF4CD964))
                                    : null,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

        bottomNavigationBar: Padding(
          padding: EdgeInsets.all(35.0),
          child: SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: selectedOption.isNotEmpty ? navigateToNextPage : null,
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: EdgeInsets.zero, // Ensures no extra padding that cuts off the gradient
                backgroundColor: Colors.transparent, // Removes default button color
                shadowColor: Colors.transparent, // Removes unwanted shadow
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF07C8F9), Color(0xFF0D41E1)], // Your gradient colors
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),

              child: Container(
                alignment: Alignment.center,
                child: Text(
                  "Continue",
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ),
      ));
  }
}
