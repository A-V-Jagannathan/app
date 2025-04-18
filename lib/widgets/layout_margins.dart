import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class LayoutMargins extends StatelessWidget {
  const LayoutMargins({super.key, this.child});

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0), child: child));
  }
}
