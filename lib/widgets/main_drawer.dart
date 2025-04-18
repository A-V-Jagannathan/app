import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:witnessing_data_app/utilities/page_to_route_converter.dart';

class MainDrawer extends StatelessWidget {
  final String page;

  const MainDrawer({super.key, required this.page});

  static const List<String> drawerItems = <String>[
    'Home',
    'Devices',
    'Settings',
  ];

  @override
  Widget build(BuildContext context) {
    final List<String> visiblePages = MainDrawer.drawerItems
        .where((eligiblePage) => eligiblePage != page)
        .toList();

    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(1),
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
            ),
            child: Center(
                child: SvgPicture.asset('assets/icons/svg/mgb_whitelogo.svg')),
          ),
          ...visiblePages.map((String pageName) => ListTile(
                title: Text(
                  pageName,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline),
                ),
                onTap: () {
                  Navigator.pushReplacementNamed(
                      context, getPageRoute(pageName));
                },
              ))
        ],
      ),
    );
  }
}
