import 'package:witnessing_data_app/screens/all_devices_screen.dart';
import 'package:witnessing_data_app/screens/main_screen.dart';
import 'package:witnessing_data_app/screens/settings_screen.dart';

final Map<String, String> pageToRouteConverter = {
  'Home': MainScreen.routeName,
  'Devices': AllDevicesScreen.routeName,
  'Settings': SettingsScreen.routeName,
};

String getPageRoute(String page) {
  return pageToRouteConverter[page] ?? '';
}
