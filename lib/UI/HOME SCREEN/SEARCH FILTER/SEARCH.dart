// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:kidspath/UI/HOME%20SCREEN/home.dart';
// import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';
// import '../../../DATA MODELS/search filter/filter.dart';
// import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
// import 'SEARCH_RESULTS.dart';
//
// class SearchFilterScreen extends StatefulWidget {
//
//   const SearchFilterScreen({super.key,});
//
//   @override
//   State<SearchFilterScreen> createState() => _SearchFilterScreenState();
//
// }
//
// class _SearchFilterScreenState extends State<SearchFilterScreen> {
//   bool showNearby = false;
//   String ageOfChildren = '';
//   RangeValues? priceRange;
//   int starRating = 0;
//
//
//
//
//   final List<String> ages = [
//     '6 - 12 mo', '1 year', '2 years', '3 years', '4 years', '5+ years'
//   ];
//
//
//
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       appBar: AppBar(
//         backgroundColor: Colors.white,
//         title: Text(
//           'Search',
//           style: GoogleFonts.inter(
//             fontSize: 25,
//             foreground: Paint()
//               ..shader = AppGradients.Projectgradient.createShader(
//                 Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
//               ),
//           ),
//         ),
//         leading: Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: InkWell(
//             onTap: () {
//               Navigator.pushAndRemoveUntil(
//                 context,
//                 MaterialPageRoute(builder: (context) => BottombarParentScreen()),
//                   (route)=>false
//               );
//             },
//             child: Icon(Icons.arrow_back, size: 30),
//           ),
//         ),
//         leadingWidth: 35,
//         actions: [
//           Padding(
//             padding: EdgeInsets.all(10.0),
//             child: TextButton(
//               onPressed: () => setState(() {
//                 showNearby = false;
//                 ageOfChildren = '';
//                 priceRange = const RangeValues(5000, 10000);
//
//                 starRating = 0;
//               }),
//               child: Text('Reset',
//                   style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold)),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         padding: EdgeInsets.all(10),
//         child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text("Nearby", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
//               SwitchListTile(
//                 title: Text('Show Nearby'),
//                 value: showNearby,
//                 onChanged: (val) => setState(() => showNearby = val),
//               ),
//               Divider(),
//               Text(
//                 'Age Of Children',
//                 style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold),
//               ),
//               SizedBox(height: 10),
//               GridView.builder(
//                 itemCount: ages.length,
//                 gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                   crossAxisCount: 2,
//                   crossAxisSpacing: 8,  // iOS feel: not too tight
//                   mainAxisSpacing: 8,
//                   childAspectRatio: 2.4, // uniform chip shape
//                 ),
//                 shrinkWrap: true,
//                 physics: NeverScrollableScrollPhysics(),
//                 itemBuilder: (context, index) {
//                   final age = ages[index];
//                   final isSelected = ageOfChildren == age;
//                   return GestureDetector(
//                       onTap: () => setState(() => ageOfChildren = age),
//                   child: Container(
//                   alignment: Alignment.center,
//                   decoration: BoxDecoration(
//                   color: isSelected ? Colors.transparent : Colors.transparent,
//                   border: Border.all(
//                   color: isSelected ? Colors.blue : Colors.grey.shade400,
//                   width: 1.2,
//                   ),
//                   borderRadius: BorderRadius.circular(12), // rounded iOS-style
//                   ),
//                   child: Text(age,
//                   style: GoogleFonts.inter
//               (fontSize: 20,fontWeight: FontWeight.w500,color: isSelected ? Colors.blue : Colors.black87,)
//
//                   ),
//                       ),
//                   );
//                 },
//               ),
//
//               Divider(),
//               Text('Price Range',
//                 style:GoogleFonts.inter(fontSize:20.sp,fontWeight: FontWeight.bold ) ,),
//               RangeSlider(
//                 min: 5000,
//                 max: 10000,
//                 divisions: 10,
//                 values: priceRange ?? const RangeValues(5000, 10000),
//                 labels: RangeLabels(
//                   '${priceRange?.start.toInt()}EG',
//                   '${priceRange?.end.toInt()}EG',
//                 ),
//                 onChanged: (values) => setState(() => priceRange = values),
//               ),
//               Divider(),
//               Text('Star Rating',
//                 style:GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold) ,),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: List.generate(5, (index) => ChoiceChip(
//                   label: Text('${index + 1} ⭐'),
//                   selected: starRating == index + 1,
//                   onSelected: (_) => setState(() => starRating = index + 1),
//                 )),
//               ),
//               SizedBox(height: 20),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
//                 child: SizedBox(
//                   width: double.infinity,
//                   height: 50,
//                   child: ElevatedButton(
//                     onPressed: () {
//                       // Convert star rating only if > 0
//                       final double? ratingFilter = starRating > 0 ? starRating.toDouble() : null;
//
//                       // Check if price range is different from default
//                       final bool isPriceFilterActive =
//                           (priceRange?.start != 5000 || priceRange?.end != 10000) ?? false;
//                       // Create filters only if values are selected
//                       final filterParams = FilterParams(
//                         minRating: starRating > 0 ? starRating.toDouble() : null,
//                         priceRange: isPriceFilterActive ? priceRange : null,
//                         ageGroup: ageOfChildren.isNotEmpty ? ageOfChildren : null,
//                       );
//
//                       // Add this validation
//                       if (filterParams.minRating == null &&
//                           filterParams.priceRange == null &&
//                           filterParams.ageGroup == null) {
//                         showDialog(
//                           context: context,
//                           builder: (ctx) => AlertDialog(
//                             title: Text('No Filters Selected', style: GoogleFonts.inter()),
//                             content: Text('Please select at least one filter', style: GoogleFonts.inter()),
//                             actions: [
//                               TextButton(
//                                 onPressed: () => Navigator.pop(ctx),
//                                 child: Text('OK', style: GoogleFonts.inter(
//                                   fontWeight: FontWeight.bold,
//                                   foreground: Paint()
//                                     ..shader = AppGradients.Projectgradient.createShader(
//                                       Rect.fromLTWH(0.0, 0.0, 100.0, 20.0),
//                                     ),
//                                 )),
//                               )
//                             ],
//                           ),
//                         );
//                         return;
//                       }
//
//                       Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (context) => FilterResultsScreen(filters: filterParams),
//
//
//
//
//                        ));},
//                     style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.transparent,
//                         shadowColor: Colors.transparent,
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(12),
//                         ),
//                         elevation: 3
//                     ),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         gradient: AppGradients.Projectgradient,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       alignment: Alignment.center,
//                       child:  Text(
//                         'Apply Filters',
//                         style: TextStyle(
//                           fontSize: 16.sp,
//                           fontWeight: FontWeight.bold,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//               ),
//       ])));
//
//
//
//   }
// }