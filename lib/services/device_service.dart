import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/models/firebase/device_log_data_model.dart';
import 'package:witnessing_data_app/models/raspberry_pi_response.dart';
import 'package:witnessing_data_app/services/firebase_service.dart';
import 'package:witnessing_data_app/utilities/file_upload_status.dart';
import 'package:witnessing_data_app/utilities/temp_ipaddr_converter.dart';

class DeviceService {
  DeviceService._();

  static DocumentSnapshot? _lastLogRecord;
  static DocumentSnapshot? _firstLogRecord;

  static final _deviceController = WitnessingDatabase.instance
      .collection(WitnessingDatabase.collections.devices)
      .withConverter<DeviceData?>(
          fromFirestore: (snapsnot, _) {
            final data = snapsnot.data();
            data?['id'] = snapsnot.id;

            return data == null ? null : DeviceData.fromJson(data);
          },
          toFirestore: (device, _) => device!.toJson());

  static CollectionReference<DeviceLogRecord?> _logsController(
      InternetAddress deviceIP) {
    return WitnessingDatabase.instance
        .collection(WitnessingDatabase.collections.devices)
        .doc(deviceIP.address)
        .collection('logs')
        .withConverter<DeviceLogRecord?>(
            fromFirestore: (snapshot, _) {
              final data = snapshot.data();
              return data == null ? null : DeviceLogRecord.fromJson(data);
            },
            toFirestore: (log, _) => log!.toJson());
  }

  static Query _logsPaginationController(InternetAddress deviceIP) {
    return WitnessingDatabase.instance
        .collection(WitnessingDatabase.collections.devices)
        .doc(deviceIP.address)
        .collection('logs')
        .orderBy('timestamp', descending: true);
  }

  ///
  /// CREATE Section
  ///
  static Future<bool> createDevice(DeviceData device) async {
    try {
      await _deviceController.doc(device.ipAddress.address).set(device);
      return true;
    } catch (e) {
      debugPrint('Error creating device: $e');
      return false;
    }
  }

  static Future<bool> addLogRecord(
      InternetAddress deviceIP, DeviceLogRecord log) async {
    try {
      await _logsController(deviceIP).add(log);
      return true;
    } catch (e) {
      debugPrint('Error adding log message: $e');
      return false;
    }
  }

  ///
  /// READ Section
  ///

  ///
  /// Gets all Devices from the database and sorts them by name
  ///
  static Future<List<DeviceData?>> getDevices() async {
    final devicesSnapshot = await _deviceController.orderBy('name').get();
    List<DeviceData?> devices =
        devicesSnapshot.docs.map((e) => e.data()).toList();

    return devices;
  }

  static Future<DeviceData?> getDeviceByIP(InternetAddress deviceIP) async {
    final device = await _deviceController.doc(deviceIP.address).get();

    if (!device.exists) debugPrint("Device with id $deviceIP does not exist");
    return device.data();
  }

  static Future<List<DeviceLogRecord?>> getInitialDeviceLogs(
      InternetAddress deviceIP,
      {int limit = 20,
      forceServerFetch = false}) async {
    bool requiresServerFetch = false;
    List<DeviceLogRecord?> logs = [];
    if (!forceServerFetch) {
      try {
        final docRefLogs = await _logsPaginationController(deviceIP)
            .limit(limit)
            .withConverter<DeviceLogRecord?>(
                fromFirestore: (snapsnot, _) => snapsnot.data() == null
                    ? null
                    : DeviceLogRecord.fromJson(snapsnot.data()!),
                toFirestore: (device, _) => device!.toJson())
            .get(const GetOptions(source: Source.cache));

        if (docRefLogs.docs.isNotEmpty) {
          _lastLogRecord = docRefLogs.docs.last;
        }
        logs = docRefLogs.docs.map((e) => e.data()).toList();

        debugPrint('Retrieved Initial Logs via CACHE!');
        requiresServerFetch = logs.isEmpty;
      } catch (e) {
        requiresServerFetch = true;
      }
    }
    debugPrint(
        'Requires Server Fetch: ${requiresServerFetch || forceServerFetch}');
    if (requiresServerFetch || forceServerFetch) {
      final docRefLogs = await _logsPaginationController(deviceIP)
          .limit(limit)
          .withConverter<DeviceLogRecord?>(
              fromFirestore: (snapsnot, _) => snapsnot.data() == null
                  ? null
                  : DeviceLogRecord.fromJson(snapsnot.data()!),
              toFirestore: (device, _) => device!.toJson())
          .get();

      if (docRefLogs.docs.isNotEmpty) {
        _lastLogRecord = docRefLogs.docs.last;
      }

      logs = docRefLogs.docs.map((e) => e.data()).toList();
      debugPrint('Retrieved Initial Logs via SERVER!');
    }
    return logs;
  }

  static Future<List<DeviceLogRecord?>> getMoreDeviceLogs(
      InternetAddress deviceIP,
      {int limit = 20,
      forceServerFetch = false}) async {
    if (_lastLogRecord == null) {
      debugPrint('No last log record found');
      return [];
    }

    bool requiresServerFetch = false;
    QuerySnapshot<DeviceLogRecord?>? docRefLogs;
    List<DeviceLogRecord?> logs = [];
    if (!forceServerFetch) {
      try {
        docRefLogs = await _logsPaginationController(deviceIP)
            .startAfterDocument(_lastLogRecord!)
            .limit(limit)
            .withConverter<DeviceLogRecord?>(
                fromFirestore: (snapsnot, _) => snapsnot.data() == null
                    ? null
                    : DeviceLogRecord.fromJson(snapsnot.data()!),
                toFirestore: (device, _) => device!.toJson())
            .get(const GetOptions(source: Source.cache));

        logs = docRefLogs.docs.map((e) => e.data()).toList();
        debugPrint('Retrieved Next Set of Logs via Cache!');
        requiresServerFetch = logs.isEmpty;
      } catch (e) {
        requiresServerFetch = true;
      }
    }

    debugPrint(
        'Requires Server Fetch: ${requiresServerFetch || forceServerFetch}');
    if (requiresServerFetch || forceServerFetch) {
      docRefLogs = await _logsPaginationController(deviceIP)
          .startAfterDocument(_lastLogRecord!)
          .limit(limit)
          .withConverter<DeviceLogRecord?>(
              fromFirestore: (snapsnot, _) => snapsnot.data() == null
                  ? null
                  : DeviceLogRecord.fromJson(snapsnot.data()!),
              toFirestore: (device, _) => device!.toJson())
          .get();

      logs = docRefLogs.docs.map((e) => e.data()).toList();
      debugPrint('Retrieved Next Set of Logs via SERVER!');
    }

    if (docRefLogs != null && docRefLogs.docs.isNotEmpty) {
      debugPrint('Setting last log record');
      _lastLogRecord = docRefLogs.docs.last;
    }

    return logs;
  }

  static Future<int> getTotalLogCount(InternetAddress deviceIP) async {
    return (await _logsController(deviceIP).count().get()).count ?? 0;
  }

  ///
  /// UPDATE Section
  ///

  static Future<bool> updateDeviceStatus(DeviceData device) async {
    try {
      debugPrint(
          'Updating device status variable on firebase: ${device.status.name}');
      await _deviceController
          .doc(device.ipAddress.address)
          .update({'status': device.status.name});
      return true;
    } catch (e) {
      debugPrint('Error updating device status: $e');
      return false;
    }
  }

  static Future<bool> startRecording(
      DeviceData device, String patientID) async {
    RPiResponse response;
    try {
      // response =
      //     await http.post(Uri.http(device.ipAddress.address, '/record/start'));
      final rawResponse = await http.post(
          Uri.http(tempIPToServerPort(device.ipAddress), '/record/start'),
          headers: {
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            "patientID": patientID,
          }));
      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error recording device: $e');
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Error starting recording',
          error: e.toString());
    }

    debugPrint('Start Recording response: ${response.toJson()}');
    switch (response.statusCode) {
      case 200:
        device.statusNotifier.value = response.status;
        return true;
      default:
        device.statusNotifier.value = response.status;
        return false;
    }
  }

  static Future<bool> stopRecording(DeviceData device) async {
    RPiResponse response;
    try {
      // response = await http.post(Uri.http(device.ipAddress.address, '/record/stop'));
      final rawResponse = await http
          .post(Uri.http(tempIPToServerPort(device.ipAddress), '/record/stop'));
      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error stopping recording: $e');
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Error stopping recording',
          error: e.toString());
    }

    debugPrint('Stopped Recording response: ${response.toJson()}');
    switch (response.statusCode) {
      case 200:
        device.statusNotifier.value = response.status;
        return true;
      default:
        device.statusNotifier.value = response.status;
        return false;
    }
  }

  static Future<bool> uploadRecording(
      DeviceData device, String audioPath) async {
    RPiResponse response;

    final request = http.MultipartRequest(
        'POST', Uri.http(tempIPToServerPort(device.ipAddress), '/audio/upload'))
      ..files.add(await http.MultipartFile.fromPath('audio', audioPath,
          contentType: MediaType('audio', 'wav')));
    try {
      final rawResponse = await request.send();
      final responseString = await rawResponse.stream.bytesToString();
      debugPrint('Raw responseString from stream: $responseString');

      response = RPiResponse.fromJson(
          jsonDecode(responseString) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error uploading recording: $e');
      response = RPiResponse(
          statusCode: 202,
          status: DeviceStatus.disconnected,
          message: 'Error uploading recording',
          error: e.toString());
    }

    debugPrint('Upload Recording response: ${response.toJson()}');
    switch (response.statusCode) {
      case 202: // Upload initiated
        device.statusNotifier.value = response.status;
        return true;
      default:
        device.statusNotifier.value = response.status;
        return false;
    }
  }

  static Future<bool> saveRecording(DeviceData device) async {
    RPiResponse response;
    try {
      // response = await http.post(Uri.http(device.ipAddress.address, '/preview'));
      final rawResponse = await http
          .post(Uri.http(tempIPToServerPort(device.ipAddress), '/preview'));

      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error saving recording: $e');
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Error saving recording',
          error: e.toString());
    }

    debugPrint('Save Recording response: ${response.toJson()}');
    switch (response.statusCode) {
      case 202: // Save video file has been initiated
        device.statusNotifier.value = response.status;
        return true;
      default:
        device.statusNotifier.value = response.status;
        return false;
    }
  }

  static Future<bool> discardRecording(DeviceData device) async {
    RPiResponse response;
    try {
      // await http.post(Uri.http(device.ipAddress.address, '/preview'));
      final rawResponse = await http
          .delete(Uri.http(tempIPToServerPort(device.ipAddress), '/preview'));
      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error discarding recording: $e');
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Error discarding recording',
          error: e.toString());
    }

    debugPrint('Discard Recording response: ${response.toJson()}');
    switch (response.statusCode) {
      case 200:
        device.statusNotifier.value = response.status;
        return true;
      default:
        device.statusNotifier.value = response.status;
        return false;
    }
  }

  static Future<FileUploadStatus?> checkUploadStatus(
      DeviceData device, String taskID) async {
    RPiResponse response;
    try {
      final rawResponse = await http.get(Uri.http(
          tempIPToServerPort(device.ipAddress), '/upload/status/$taskID'));

      response = RPiResponse.fromJson(
          jsonDecode(rawResponse.body) as Map<String, dynamic>)
        ..statusCode = rawResponse.statusCode;
    } catch (e) {
      debugPrint('Error checking upload status: $e');
      response = RPiResponse(
          statusCode: 500,
          status: DeviceStatus.disconnected,
          message: 'Error checking upload status',
          error: e.toString());
    }

    debugPrint('Check Upload Status response: ${response.toJson()}');
    switch (response.statusCode) {
      case 200:
        device.statusNotifier.value = response.status;
        return FileUploadStatus.values
            .byName(response.data['status'] as String);
      default:
        device.statusNotifier.value = response.status;
        return null;
    }
  }

  static Future<bool> deleteDevice(InternetAddress deviceIP) async {
    try {
      return WitnessingDatabase.instance
          .runTransaction((transaction) async {
            // get all logs to prepare for deletion
            final databaseLogs = await _logsController(deviceIP).get();

            // delete all log references to prevent orphaned data
            await Future.wait(
                databaseLogs.docs
                    .map((logRecord) => logRecord.reference.delete()),
                eagerError: true);

            // delete actual device
            await _deviceController.doc(deviceIP.address).delete();
          })
          .then((value) => true) // complete the transaction
          .onError((error, stackTrace) {
            debugPrint('Error deleting device: $error');
            return false;
          });
    } catch (e) {
      debugPrint('Error deleting device: $e');
      return false;
    }
  }
}
