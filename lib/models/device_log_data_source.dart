import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:intl/intl.dart';

import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/services/device_service.dart';
import 'package:witnessing_data_app/widgets/device_log_event_bubble.dart';

class DeviceLogDataSource extends AsyncDataTableSource {
  DeviceLogDataSource(this._device);

  final DeviceData _device;
  int _rowCount = 0;
  bool _forceServerFetch = false;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _rowCount;

  @override
  int get selectedRowCount => 0;

  @override
  Future<AsyncRowsResponse> getRows(int startIndex, int count) async {
    debugPrint('getRows($startIndex, $count)');
    _rowCount = await _device.logCount;
    if (_rowCount == 0) {
      debugPrint('No logs found');
      return AsyncRowsResponse(0, []);
    }

    if (_device.prevLogRowCount != _rowCount) {
      debugPrint(
          'Row count changed from ${_device.prevLogRowCount} to $_rowCount');
      _device.prevLogRowCount = _rowCount;
      _forceServerFetch = true;
    }

    if (startIndex == 0) {
      debugPrint(
          'Retrieving initial logs with forceServerFetch: $_forceServerFetch');
      final initialLogs = await DeviceService.getInitialDeviceLogs(
          _device.ipAddress,
          limit: count,
          forceServerFetch: _forceServerFetch);

      _forceServerFetch = false;
      return AsyncRowsResponse(
          initialLogs.length,
          initialLogs
              .map((logRecord) => DataRow(
                      key: ValueKey<DateTime>(logRecord!.timestamp),
                      cells: [
                        DataCell(Text(DateFormat('MM-dd-yyyy\nHH:mm:ss')
                            .format(logRecord.timestamp))),
                        DataCell(DeviceLogEventBubble(event: logRecord.event)),
                        DataCell(Text(logRecord.message)),
                      ]))
              .toList());
    } else {
      debugPrint(
          'Retrieving more logs with forceServerFetch: $_forceServerFetch');
      final nextLogs = await DeviceService.getMoreDeviceLogs(_device.ipAddress,
          limit: count, forceServerFetch: _forceServerFetch);

      _forceServerFetch = false;
      return AsyncRowsResponse(
          nextLogs.length,
          nextLogs
              .map((logRecord) => DataRow(
                      key: ValueKey<DateTime>(logRecord!.timestamp),
                      cells: [
                        DataCell(Text(DateFormat('MM-dd-yyyy HH:mm:ss')
                            .format(logRecord.timestamp))),
                        DataCell(DeviceLogEventBubble(event: logRecord.event)),
                        DataCell(Text(logRecord.message)),
                      ]))
              .toList());
    }
  }
}
