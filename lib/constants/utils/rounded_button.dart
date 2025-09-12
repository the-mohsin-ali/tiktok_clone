import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RoundedButton extends StatelessWidget {
  final String title;
  final Color color;
  final Color titelColor;
  final VoidCallback onTap;
  final double height;
  final double width;

  RoundedButton({
    super.key,
    required this.titelColor,
    required this.title,
    required this.color,
    required this.onTap,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(color: titelColor, fontSize: 18.w, fontFamily: 'TiktokSansExpanded', fontWeight: FontWeight.w500),
          ),
        ),
      ),
    );
  }
}
