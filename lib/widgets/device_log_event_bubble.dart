import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/device_log_data_model.dart';

class DeviceLogEventBubble extends StatelessWidget {
  const DeviceLogEventBubble({super.key, required this.event});

  final DeviceLogEvent event;

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context)
        .textTheme
        .bodyLarge!
        .copyWith(color: Colors.white, fontWeight: FontWeight.bold);
    switch (event) {
      case DeviceLogEvent.disconnect:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.grey.shade800,
              borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_off_sharp, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Disconnect', style: textStyle),
            ],
          ),
        );
      case DeviceLogEvent.connect:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.green, borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.wifi_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Connect', style: textStyle),
            ],
          ),
        );
      case DeviceLogEvent.recordStart:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Record Start', style: textStyle),
            ],
          ),
        );
      case DeviceLogEvent.recordStop:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.videocam_off_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Record Stop', style: textStyle),
            ],
          ),
        );
      case DeviceLogEvent.embryoSelection:
        return Container(
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
              color: Colors.blueAccent, borderRadius: BorderRadius.circular(5)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.swipe_sharp, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text('Embryo Selection', style: textStyle),
            ],
          ),
        );
    }
  }
}
