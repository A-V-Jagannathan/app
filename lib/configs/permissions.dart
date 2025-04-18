import 'package:permission_handler/permission_handler.dart';

final Map<Permission, String> appPermissions = {
  Permission.camera:
      "Camera permissions are needed to scan QR / Bar codes in the lab.",
  Permission.microphone:
      "Microphone permissions are needed to record audio while using the microscopes.",
  Permission.photos:
      "Photos permissions are needed to store video files temporarily."
};
