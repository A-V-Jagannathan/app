import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';

import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/services/device_service.dart';

class DeviceModel extends ChangeNotifier {
  DeviceModel() {
    loadAllDevices().then((value) {
      _hasLoaded = true;
    });
  }

  bool _hasLoaded = false;

  /// The List of All Devices in the Database
  ///
  /// This list is populated by the [loadAllDevices] method.
  List<DeviceData?> _allDevices = [];

  /// The currently selected device
  ///
  /// This is set by the [setSelectedDevice] method and cleared by
  /// the [clearSelectedDevice] method.
  DeviceData? _selectedDevice;

  /// The index of the currently selected device in the [_allDevices] list
  /// represented by [_selectedDevice]
  ///
  /// This is set by the [setSelectedDevice] method and cleared by the
  /// [clearSelectedDevice] method.
  int? _selectedDeviceIndex;

  ///
  List<DeviceData?> get devices => _allDevices;
  set devices(List<DeviceData?> devices) {
    _allDevices = devices;
    notifyListeners();
  }

  Future<bool> addDevice(DeviceData device) async {
    final created = await DeviceService.createDevice(device);
    if (!created) return false;

    _allDevices.add(device);
    notifyListeners();
    return true;
  }

  DeviceData? get selectedDevice => _selectedDevice;
  bool get hasSelectedDevice => _selectedDevice != null;
  int? get selectedDeviceIndex => _selectedDeviceIndex;
  void setSelectedDevice(DeviceData device, int index) {
    _selectedDevice = device;
    _selectedDeviceIndex = index;
    notifyListeners();
  }

  void clearSelectedDevice({bool notify = true}) {
    debugPrint('clearSelectedDevice called with notify: $notify');
    _selectedDevice = null;
    _selectedDeviceIndex = null;
    if (notify) notifyListeners();
  }

  /// Load all devices from the database
  ///
  /// This method is called in the constructor of the [DeviceModel] class
  /// and ensures all devices are loaded when the app starts through the
  /// [Provider] package.
  Future<bool?> loadAllDevices() async {
    _allDevices = await DeviceService.getDevices();
    notifyListeners();
    return _allDevices.isNotEmpty ? true : null;
  }

  /// Load a device by its ID
  Future<bool?> loadDeviceByID(InternetAddress deviceIP) async {
    if (!_hasLoaded) {
      await loadAllDevices();
      _hasLoaded = true;
    }
    if (_allDevices.isEmpty) return null;

    _selectedDevice =
        _allDevices.firstWhereOrNull((device) => device!.ipAddress == deviceIP);

    return hasSelectedDevice ? true : null;
  }

  Future<bool> deleteDevice(DeviceData device) async {
    final success = await DeviceService.deleteDevice(device.ipAddress);
    if (success) {
      _allDevices.remove(device);
      device.heartbeat.stop();
      notifyListeners();
    }
    return success;
  }
}
