import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';

class ShareBottomSheet extends StatelessWidget {
  const ShareBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.8,
      minChildSize: 0.2,
      maxChildSize: 0.8,
      expand: false,
      builder: (BuildContext context, ScrollController scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 60.w,
                  height: 4.h,
                  margin: EdgeInsets.symmetric(vertical: 4.h),
                  decoration: BoxDecoration(color: Colors.grey[800], borderRadius: BorderRadius.circular(4)),
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: const Text(
                  "Share To",
                  style: TextStyle(color: AppColor.primaryColor, fontSize: 18, fontWeight: FontWeight.w500, fontFamily: 'TikTokSansExpanded'),
                ),
              ),
              SizedBox(height: 16.h,),
              GridView.count(
                shrinkWrap: true,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                physics: const NeverScrollableScrollPhysics(),  
                crossAxisCount: 4
                // children: ,
              )
            ],
          ),
        );
      },
    );
  }
}



class _ShareOption{
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  _ShareOption(this.label, this.icon, this.onTap);
}

final List<_ShareOption> _ShareOptions = [
  // _ShareOption('WhatsApp', Icon(Icons.WhatsApp), (){}),

];
