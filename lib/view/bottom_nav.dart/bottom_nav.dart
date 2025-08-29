import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:tiktok_clone/constants/color/app_color.dart';
import 'package:tiktok_clone/view/bottom_nav.dart/bottom_nav_controller.dart';

class BottomNav extends GetView<BottomNavController> {
  const BottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      // ignore: deprecated_member_use
      onPopInvoked: (didPop) {
        if (controller.selectedTabIndex.value == 1 ||
            controller.selectedTabIndex.value == 2 ||
            controller.selectedTabIndex.value == 3 ||
            controller.selectedTabIndex.value == 4) {
          controller.selectedTabIndex.value = 0;
          log(controller.selectedTabIndex.value.toString());
          // controller.pages[0];
        } else if (controller.selectedTabIndex.value == 0) {
          SystemNavigator.pop();
        }
      },
      child: Scaffold(
        body: Obx(() => controller.pages[controller.selectedTabIndex.value]),
        floatingActionButton: FloatingActionButton(
          heroTag: 'bottom_nav_fab',
          onPressed: () {
            // Get.find<ThemeController>().changeTheme;
            Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
          },
        ),
        bottomNavigationBar: Obx(() {
          // final isDark = Theme.of(context).brightness == Brightness.dark;
          final bottomBarTheme = controller.selectedTabIndex.value == 0 ? ThemeData.dark() : Theme.of(context);
          return Theme(
            data: bottomBarTheme,
            child: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              onTap: controller.changeTabIndex,
              currentIndex: controller.selectedTabIndex.value,
              selectedItemColor: bottomBarTheme.brightness == Brightness.dark ? Colors.white : Colors.black,
              unselectedItemColor: AppColor.buttonInactiveColor,
              // backgroundColor: Colors.black,
              items: [
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/home.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.buttonInactiveColor, BlendMode.srcIn)
                        : null,
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icons/home_filled.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn)
                        : null,
                  ),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/friends.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.buttonInactiveColor, BlendMode.srcIn)
                        : null,
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icons/friends_filled.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn)
                        : null,
                  ),
                  label: 'Friends',
                ),
                BottomNavigationBarItem(
                  icon: bottomBarTheme.brightness == Brightness.dark
                      ? SvgPicture.asset('assets/icons/create_button_dark.svg')
                      : SvgPicture.asset('assets/icons/create_button_light.svg'),
                  label: 'Create',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/inbox.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.buttonInactiveColor, BlendMode.srcIn)
                        : null,
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icons/inbox_filled.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn)
                        : null,
                  ),
                  label: 'Inbox',
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    'assets/icons/profile.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.buttonInactiveColor, BlendMode.srcIn)
                        : null,
                  ),
                  activeIcon: SvgPicture.asset(
                    'assets/icons/profile_icon_filled.svg',
                    colorFilter: bottomBarTheme.brightness == Brightness.dark
                        ? ColorFilter.mode(AppColor.secondaryColor, BlendMode.srcIn)
                        : null,
                  ),
                  label: 'Profile',
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
