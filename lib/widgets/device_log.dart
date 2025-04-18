import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/device_log_data_source.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';

class DeviceLog extends StatelessWidget {
  const DeviceLog({super.key, required this.device});

  final DeviceData device;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
      child: AsyncPaginatedDataTable2(
          renderEmptyRowsInTheEnd: false,
          fixedTopRows: 1,
          headingTextStyle: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.bold),
          headingRowDecoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(10), topRight: Radius.circular(10))),
          loading: Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.surface),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Text('Loading...',
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(width: 10),
                    const SizedBox(
                        width: 40,
                        height: 40,
                        child: CircularProgressIndicator())
                  ]))),
          empty: Center(
              child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Theme.of(context).colorScheme.surface),
                  child: Text('Device has no log entries',
                      style: Theme.of(context).textTheme.headlineSmall))),
          rowsPerPage: 10,
          columnSpacing: 10,
          dataRowHeight: 70,
          columns: const [
            DataColumn2(label: Text('Timestamp'), size: ColumnSize.S),
            DataColumn2(label: Text('Event'), size: ColumnSize.M),
            DataColumn2(label: Text('Details'), size: ColumnSize.L),
          ],
          source: DeviceLogDataSource(device)),
    );
  }
}
