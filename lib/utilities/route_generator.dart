import 'dart:io';

import 'package:flutter/material.dart';
import 'package:witnessing_data_app/screens/all_devices_screen.dart';
import 'package:witnessing_data_app/screens/patient_screen.dart';
import 'package:witnessing_data_app/screens/selected_device_screen.dart';
import 'package:witnessing_data_app/screens/main_screen.dart';
import 'package:witnessing_data_app/screens/permission_screen.dart';
import 'package:witnessing_data_app/screens/settings_screen.dart';
import 'package:witnessing_data_app/utilities/patient_screen_args.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/main_drawer.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';

class RouteGenerator {
  static Route<dynamic> generateRoutes(RouteSettings settings) {
    switch (settings.name) {
      case PermissionScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => const PermissionScreen());

      ///
      /// Main Drawer Screens
      ///
      case MainScreen.routeName:
        return MaterialPageRoute(builder: (context) => const MainScreen());

      case AllDevicesScreen.routeName:
        return MaterialPageRoute(
            builder: (context) => const AllDevicesScreen());

      case SettingsScreen.routeName:
        // TODO: Implement SettingsScreen
        return MaterialPageRoute(builder: (context) => const SettingsScreen());

      ///
      /// Patient Screens
      ///
      case PatientScreen.routeName:
        final args = settings.arguments as PatientScreenArgs;
        return MaterialPageRoute(
            builder: (context) => PatientScreen(
                  emrbyoscopeID: args.embryoscopeID,
                  clearPatientOnPop: args.clearPatientOnPop,
                ));

      ///
      /// Device Screens
      ///
      case SelectedDeviceScreen.routeName:
        final deviceIP = settings.arguments as InternetAddress;
        return MaterialPageRoute(
            builder: (context) => SelectedDeviceScreen(deviceIP: deviceIP));

      default:
        return _unknownRoute();
    }
  }

  static Route<dynamic> _unknownRoute() {
    return MaterialPageRoute(
        builder: (context) => const Scaffold(
              appBar: MGBAppBar(),
              drawer: MainDrawer(page: 'Devices'),
              body: LayoutMargins(
                child: Center(
                  child: Text('Route not found'),
                ),
              ),
            ));
  }
}
