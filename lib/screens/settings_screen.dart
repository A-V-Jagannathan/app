import 'package:flutter/material.dart';
import 'package:witnessing_data_app/configs/permissions.dart';
import 'package:witnessing_data_app/widgets/email_notification_entry.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/main_drawer.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';
import 'package:witnessing_data_app/widgets/permission_item.dart';

class SettingsScreen extends StatelessWidget {
  static const String routeName = '/settings';

  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PopScope(
        canPop: false,
        child: Scaffold(
          appBar: MGBAppBar(),
          drawer: MainDrawer(page: 'Settings'),
          body: LayoutMargins(
              child: SingleChildScrollView(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  PermissionsBlock(),
                  Divider(height: 40, thickness: 2),
                  EmailNotificationsBlock()
                ]),
          )),
        ));
  }
}

class PermissionsBlock extends StatelessWidget {
  const PermissionsBlock({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('App Permissions',
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) => PermissionItem(
                permissionType: appPermissions.keys.elementAt(index),
                explanationText: appPermissions.values.elementAt(index)),
            separatorBuilder: (context, index) => const SizedBox(height: 30),
            itemCount: appPermissions.length)
      ],
    );
  }
}

class EmailNotificationsBlock extends StatefulWidget {
  const EmailNotificationsBlock({super.key});

  @override
  State<EmailNotificationsBlock> createState() =>
      _EmailNotificationsBlockState();
}

class _EmailNotificationsBlockState extends State<EmailNotificationsBlock> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Email Notifications',
            style: Theme.of(context)
                .textTheme
                .displaySmall!
                .copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        Text(
            'Email notifications are sent to the email address listed below to alert you about any device that has gone offline unexpectedly.',
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(fontWeight: FontWeight.w500)),
        const SizedBox(height: 20),
        const EmailNotificationEntry(),
        const SizedBox(height: 20),
        const EmailNotificationsToggle(),
        const SizedBox(height: 10),
        const EmailNotificationInterval()
      ],
    );
  }
}
