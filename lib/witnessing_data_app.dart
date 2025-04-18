import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:witnessing_data_app/constants/theme/app_color_theme.dart';
import 'package:witnessing_data_app/constants/theme/app_text_theme.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/providers/local_storage_provider.dart';
import 'package:witnessing_data_app/screens/main_screen.dart';
import 'package:witnessing_data_app/screens/permission_screen.dart';
import 'package:witnessing_data_app/utilities/route_generator.dart';

class WitnessingDataApp extends StatefulWidget {
  const WitnessingDataApp({super.key});
  @override
  State<WitnessingDataApp> createState() => _WitnessingDataAppState();
}

class _WitnessingDataAppState extends State<WitnessingDataApp>
    with WidgetsBindingObserver {
  bool _hasSeenPermissionScreen = false;

  final ThemeData appTheme = ThemeData(
      colorScheme: appColorScheme,
      textTheme: appTextTheme,
      cardTheme: const CardTheme(color: Colors.white),
      datePickerTheme: DatePickerThemeData(
          headerBackgroundColor: appColorScheme.primary,
          headerForegroundColor: appColorScheme.onPrimary,
          backgroundColor: appColorScheme.onPrimary,
          surfaceTintColor: Colors.transparent));

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _hasSeenPermissionScreen = context
            .read<LocalStorageModel>()
            .getPreference<bool?>('hasSeenPermissionsScreen') ??
        false;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_hasSeenPermissionScreen) return;
    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        return;
      case AppLifecycleState.paused:
        debugPrint('Paused');
        final deviceProvider = context.read<DeviceModel>();
        for (final device in deviceProvider.devices) {
          device?.heartbeat.stop();
        }
      case AppLifecycleState.resumed:
        final deviceProvider = context.read<DeviceModel>();
        debugPrint('Resumed');
        for (final device in deviceProvider.devices) {
          device?.heartbeat.start();
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Witnessing Data',
        debugShowCheckedModeBanner: false,
        themeMode: ThemeMode.light,
        theme: appTheme,
        initialRoute: _hasSeenPermissionScreen
            ? MainScreen.routeName
            : PermissionScreen.routeName,
        onGenerateRoute: RouteGenerator.generateRoutes);
  }
}

/// Old code maybe can be deleted/useful?
///   //         return OrientationBuilder(
    //           builder: (context, orientation) => Container(
    //             color: appTheme.colorScheme.primary,
    //             child: LayoutMargins(
    //               child: Column(
    //                 crossAxisAlignment: CrossAxisAlignment.stretch,
    //                 children: <Widget>[
    //                   const Spacer(flex: 1),
    //                   Expanded(
    //                     flex: 2,
    //                     child: Center(
    //                       child: Column(
    //                         children: <Widget>[
    //                           SvgPicture.asset(
    //                             'assets/icons/svg/mgb_whitelogo.svg',
    //                             width: orientation == Orientation.portrait
    //                                 ? 100
    //                                 : 75,
    //                           ),
    //                           const SizedBox(height: 30),
    //                           SvgPicture.asset(
    //                             'assets/images/svg/mgb_whitetext.svg',
    //                             height: orientation == Orientation.portrait
    //                                 ? 50
    //                                 : 40,
    //                           )
    //                         ],
    //                       ),
    //                     ),
    //                   ),
    //                   Expanded(
    //                     flex: 4,
    //                     child: Center(
    //                         child: SizedBox(
    //                       height: 80,
    //                       width: 80,
    //                       child: CircularProgressIndicator(
    //                           color: appTheme.colorScheme.secondary),
    //                     )),
    //                   ),
    //                   const Spacer(flex: 1)
    //                 ],
    //               ),
    //             ),
    //           ),
    //         );
    //       }
    //     });
