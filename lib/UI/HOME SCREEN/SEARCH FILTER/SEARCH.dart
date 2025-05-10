import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:kidspath/UI/HOME%20SCREEN/home.dart';
import 'package:kidspath/WIDGETS/BOTTOM%20NAV%20BAR/BTM_BAR_NAV_PARENT.dart';
import '../../../DATA MODELS/search filter/filter.dart';
import '../../../WIDGETS/GRADIENT_COLOR/gradient _color.dart';
import 'SEARCH_RESULTS.dart';

class SearchFilterScreen extends StatefulWidget {

  const SearchFilterScreen({super.key,});

  @override
  State<SearchFilterScreen> createState() => _SearchFilterScreenState();
}

class _SearchFilterScreenState extends State<SearchFilterScreen> {
  bool showNearby = false;
  String sortBy = 'Star Rating (highest first)';
  String ageOfChildren = '';
  String opening = '';
  String schedule = '';
  bool anyHours = true;
  TimeOfDay startTime = const TimeOfDay(hour: 6, minute: 0);
  TimeOfDay endTime = const TimeOfDay(hour: 13, minute: 0);
  bool overnight = false;
  bool weekend = false;
  bool afterCare = false;
  String curriculum = 'Traditional';
  RangeValues priceRange = const RangeValues(5000, 10000);
  RangeValues time = const RangeValues(8,20);
  int starRating = 1;

  final List<String> sortOptions = [
    'Popularity',
    'Star Rating (highest first)',
    'Star Rating (lowest first)',
    'Best Reviewed First',
    'Price (lowest first)',
    'Price (highest first)',
  ];
  String _formatHourLabel(double hour) {
    int h = hour.toInt();
    if (h == 0) return '12 AM';  // Midnight (12 AM)
    if (h == 12) return '12 PM'; // Noon (12 PM)
    return '${h % 12} ${h < 12 ? 'AM' : 'PM'}'; // AM or PM based on the hour
  }

  final List<String> ages = [
    '6 - 12 mo', '1 year', '2 years', '3 years', '4 years', '5+ years'
  ];




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Search',
          style: GoogleFonts.inter(
            fontSize: 25,
            foreground: Paint()
              ..shader = AppGradients.Projectgradient.createShader(
                Rect.fromLTWH(0.0, 0.0, 200.0, 70.0),
              ),
          ),
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8.0),
          child: InkWell(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => BottombarParentScreen()),
                  (route)=>false
              );
            },
            child: Icon(Icons.arrow_back, size: 30),
          ),
        ),
        leadingWidth: 35,
        actions: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextButton(
              onPressed: () => setState(() {
                showNearby = false;
                sortBy = "";
                ageOfChildren = '';
                opening = '';
                schedule = '';
                anyHours = true;
                startTime = const TimeOfDay(hour: 6, minute: 0);
                endTime = const TimeOfDay(hour: 13, minute: 0);
                overnight = false;
                weekend = false;
                afterCare = false;
                curriculum = '';
                priceRange = const RangeValues(5000, 10000);
                time = const RangeValues(8,20);
                starRating = 1;
              }),
              child: Text('Reset',
                  style: GoogleFonts.inter(fontSize: 15.sp, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(10),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("Nearby", style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              SwitchListTile(
                title: Text('Show Nearby'),
                value: showNearby,
                onChanged: (val) => setState(() => showNearby = val),
              ),
              Divider(height: 3),
              SizedBox(height: 15),
              Text('Sort Options', style: GoogleFonts.inter(fontSize: 20, fontWeight: FontWeight.bold)),
              ...sortOptions.map((option) => RadioListTile(
                title: Text(option),
                value: option,
                groupValue: sortBy,
                onChanged: (val) => setState(() => sortBy = val!),
              )),
              Divider(),
              Text(
                'Age Of Children',
                style: GoogleFonts.inter(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              GridView.builder(
                itemCount: ages.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8,  // iOS feel: not too tight
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.4, // uniform chip shape
                ),
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) {
                  final age = ages[index];
                  final isSelected = ageOfChildren == age;
                  return GestureDetector(
                      onTap: () => setState(() => ageOfChildren = age),
                  child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                  color: isSelected ? Colors.transparent : Colors.transparent,
                  border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey.shade400,
                  width: 1.2,
                  ),
                  borderRadius: BorderRadius.circular(12), // rounded iOS-style
                  ),
                  child: Text(age,
                  style: GoogleFonts.inter
              (fontSize: 20,fontWeight: FontWeight.w500,color: isSelected ? Colors.blue : Colors.black87,)

                  ),
                      ),
                  );
                },
              ),
              Divider(),
              Text('Openings',
                style:GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold) ,),
              RadioListTile(
                title: Text('Immediate'),
                value: 'Immediate',
                groupValue: opening,
                onChanged: (val) => setState(() => opening = val!),
              ),
              Divider(),
              RadioListTile(
                title: Text('Upcoming'),
                value: 'Upcoming',
                groupValue: opening,
                onChanged: (val) => setState(() => opening = val!),
              ),
              Divider(),
              Text('Schedule',
              style: GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold),),
              RadioListTile(
                title: Text('Full Time'),
                value: 'Full Time',
                groupValue: schedule,
                onChanged: (val) => setState(() => schedule = val!),
              ),
              RadioListTile(
                title: Text('Part Time'),
                value: 'Part Time',
                groupValue: schedule,
                onChanged: (val) => setState(() => schedule = val!),
              ),
              RadioListTile(
                title: Text('Drop In'),
                value: 'Drop In',
                groupValue: schedule,
                onChanged: (val) => setState(() => schedule = val!),
              ),
              Divider(),
              Text('Hours',
                style: GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold),),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text('Any Hours',
                  style:GoogleFonts.inter(fontSize: 20.sp) ,),
              ),
              RangeSlider(
                min: 8,    // Starting at 8 AM
                max: 20,   // Ending at 8 PM (20:00)
                divisions: 12,  // 12 steps from 8 AM to 8 PM
                values: time,
                labels: RangeLabels(
                  _formatHourLabel(time.start),  // Format the start time
                  _formatHourLabel(time.end),    // Format the end time
                ),
                onChanged: (values) => setState(() => time = values),
              ),
              CheckboxListTile(
                title: Text('Overnight'),
                value: overnight,
                onChanged: (val) => setState(() => overnight = val!),
              ),
              CheckboxListTile(
                title: Text('Weekend'),
                value: weekend,
                onChanged: (val) => setState(() => weekend = val!),
              ),
              CheckboxListTile(
                title: Text('After Care'),
                value: afterCare,
                onChanged: (val) => setState(() => afterCare = val!),
              ),
              Divider(),
              Text('Curriculum',
                style:GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold) ,),
              RadioListTile(
                title: Text('Traditional'),
                value: 'Traditional',
                groupValue: curriculum,
                onChanged: (val) => setState(() => curriculum = val!),
              ),
              RadioListTile(
                title: Text('Mandatory'),
                value: 'Mandatory',
                groupValue: curriculum,
                onChanged: (val) => setState(() => curriculum = val!),
              ),
              Divider(),
              Text('Price Range',
                style:GoogleFonts.inter(fontSize:20.sp,fontWeight: FontWeight.bold ) ,),
              RangeSlider(
                min: 5000,
                max: 10000,
                divisions: 10,
                values: priceRange,
                labels: RangeLabels(
                  '${priceRange.start.toInt()}EG',
                  '${priceRange.end.toInt()}EG',
                ),
                onChanged: (values) => setState(() => priceRange = values),
              ),
              Divider(),
              Text('Star Rating',
                style:GoogleFonts.inter(fontSize: 20.sp,fontWeight: FontWeight.bold) ,),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(5, (index) => ChoiceChip(
                  label: Text('${index + 1} ⭐'),
                  selected: starRating == index + 1,
                  onSelected: (_) => setState(() => starRating = index + 1),
                )),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      final filterParams = FilterParams(
                        minRating: starRating.toDouble(),
                        priceRange: priceRange,
                        ageGroup: ageOfChildren,
                        schedule: schedule,
                        curriculum: curriculum,
                        startTime: startTime.hour + startTime.minute/60,
                        endTime: endTime.hour + endTime.minute/60,
                        overnight: overnight,
                        weekend: weekend,
                        afterCare: afterCare,
                      );

                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FilterResultsScreen(filters: filterParams,),




                       ));},
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 3
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: AppGradients.Projectgradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      alignment: Alignment.center,
                      child:  Text(
                        'Apply Filters',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
      ])));



  }
}