import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyboardAnimationHandler {
  static const Duration _animationDuration = Duration(milliseconds: 250);
  static const Curve _animationCurve = Curves.easeOutQuart;

  static void optimizeKeyboardPerformance() {
    // Disable expensive operations during keyboard animation
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );
  }

  static Widget buildKeyboardAwareWidget({required Widget child, required BuildContext context}) {
    return AnimatedPadding(
      duration: _animationDuration,
      curve: _animationCurve,
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: child,
    );
  }
}

// Custom widget for better keyboard handling
class KeyboardOptimizedBottomSheet extends StatefulWidget {
  final Widget child;
  final double initialChildSize;
  final double minChildSize;
  final double maxChildSize;

  const KeyboardOptimizedBottomSheet({
    super.key,
    required this.child,
    this.initialChildSize = 0.6,
    this.minChildSize = 0.3,
    this.maxChildSize = 0.9,
  });

  @override
  State<KeyboardOptimizedBottomSheet> createState() => _KeyboardOptimizedBottomSheetState();
}

class _KeyboardOptimizedBottomSheetState extends State<KeyboardOptimizedBottomSheet> with TickerProviderStateMixin {
  late AnimationController _keyboardAnimationController;
  late Animation<double> _keyboardAnimation;
  double _keyboardHeight = 0;

  @override
  void initState() {
    super.initState();
    _keyboardAnimationController = AnimationController(duration: const Duration(milliseconds: 250), vsync: this);
    _keyboardAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _keyboardAnimationController, curve: Curves.easeOutQuart));

    // Listen to keyboard changes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _listenToKeyboardChanges();
    });
  }

  void _listenToKeyboardChanges() {
    final mediaQuery = MediaQuery.of(context);
    final newKeyboardHeight = mediaQuery.viewInsets.bottom;

    if (_keyboardHeight != newKeyboardHeight) {
      setState(() {
        _keyboardHeight = newKeyboardHeight;
      });

      if (newKeyboardHeight > 0) {
        _keyboardAnimationController.forward();
      } else {
        _keyboardAnimationController.reverse();
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _listenToKeyboardChanges();
  }

  @override
  void dispose() {
    _keyboardAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.initialChildSize,
      minChildSize: widget.minChildSize,
      maxChildSize: widget.maxChildSize,
      builder: (context, scrollController) {
        return AnimatedBuilder(
          animation: _keyboardAnimation,
          builder: (context, child) {
            return Container(
              margin: EdgeInsets.only(bottom: _keyboardHeight * _keyboardAnimation.value),
              child: widget.child,
            );
          },
        );
      },
    );
  }
}
