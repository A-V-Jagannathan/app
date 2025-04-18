import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:witnessing_data_app/screens/main_screen.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/permission_controls.dart';

class PermissionScreen extends StatelessWidget {
  static const String routeName = 'permissions';
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Orientation orientation = MediaQuery.of(context).orientation;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: LayoutMargins(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Spacer(flex: 1),
            Expanded(
              flex: 2,
              child: Center(
                child: Column(
                  children: <Widget>[
                    SvgPicture.asset(
                      'assets/icons/svg/mgb_whitelogo.svg',
                      width: orientation == Orientation.portrait ? 100 : 75,
                    ),
                    const SizedBox(height: 30),
                    SvgPicture.asset(
                      'assets/images/svg/mgb_whitetext.svg',
                      height: orientation == Orientation.portrait ? 50 : 40,
                    )
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 4,
              child: PermissionControls(),
            ),
            Expanded(
                flex: 1,
                child: Center(
                    child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const MainScreen()));
                  },
                  child: const Text('Continue', style: TextStyle(fontSize: 20)),
                ))),
          ],
        ),
      ),
    );
  }
}
