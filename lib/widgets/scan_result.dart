import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanResult extends StatelessWidget {
  ScanResult({super.key, required this.controller, this.barcode});

  final MobileScannerController controller;
  Barcode? barcode;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: controller,
      builder: (context, state, child) {
        if (!state.isInitialized) {
          return Center(
              child: Text(
            'Initializing...',
            overflow: TextOverflow.fade,
            style: Theme.of(context)
                .textTheme
                .bodyLarge!
                .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
          ));
        } else if (!state.isRunning) {
          barcode = null;
          return Center(
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.withOpacity(0.4)),
              icon: const Icon(Icons.qr_code_scanner_rounded,
                  color: Colors.white, size: 32),
              label: Text('Start Scanner',
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall!
                      .copyWith(color: Colors.white)),
              onPressed: () async {
                await controller.start();
              },
            ),
          );
        }

        final Widget textChild;

        if (state.isRunning) {
          if (barcode == null) {
            textChild = Text(
              'Point the camera at a QR Code',
              overflow: TextOverflow.fade,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            );
          } else {
            textChild = Text(
              barcode!.displayValue == null
                  ? 'No display value.'
                  : 'Scan Successful!',
              overflow: TextOverflow.fade,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge!
                  .copyWith(color: Colors.white, fontWeight: FontWeight.w600),
            );
          }
        } else {
          textChild = const SizedBox.shrink();
        }

        return Center(
          child: textChild,
        );
      },
    );
  }
}
