import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/widgets/device_card.dart';

enum SelectorMode { none, single, multiple }

class DeviceSelector extends StatelessWidget {
  const DeviceSelector({super.key, this.mode = SelectorMode.multiple});

  final SelectorMode mode;

  @override
  Widget build(BuildContext context) {
    return Consumer<DeviceModel>(
      builder: (_, deviceProvider, __) {
        if (deviceProvider.devices.isEmpty) {
          return Center(
            child: Text(
              'No devices found in the database. Please add device(s) for them to show up here.',
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ),
          );
        }

        return GridView.builder(
          padding: EdgeInsets.zero,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisExtent: 150,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20),
          shrinkWrap: true,
          itemCount: deviceProvider.devices.length,
          itemBuilder: (context, index) {
            return Selector<DeviceModel, DeviceData>(
              selector: (_, deviceProvider) => deviceProvider.devices[index]!,
              builder: (context, device, child) {
                return DeviceCard(
                  device: device,
                  index: index,
                  mode: mode,
                );
              },
            );
          },
        );
      },
    );
  }
}
