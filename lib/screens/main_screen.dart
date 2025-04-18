import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/providers/local_storage_provider.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/main_drawer.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';
import 'package:witnessing_data_app/widgets/scan_qr_code_button.dart';

class MainScreen extends StatefulWidget {
  static const String routeName = 'home';

  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  @override
  void initState() {
    super.initState();

    final localStorage = context.read<LocalStorageModel>();
    if (localStorage.getPreference<bool?>('hasSeenPermissionsScreen') == null) {
      localStorage.setPreference('hasSeenPermissionsScreen', true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
          appBar: const MGBAppBar(),
          drawer: const MainDrawer(page: 'Home'),
          body: LayoutMargins(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Actions',
                    style: Theme.of(context)
                        .textTheme
                        .displaySmall!
                        .copyWith(fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),
                const ScanQRCodeButton()
              ],
            ),
          )),
    );
  }
}
