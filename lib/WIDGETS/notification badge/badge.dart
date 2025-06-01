import 'package:flutter/material.dart';

class BadgeCount extends StatelessWidget {
  final int count;
  final double? size;

  const BadgeCount({
    Key? key,
    required this.count,
    this.size = 25,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate dynamic width based on digit count
    final digitCount = count.toString().length;
    final dynamicWidth = size! * (0.6 + digitCount * 0.2);
/////////////////////////////////////////////////////////////
    return Container(
      width: dynamicWidth, // Dynamic width based on number length
      height: size,
      decoration: BoxDecoration(
        color: Colors.red,
        borderRadius: BorderRadius.circular(size! / 2), // Fully rounded ends
        border: Border.all(
          color: Theme.of(context).scaffoldBackgroundColor,
          width: 1.5,
        ),
      ),
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              count.toString(), // Show full count without limit
              style: TextStyle(
                color: Colors.white,
                fontSize: size! * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}