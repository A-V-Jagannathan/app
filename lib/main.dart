import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witnessing_data_app/configs/cameras.dart';
import 'package:witnessing_data_app/configs/firebase/firebase_config.dart';
import 'package:witnessing_data_app/providers/connectivity_provider.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/providers/embryo_provider.dart';
import 'package:witnessing_data_app/providers/local_storage_provider.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';
import 'package:witnessing_data_app/providers/settings_provider.dart';
import 'package:witnessing_data_app/witnessing_data_app.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    deviceCameras = await availableCameras();
  } on CameraException catch (e) {
    debugPrint('Error Code: ${e.code}\nError Message: ${e.description}');
  }

  await FirebaseConfig.initialize();
  SharedPreferences prefs = await SharedPreferences.getInstance();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => PatientModel()),
      ChangeNotifierProvider(create: (_) => EmbryoModel()),
      ChangeNotifierProvider(
          create: (_) => DeviceModel(),
          lazy: prefs.getBool('hasSeenPermissionsScreen') ?? false
              ? false
              : true // needs to load devices right on start unless user has not seen permissions screen
          ),
      Provider(create: (_) => LocalStorageModel(prefs)),
      ChangeNotifierProvider<SettingsModel>(
          create: (_) => SettingsModel(prefs), lazy: false),
      ChangeNotifierProvider(create: (_) => ConnectivityModel())
    ],
    child: const WitnessingDataApp(),
  ));
}
