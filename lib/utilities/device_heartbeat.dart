import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/models/raspberry_pi_response.dart';
import 'package:witnessing_data_app/utilities/temp_ipaddr_converter.dart';

class DeviceHeartbeat {
  DeviceHeartbeat({required this.device, required this.duration}) {
    start();
  }

  final DeviceData device;
  final Duration duration;

  // final StreamController<DeviceStatus> _controller =
  //     StreamController<DeviceStatus>.broadcast();
  // Stream<DeviceStatus> get stream => _controller.stream;
  Timer? _heartbeatTimer;

  Future<bool> forceUpdate() async {
    debugPrint('Forcing update for ${device.name}');
    return _healthCheck();
  }

  void start() {
    if (_heartbeatTimer != null && _heartbeatTimer!.isActive) {
      debugPrint('Heartbeat already started for ${device.name}');
      return;
    }

    debugPrint("[ HEARTBEAT STARTED ] Device '${device.name}'");
    _healthCheck();
    _heartbeatTimer = Timer.periodic(duration, (_) {
      _healthCheck();
    });
  }

  void stop() {
    debugPrint("[ HEARTBEAT STOP ] Device '${device.name}'");
    _heartbeatTimer?.cancel();
    _heartbeatTimer = null;
  }

  /// Check the health of the device
  ///
  /// Returns: [DeviceStatus] of the device
  Future<bool> _healthCheck() async {
    RPiResponse response;
    bool healthy = false;
    try {
      // response = await http.get(Uri.https(device.ipAddress.address, '/status'));
      final rawResponse = await http
          .get(Uri.http(tempIPToServerPort(device.ipAddress), '/status'));

      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;

      healthy = true;
    } catch (e) {
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Disconnected',
          error: e.toString());
    }

    switch (response.statusCode) {
      case 200:
        device.statusNotifier.value = response.status;
        debugPrint("${device.name} is healthy: ${healthy ? 'YES' : 'NO'}");
        return healthy;
      case 500:
        debugPrint(
            'Device ${device.name} is disconnected. Status code: ${response.statusCode}');
        device.statusNotifier.value = DeviceStatus.disconnected;
        return healthy;
      default:
        debugPrint(
            "Device '${device.name}' had another issue occur. Status code: ${response.statusCode}");
        return healthy;
    }
  }
}
