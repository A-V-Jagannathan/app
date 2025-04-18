import 'package:flutter/material.dart';
import 'package:witnessing_data_app/configs/permissions.dart';
import 'package:witnessing_data_app/widgets/permission_item.dart';

class PermissionControls extends StatefulWidget {
  const PermissionControls({super.key});

  @override
  State<PermissionControls> createState() => _PermissionControlsState();
}

class _PermissionControlsState extends State<PermissionControls> {
  @override
  Widget build(BuildContext context) {
    List<PermissionItem> permissionItems = appPermissions.entries
        .map((entry) => PermissionItem(
            permissionType: entry.key, explanationText: entry.value))
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 65),
      child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Text(
                      'The following permissions are needed for the app to work properly. You can choose to skip this step for now and the permissions will show up when an action requiring them is performed.',
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 20),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: permissionItems,
                    ),
                  )
                ],
              ))),
    );
  }
}
