import 'package:flutter/material.dart';

enum SnackBarType { error, success, warning, info }

SnackBar getSnackBar(BuildContext context, SnackBarType type, String message,
    [Duration duration = const Duration(seconds: 4)]) {
  final Color backgroundColor = switch (type) {
    SnackBarType.error => Theme.of(context).colorScheme.error,
    SnackBarType.success => Colors.green,
    SnackBarType.warning => Colors.amber,
    SnackBarType.info => Colors.grey
  };

  final Color textColor =
      switch (type) { SnackBarType.warning => Colors.black, _ => Colors.white };

  return SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.fromLTRB(100, 20, 100, 80),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: backgroundColor,
      duration: duration,
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: Theme.of(context)
            .textTheme
            .bodyLarge!
            .copyWith(color: textColor, fontWeight: FontWeight.w600),
      ));
}
