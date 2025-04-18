import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/dialogs/delete_device_dialog.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/widgets/device_log.dart';
import 'package:witnessing_data_app/widgets/device_selector.dart';

class DeviceCard extends StatelessWidget {
  const DeviceCard(
      {super.key,
      required this.device,
      this.index = -1,
      this.mode = SelectorMode.none,
      this.iconSize = 40});

  final DeviceData device;
  final int index;
  final SelectorMode mode;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    final int? selectedDeviceIndex = context.select<DeviceModel, int?>(
        (deviceProvider) => deviceProvider.selectedDeviceIndex);

    final selectedTheme = Theme.of(context).colorScheme.onPrimary;
    final unselectedTheme = Theme.of(context).colorScheme.onSurface;

    return ValueListenableBuilder(
      valueListenable: device.statusNotifier,
      builder: (context, status, _) {
        final bool canBeSelected = status == DeviceStatus.connected;

        final bool selected = index == selectedDeviceIndex && canBeSelected;
        final normalTextTheme = Theme.of(context)
            .textTheme
            .titleMedium!
            .copyWith(color: selected ? selectedTheme : unselectedTheme);
        final boldTextTheme = Theme.of(context).textTheme.titleMedium!.copyWith(
              color: selected ? selectedTheme : unselectedTheme,
              fontWeight: FontWeight.bold,
            );

        final statusColor = selected
            ? Theme.of(context).colorScheme.primary
            : device.statusColor;
        final statusIcon = device.getStatusIcon(iconSize);

        return Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          clipBehavior: Clip.hardEdge,
          color: canBeSelected
              ? selected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.white
              : Colors.grey[400],
          child: InkWell(
            splashFactory: InkSplash.splashFactory,
            splashColor: Colors.grey[100]!.withOpacity(0.2),
            onTap: () {
              switch (mode) {
                case SelectorMode.none:
                  break;
                case SelectorMode.single:
                  _displayDeviceLog(context);
                case SelectorMode.multiple:
                  if (canBeSelected) {
                    selected
                        ? context.read<DeviceModel>().clearSelectedDevice()
                        : context
                            .read<DeviceModel>()
                            .setSelectedDevice(device, index);
                  }
              }
            },
            onLongPress: mode == SelectorMode.single
                ? () {
                    // do not allow deletion of selected device if it is active
                    if (status == DeviceStatus.previewing ||
                        status == DeviceStatus.recording) return;

                    showDialog(
                        context: context,
                        builder: (context) =>
                            DeleteDeviceDialog(device: device));
                  }
                : null,
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(15, 15, 0, 15),
                    height: double.infinity,
                    child: Row(
                      children: [
                        Center(
                            child: Image.asset(
                          'assets/images/png/raspilogo.png',
                          height: 60,
                        )),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Flexible(
                                        child: Text(
                                          device.name,
                                          overflow: TextOverflow.ellipsis,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium!
                                              .copyWith(
                                                  color: selected
                                                      ? selectedTheme
                                                      : unselectedTheme,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                        ),
                                      ),
                                      RichText(
                                        text: TextSpan(
                                            style: boldTextTheme,
                                            text: 'IP: ',
                                            children: [
                                              TextSpan(
                                                  text:
                                                      device.ipAddress.address,
                                                  style: normalTextTheme)
                                            ]),
                                      ),
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Status: ', style: boldTextTheme),
                                        Text(
                                            device.statusNotifier.value.name
                                                .toUpperCase(),
                                            style: normalTextTheme)
                                      ]))
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                    flex: 1,
                    child: Row(children: [
                      Container(
                        color: Colors.black,
                        width: 2,
                      ),
                      Expanded(
                          child: Container(
                              color: statusColor,
                              child: Center(child: statusIcon)))
                    ]))
              ],
            ),
          ),
        );
      },
    );
  }

  void _displayDeviceLog(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      enableDrag: false,
      backgroundColor: Theme.of(context).colorScheme.surface.withOpacity(1),
      constraints: BoxConstraints(
          maxWidth: screenSize.width - 40, maxHeight: screenSize.height * 0.75),
      builder: (context) => SizedBox.expand(
          child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Align(
                alignment: Alignment.topRight,
                child: IconButton(
                    icon: const Icon(Icons.cancel_sharp),
                    iconSize: 36,
                    onPressed: () => Navigator.pop(context))),
          ),
          Expanded(
            child: DeviceLog(
              device: device,
            ),
          ),
        ],
      )),
    );
  }
}
