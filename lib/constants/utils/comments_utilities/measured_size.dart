import 'package:flutter/material.dart';

typedef OnWidgetSizeChange = void Function(Size size);

class MeasuredSize extends StatefulWidget {
  final Widget child;
  final OnWidgetSizeChange onChange;

  const MeasuredSize({Key? key, required this.child, required this.onChange}) : super(key: key);

  @override
  State<MeasuredSize> createState() => _MeasuredSizeState();
}

class _MeasuredSizeState extends State<MeasuredSize> {
  Size? _oldSize;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(_notifySize);
  }

  @override
  void didUpdateWidget(covariant MeasuredSize oldWidget) {
    super.didUpdateWidget(oldWidget);
    WidgetsBinding.instance.addPostFrameCallback(_notifySize);
  }

  void _notifySize(Duration _) {
    final contextSize = context.size;
    if (contextSize == null) return;
    if (_oldSize == contextSize) return;
    _oldSize = contextSize;
    widget.onChange(contextSize);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
