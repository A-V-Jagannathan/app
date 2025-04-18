import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/widgets/device_preview.dart';
import 'package:witnessing_data_app/widgets/embryo_selector.dart';
// import 'package:witnessing_data_app/widgets/embryo_selector.dart';

class DeviceStatusDetails extends StatelessWidget {
  const DeviceStatusDetails({super.key, required this.device});

  final DeviceData device;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: device.statusNotifier,
        builder: (_, status, __) {
          switch (status) {
            case DeviceStatus.connected:
            case DeviceStatus.recording:
              return EmbryoSelector(
                  selectedDevice: device, deviceStatus: status);
            case DeviceStatus.disconnected:
              return DefaultTextStyle(
                style: Theme.of(context).textTheme.headlineLarge!,
                child: const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text('Device cannot be found on the network...\n'),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('1.'),
                          SizedBox(width: 25),
                          Flexible(
                              child: Text(
                                  'Ensure device is plugged in/powered on.')),
                        ],
                      ),
                      SizedBox(height: 15),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('2.'),
                          SizedBox(width: 20),
                          Flexible(
                            child: Text(
                                'Verify this tablet is connected to the same network as the device.'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            case DeviceStatus.previewing:
              return DevicePreview(device: device);
          }
        });
  }
}
