import 'dart:io';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:witnessing_data_app/models/firebase/device_log_data_model.dart';
import 'package:witnessing_data_app/services/device_service.dart';
import 'package:witnessing_data_app/utilities/device_heartbeat.dart';

part 'device_data_model.g.dart';

enum DeviceStatus { connected, disconnected, recording, previewing }

@JsonSerializable()
class DeviceData {
  static InternetAddress _ipAddressFromJson(String ipAddress) {
    return InternetAddress(ipAddress);
  }

  static String _ipAddressToJson(InternetAddress ipAddress) {
    return ipAddress.address;
  }

  // static const Map<String, DeviceStatus> statusStrings = {
  //   'connected': DeviceStatus.connected,
  //   'disconnected': DeviceStatus.disconnected,
  //   'recording': DeviceStatus.recording,
  //   'previewing': DeviceStatus.previewing
  // };

  DeviceData(
      {required this.name,
      required this.ipAddress,
      this.status = DeviceStatus.disconnected}) {
    _heartbeat =
        DeviceHeartbeat(device: this, duration: const Duration(seconds: 10));
    statusNotifier = ValueNotifier(status);
    statusNotifier.addListener(() {
      updateStatus(statusNotifier.value);
    });
  }

  final String name;

  @JsonKey(fromJson: _ipAddressFromJson, toJson: _ipAddressToJson)
  final InternetAddress ipAddress;

  DeviceStatus status;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final ValueNotifier<DeviceStatus> statusNotifier;

  @JsonKey(includeFromJson: false, includeToJson: false)
  late final DeviceHeartbeat _heartbeat;

  DeviceHeartbeat get heartbeat => _heartbeat;

  @JsonKey(includeFromJson: false, includeToJson: false)
  int prevLogRowCount = 0;

  Widget getStatusIcon([double iconSize = 40]) {
    switch (statusNotifier.value) {
      case DeviceStatus.connected:
        return Icon(Icons.wifi_rounded, color: Colors.white, size: iconSize);
      case DeviceStatus.disconnected:
        return Icon(Icons.wifi_off_sharp, color: Colors.white, size: iconSize);
      case DeviceStatus.previewing:
        return Icon(Icons.preview_outlined,
            color: Colors.white, size: iconSize);
      case DeviceStatus.recording:
        return Icon(Icons.videocam_rounded,
            color: Colors.white, size: iconSize);
    }
  }

  Color get statusColor {
    switch (statusNotifier.value) {
      case DeviceStatus.connected:
        return Colors.green;
      case DeviceStatus.disconnected:
        return Colors.grey.shade800;
      case DeviceStatus.previewing:
        return Colors.blueAccent;
      case DeviceStatus.recording:
        return Colors.red;
    }
  }

  Future<bool> startRecording(String patientID) async {
    return DeviceService.startRecording(this, patientID);
  }

  Future<bool> stopRecording() async {
    return DeviceService.stopRecording(this);
  }

  Future<bool> saveRecording() async {
    return DeviceService.saveRecording(this);
  }

  Future<bool> uploadRecording(String recordingPath) async {
    return DeviceService.uploadRecording(this, recordingPath);
  }

  Future<bool> discardRecording() async {
    return DeviceService.discardRecording(this);
  }

  Future<bool> logEvent(DeviceLogEvent event, String message) async {
    return await DeviceService.addLogRecord(
        ipAddress,
        DeviceLogRecord(
            event: event, message: message, timestamp: DateTime.now()));
  }

  Future<bool> updateStatus(DeviceStatus newStatus) async {
    // status is actually the previous state since it is not updated from the ValueNotifier yet
    Future<bool> logFuture = Future.value(true);
    switch (status) {
      case DeviceStatus.connected:
        switch (newStatus) {
          case DeviceStatus.connected:
            return true; // no need to update anything

          // case where device was connected at first, but then disconnected
          // REQUIRES FUTURE IMPLEMENTATION OF NOTIFICATION TO THE USER
          case DeviceStatus.disconnected:
            status = newStatus;
            debugPrint(
                '[ DEVICE DISCONNECTED ] Logging a disconnect event with Firebase (Connected -> Disconnected)');
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.disconnect,
                    message: 'Device disconnected',
                    timestamp: DateTime.now()));
            break;

          case DeviceStatus.previewing:
            debugPrint('Device is previewing');
            status = newStatus;

          case DeviceStatus.recording:
            debugPrint(
                '[ RECORDING STARTED ] Logging a recordStart event with Firebase');
            status = newStatus;
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.recordStart,
                    message: 'Recording started',
                    timestamp: DateTime.now()));
        }
      case DeviceStatus.disconnected:
        switch (newStatus) {
          case DeviceStatus.connected:
            status = newStatus;
            debugPrint(
                '[ DEVICE CONNECTED ] Logging a connect event with Firebase');
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.connect,
                    message: 'Device connected',
                    timestamp: DateTime.now()));
            break;

          case DeviceStatus.disconnected:
            return true; // no need to update anything

          default:
            status = newStatus;
        }
      case DeviceStatus.previewing:
        switch (newStatus) {
          case DeviceStatus.disconnected:
            status = newStatus;
            debugPrint(
                '[ DEVICE DISCONNECTED ] Logging a disconnect event with Firebase (Previewing -> Disconnected)');
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.disconnect,
                    message: 'Device disconnected',
                    timestamp: DateTime.now()));
            break;

          case DeviceStatus.previewing:
            return true; // no need to update anything

          default:
            debugPrint('Changing status $status to $newStatus');
            status = newStatus;
        }
      case DeviceStatus.recording:
        switch (newStatus) {
          case DeviceStatus.disconnected:
            status = newStatus;
            debugPrint(
                '[ DEVICE DISCONNECTED ] Logging a disconnect event with Firebase (Recording -> Disconnected)');
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.disconnect,
                    message: 'Device disconnected',
                    timestamp: DateTime.now()));
            break;

          case DeviceStatus.recording:
            return true; // no need to update anything

          case DeviceStatus.previewing:
            debugPrint(
                '[ RECORDING STOPPED ] Logging a recordStop event with Firebase');
            status = newStatus;
            logFuture = DeviceService.addLogRecord(
                ipAddress,
                DeviceLogRecord(
                    event: DeviceLogEvent.recordStop,
                    message: 'Recording stopped',
                    timestamp: DateTime.now()));
          case DeviceStatus.connected:
            status = newStatus;
        }
    }
    final futures = [DeviceService.updateDeviceStatus(this), logFuture];
    final results = await Future.wait(futures);
    return results.every((element) => element);
  }

  Future<int> get logCount async =>
      await DeviceService.getTotalLogCount(ipAddress);

  factory DeviceData.fromJson(Map<String, dynamic> json) =>
      _$DeviceDataFromJson(json);

  Map<String, dynamic> toJson() => _$DeviceDataToJson(this);
}
