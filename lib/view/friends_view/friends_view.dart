import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FriendsView extends StatelessWidget {
  const FriendsView({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark
          ? SystemUiOverlayStyle
                .light // dark bg → white icons
          : SystemUiOverlayStyle.dark,
      child: Scaffold(body: Center(child: Text('Friends Screen'))),
    );
  }
}
