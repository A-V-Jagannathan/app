import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class MGBAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height = kToolbarHeight + 20;
  final VoidCallback? onBack;
  const MGBAppBar({super.key, this.onBack});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.onPrimary, size: 40),
        title: SvgPicture.asset(
          'assets/images/svg/mgb_whitelogo_whitetext.svg',
          height: 40,
        ),
        centerTitle: true,
        backgroundColor: Theme.of(context).colorScheme.primary,
        toolbarHeight: height,
        leading: onBack != null ? BackButton(onPressed: onBack) : null,
        automaticallyImplyLeading: true);
  }

  @override
  Size get preferredSize => Size.fromHeight(height);
}
