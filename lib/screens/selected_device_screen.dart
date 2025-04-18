import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/providers/embryo_provider.dart';
import 'package:witnessing_data_app/screens/main_screen.dart';
import 'package:witnessing_data_app/widgets/device_card.dart';
import 'package:witnessing_data_app/widgets/device_controls.dart';
import 'package:witnessing_data_app/widgets/device_status_details.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';
import 'package:witnessing_data_app/widgets/full_page_lookup_progress.dart';

class SelectedDeviceScreen extends StatefulWidget {
  static const String routeName = '/device';

  final InternetAddress deviceIP;
  const SelectedDeviceScreen({super.key, required this.deviceIP});

  @override
  State<SelectedDeviceScreen> createState() => _SelectedDeviceScreenState();
}

class _SelectedDeviceScreenState extends State<SelectedDeviceScreen> {
  late final Future<bool?> _deviceDataFuture;

  bool _initiatedRecording = false;

  @override
  void initState() {
    super.initState();
    final deviceProvider = context.read<DeviceModel>();

    if (deviceProvider.hasSelectedDevice) {
      _deviceDataFuture = Future.value(true);
    } else {
      _deviceDataFuture =
          context.read<DeviceModel>().loadDeviceByID(widget.deviceIP);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: MGBAppBar(
          onBack: () {
            context.read<EmbryoModel>().clearSelectedEmbryo(notify: false);
            context.read<DeviceModel>().clearSelectedDevice(notify: false);
            if (_initiatedRecording) {
              Navigator.of(context).pushNamedAndRemoveUntil(
                  MainScreen.routeName, (route) => false);
            } else {
              Navigator.of(context).pop();
            }
          },
        ),
        body: LayoutMargins(
          child: FutureBuilder(
            future: _deviceDataFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasData) {
                  return Selector<DeviceModel, DeviceData?>(
                      selector: (_, deviceProvider) =>
                          deviceProvider.selectedDevice,
                      builder: (_, selectedDevice, child) {
                        return Column(children: [
                          Expanded(
                              flex: 1,
                              child: Row(children: [
                                Expanded(
                                    flex: 3,
                                    child: DeviceCard(
                                        device: selectedDevice!, iconSize: 54)),
                                const SizedBox(width: 20),
                                Expanded(
                                    flex: 2,
                                    child: DeviceControls(
                                        device: selectedDevice,
                                        onRecordingStart: onInitiatedRecording))
                              ])),
                          const SizedBox(height: 20),
                          Expanded(
                              flex: 4,
                              child:
                                  DeviceStatusDetails(device: selectedDevice)),
                          const Spacer()
                        ]);
                      });
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}',
                        style: Theme.of(context).textTheme.displaySmall),
                  );
                } else {
                  return Center(
                      child: Text(
                          "Device with IP '${widget.deviceIP.address}' was not found.\n\nPlease navigate to the 'Devices' tab from the Home Screen to add it to the database.",
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.displaySmall));
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                return FullPageLookupProgress(
                    progressText:
                        "Looking up device at\n'${widget.deviceIP.address}'");
              }

              return const SizedBox.shrink();
            },
          ),
        ));
  }

  void onInitiatedRecording() {
    _initiatedRecording = true;
    debugPrint('Initiated recording so popback will return to mainscreen');
  }
}
