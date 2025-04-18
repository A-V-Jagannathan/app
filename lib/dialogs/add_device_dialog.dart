import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';

class AddDeviceDialog extends StatefulWidget {
  const AddDeviceDialog({super.key});

  @override
  State<AddDeviceDialog> createState() => _AddDeviceDialogState();
}

class _AddDeviceDialogState extends State<AddDeviceDialog> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ipAddrController = TextEditingController();

  bool _isCreatingNewDevice = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ipAddrController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Add Device'),
      backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(1),
      content: SizedBox(
        height: screenSize.height * 0.25,
        width: screenSize.width * 0.50,
        child: _isCreatingNewDevice
            ? Center(
                child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Adding...',
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
            : Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: _nameController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      decoration: InputDecoration(
                          labelText: 'Device Name',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          )),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a device name';
                        }
                        return null;
                      },
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _ipAddrController,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      maxLines: 1,
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(
                        labelText: 'Device IP Address (IPv4)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an IP address';
                        } else if (InternetAddress.tryParse(value) == null) {
                          return 'Please enter a valid IPv4 address';
                        }
                        return null;
                      },
                      onTapOutside: (event) =>
                          FocusManager.instance.primaryFocus?.unfocus(),
                    ),
                  ],
                ),
              ),
      ),
      actions: <Widget>[
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.onPrimary),
          onPressed: _isCreatingNewDevice
              ? null
              : () {
                  Navigator.of(context).pop();
                },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isCreatingNewDevice
              ? null
              : () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      _isCreatingNewDevice = true;
                    });

                    _addDevice(DeviceData(
                        name: _nameController.text,
                        ipAddress: InternetAddress(_ipAddrController.text)));
                  }
                },
          style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary),
          child: const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _addDevice(DeviceData device) async {
    return context.read<DeviceModel>().addDevice(device).then((success) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context, SnackBarType.success, 'Successfully added device!'));
        setState(() {
          _nameController.clear();
          _ipAddrController.clear();
          _isCreatingNewDevice = false;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
            getSnackBar(context, SnackBarType.error, 'Failed to add device!'));
        setState(() {
          _isCreatingNewDevice = false;
        });
      }
    });
  }
}
