import 'dart:io';

String tempIPToServerPort(InternetAddress ipAddress) {
  int basePortNum = 6000;
  final portOffset = int.parse(ipAddress.address.split('.').last);

  return "192.168.1.186:${basePortNum + portOffset}";
}
