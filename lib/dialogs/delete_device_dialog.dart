import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';

class DeleteDeviceDialog extends StatefulWidget {
  const DeleteDeviceDialog({super.key, required this.device});

  final DeviceData device;

  @override
  State<DeleteDeviceDialog> createState() => _DeleteDeviceDialogState();
}

class _DeleteDeviceDialogState extends State<DeleteDeviceDialog> {
  bool _isDeleting = false;

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(1),
      title: const Text('Continue with Current Cycle?'),
      content: SizedBox(
        height: screenSize.height * 0.25,
        width: screenSize.width * 0.75,
        child: _isDeleting
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Deleting...',
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 75,
                    width: 75,
                    child: CircularProgressIndicator(
                      color: Theme.of(context).colorScheme.primary,
                      strokeWidth: 6,
                    ),
                  ),
                ],
              ))
            : Center(
                child: Text(
                "Are you sure you want to delete\n'${widget.device.name}'?\n\nThis action cannot be undone.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium,
              )),
      ),
      actions: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary),
          onPressed: _isDeleting
              ? null
              : () {
                  Navigator.pop(context);
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isDeleting
              ? null
              : () {
                  setState(() {
                    _isDeleting = true;
                  });

                  _deleteDevice();
                },
          child: const Text('Delete'),
        ),
      ],
    );
  }

  Future<void> _deleteDevice() async {
    // Delete device from Firebase
    context.read<DeviceModel>().deleteDevice(widget.device).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
          context, SnackBarType.success, 'Successfully deleted device!'));
      setState(() {
        _isDeleting = false;
      });
      Navigator.pop(context);
    }).onError((error, stackTrace) {
      ScaffoldMessenger.of(context).showSnackBar(
          getSnackBar(context, SnackBarType.error, 'Unable to delete device'));
      setState(() {
        _isDeleting = false;
      });
    });
  }
}
