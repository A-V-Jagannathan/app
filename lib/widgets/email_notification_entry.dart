import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/notification_profile_model.dart';
import 'package:witnessing_data_app/providers/settings_provider.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';

class EmailNotificationsToggle extends StatelessWidget {
  const EmailNotificationsToggle({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsModel>(
      builder: (_, settingsModel, __) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                flex: 3,
                child: Text('Allow Notifications',
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              Expanded(
                flex: 1,
                child: Center(
                  child: SizedBox(
                    width: 65,
                    child: FittedBox(
                      fit: BoxFit.fill,
                      child: Switch(
                          value: settingsModel
                              .notificationProfile.allowNotifications,
                          onChanged: (value) async {
                            await settingsModel.updateAllowNotifications(value);
                          }),
                    ),
                  ),
                ),
              )
            ]);
      },
    );
  }
}

class EmailNotificationEntry extends StatefulWidget {
  const EmailNotificationEntry({super.key});

  @override
  State<EmailNotificationEntry> createState() => _EmailNotificationEntryState();
}

class _EmailNotificationEntryState extends State<EmailNotificationEntry> {
  late final SettingsModel _settingsModel;
  late final TextEditingController _emailController;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _emailError = false;
  bool _emailChanged = false;

  final errorBorder = const OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2));

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _settingsModel = context.read<SettingsModel>();
    _emailController.text = _settingsModel.notificationProfile.email;
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalBorder = OutlineInputBorder(
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2));
    return Row(
      children: [
        Expanded(
            flex: 3,
            child: Form(
                key: _formKey,
                child: TextFormField(
                    controller: _emailController,
                    autocorrect: false,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    textInputAction: TextInputAction.done,
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).colorScheme.onPrimary,
                        border: normalBorder,
                        enabledBorder: normalBorder,
                        errorBorder: _emailError ? errorBorder : normalBorder,
                        focusedErrorBorder:
                            _emailError ? errorBorder : normalBorder,
                        hintText: 'Enter email to receive notifications at',
                        contentPadding: const EdgeInsets.all(10),
                        errorStyle:
                            const TextStyle(fontSize: 0, color: Colors.black)),
                    validator: (value) {
                      value = value?.trim();

                      String? errorText;
                      bool hasError = false;

                      if (value == null || value.isEmpty) {
                        errorText = null;
                        hasError = false;
                      } else if (!EmailValidator.validate(value)) {
                        errorText = 'Invalid email format';
                        hasError = true;
                      }

                      _emailError = hasError;
                      return errorText;
                    },
                    // onTap: () {
                    //   setState(() {
                    //     _emailError = false;
                    //   });
                    // },
                    onChanged: (value) {
                      setState(() {
                        _emailChanged = true;
                      });
                    },
                    onFieldSubmitted: (_) => _validateEmail(context)))),
        Expanded(
          flex: 1,
          child: Center(
            child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary),
                onPressed: _emailChanged || _emailError
                    ? () {
                        // close the keyboard so that the snackbar won't be covering the text input
                        FocusManager.instance.primaryFocus?.unfocus();
                        _validateEmail(context);
                      }
                    : null,
                child: const Text('Save Email')),
          ),
        )
      ],
    );
  }

  Future<void> _validateEmail(BuildContext context) async {
    if (!_emailChanged && !_emailError) {
      debugPrint('No change + no error. No need to validate.');
      return;
    }

    setState(() {
      _emailChanged = false;
    });
    _formKey.currentState!.validate();

    if (!_emailError) {
      _emailController.text = _emailController.text.trim();
      await _settingsModel.updateEmail(_emailController.text);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            getSnackBar(context, SnackBarType.success, "Email saved!"));
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context, SnackBarType.error, "Cannot save Invalid Email"));
      }
    }
  }
}

class EmailNotificationInterval extends StatelessWidget {
  const EmailNotificationInterval({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Text('Repeat Notification Frequency',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(width: 5),
            IconButton(
                onPressed: () async {
                  await showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                            title: const Text('Repeat Notification Frequency'),
                            backgroundColor: Theme.of(context)
                                .dialogBackgroundColor
                                .withOpacity(1),
                            contentPadding:
                                const EdgeInsets.fromLTRB(24, 20, 24, 0),
                            content: SizedBox(
                                width: 400,
                                child: Text(
                                  'This is the time interval between consecutive email notifications. If the same device(s) are offline after the specified period, another email reminder will be sent. Shorter intervals indicate the potential to receive more emails, but provide more timely updates regarding device statuses.',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                )),
                            actionsPadding:
                                const EdgeInsets.fromLTRB(24, 0, 24, 10),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Close'))
                            ],
                          ));
                },
                icon: const Icon(Icons.info_outlined),
                iconSize: 28,
                color: Colors.grey)
          ],
        ),
        Consumer<SettingsModel>(
          builder: (_, settingsModel, __) => SegmentedButton(
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.fromLTRB(15, 5, 15, 5),
                backgroundColor: Theme.of(context).colorScheme.onPrimary,
                foregroundColor: Theme.of(context).colorScheme.primary,
                selectedBackgroundColor: Theme.of(context).colorScheme.primary,
                selectedForegroundColor:
                    Theme.of(context).colorScheme.onPrimary,
              ),
              selected: {
                settingsModel.notificationProfile.notificationInterval
              },
              showSelectedIcon: false,
              // selectedIcon: const Icon(Icons.check, size: 14),
              multiSelectionEnabled: false,
              emptySelectionAllowed: false,
              onSelectionChanged: (Set<NotificationInterval> selected) {
                settingsModel.updateRepeatNotificationFrequency(selected.first);
              },
              segments: NotificationInterval.values
                  .map<ButtonSegment<NotificationInterval>>(
                      (NotificationInterval interval) => ButtonSegment(
                          value: interval, label: Text(interval.value)))
                  .toList()),
        )
      ],
    );
  }
}
