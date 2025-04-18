import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/dialogs/add_device_dialog.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';
import 'package:witnessing_data_app/widgets/device_selector.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/main_drawer.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';

class AllDevicesScreen extends StatelessWidget {
  static const String routeName = '/all-devices';

  const AllDevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const MGBAppBar(),
        drawer: const MainDrawer(page: 'Devices'),
        // resizeToAvoidBottomInset: false,
        body: LayoutMargins(
            child: RefreshIndicator(
          displacement: 15,
          backgroundColor: Theme.of(context).colorScheme.primary,
          color: Theme.of(context).colorScheme.onPrimary,
          onRefresh: () async {
            context.read<DeviceModel>().loadAllDevices().then((value) {
              ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                  context, SnackBarType.success, 'Devices Refreshed!'));
            }).onError((error, stackTrace) {
              ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                  context, SnackBarType.error, 'Unable to Refresh Devices'));
            });
          },
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('All Devices',
                  style: Theme.of(context)
                      .textTheme
                      .displaySmall!
                      .copyWith(fontWeight: FontWeight.w500)),
              ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => const AddDeviceDialog(),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.onPrimary,
                      textStyle: Theme.of(context)
                          .textTheme
                          .bodyLarge!
                          .copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.w600)),
                  label: const Text('Add Device'),
                  icon: const Icon(Icons.add_circle_outline_sharp))
            ]),
            const SizedBox(height: 20),
            const Expanded(child: DeviceSelector(mode: SelectorMode.single)),
            Center(
                child: Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(10.0),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withOpacity(0.6),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Icon(Icons.info_outline,
                          color: Theme.of(context).colorScheme.surface),
                      const SizedBox(width: 10),
                      Text(
                          "Tap to pull up the device's Log. Long press to delete.",
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge!
                              .copyWith(
                                  color: Theme.of(context).colorScheme.surface,
                                  fontWeight: FontWeight.w500))
                    ])))
          ]),
        )));
  }
}
