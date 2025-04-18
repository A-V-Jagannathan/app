import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionItem extends StatefulWidget {
  final Permission permissionType;
  final String explanationText;

  const PermissionItem(
      {super.key, required this.permissionType, required this.explanationText});

  @override
  State<PermissionItem> createState() => _PermissionItemState();
}

class _PermissionItemState extends State<PermissionItem> {
  PermissionStatus? _permissionStatus;

  @override
  initState() {
    super.initState();
    _getPermissionStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
            flex: 3,
            child: Row(
              children: <Widget>[
                const SizedBox(
                  width: 24,
                ),
                Icon(_convertPermissionToIcon(widget.permissionType),
                    size: 48, color: Theme.of(context).colorScheme.onSurface),
                const SizedBox(
                  width: 30,
                ),
                Flexible(
                  child: Text(
                    widget.explanationText,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
              ],
            )),
        Expanded(
            flex: 1, child: Center(child: _convertPermissionStatusToWidget()))
      ],
    );
  }

  Future<void> _getPermissionStatus() async {
    final status = await widget.permissionType.status;
    setState(() {
      _permissionStatus = status;
    });
  }

  Future<void> _requestPermission() async {
    final status = await widget.permissionType.request();
    debugPrint(
        'Requesting permission for ${widget.permissionType}: new status $status');
    setState(() {
      _permissionStatus = status;
    });
  }

  Widget _convertPermissionStatusToWidget() {
    switch (_permissionStatus) {
      case PermissionStatus.granted:
        return const Icon(
          Icons.check_circle_outline,
          color: Colors.green,
          size: 48,
        );
      // case PermissionStatus.denied:
      //   return ElevatedButton(
      //       onPressed: () {
      //         _requestPermission();
      //       },
      //       style: ButtonStyle(
      //           backgroundColor: MaterialStateProperty.all(Colors.amber)),
      //       child: Text(
      //         'Allow',
      //         style: Theme.of(context)
      //             .textTheme
      //             .bodyLarge!
      //             .copyWith(color: Theme.of(context).colorScheme.onTertiary),
      //       ));
      case PermissionStatus.restricted:
        return const Icon(Icons.cancel_outlined, color: Colors.red);
      case PermissionStatus.permanentlyDenied:
        return ElevatedButton(
            onPressed: () {
              openAppSettings();
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(Colors.red[200])),
            child: Text(
              'Open Settings',
              style: Theme.of(context).textTheme.bodySmall!.copyWith(
                  color: Theme.of(context).colorScheme.onTertiary,
                  fontWeight: FontWeight.w600),
            ));
      default:
        // return widget.permissionType == Permission.nearbyWifiDevices
        //     ? const Icon(
        //         Icons.check_circle_outline,
        //         color: Colors.grey,
        //         size: 48,
        //       ) :
        return ElevatedButton(
            onPressed: () {
              _requestPermission();
            },
            style: ButtonStyle(
                backgroundColor: WidgetStateProperty.all(
                    Theme.of(context).colorScheme.tertiary)),
            child: Text(
              'Allow',
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Theme.of(context).colorScheme.onTertiary),
            ));
    }
  }

  IconData _convertPermissionToIcon(Permission permission) {
    switch (permission) {
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.photos:
        return Icons.photo;
      case Permission.microphone:
        return Icons.mic;
      case Permission.nearbyWifiDevices:
        return Icons.wifi;
      default:
        return Icons.error;
    }
  }
}
