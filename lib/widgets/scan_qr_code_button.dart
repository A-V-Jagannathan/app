import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/qr_code_model.dart';
import 'package:witnessing_data_app/screens/mobile_scanner_screen.dart';

class ScanQRCodeButton extends StatelessWidget {
  final Text? buttonText;
  final EdgeInsets? buttonPadding;
  final QRCodeType? lookFor;
  final VoidCallback? onPriorToPush;

  const ScanQRCodeButton({
    super.key,
    this.buttonText,
    this.buttonPadding,
    this.lookFor,
    this.onPriorToPush,
  });

  @override
  Widget build(BuildContext context) {
    final Text buttonText = this.buttonText ??
        Text(
          'Scan Patient QR Code',
          style: Theme.of(context).textTheme.displaySmall,
        );
    final EdgeInsets buttonPadding =
        this.buttonPadding ?? const EdgeInsets.all(45.0); // (1

    return Center(
      child: GestureDetector(
          onTap: () {
            // execute function before pushing to the next screen
            onPriorToPush?.call();
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MobileScannerScreen(
                          lookFor: lookFor,
                        )));
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color:
                      Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                  blurRadius: 15,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Card(
              child: Padding(
                  padding: buttonPadding,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(Icons.qr_code_scanner_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                          size: 48),
                      const SizedBox(width: 30),
                      buttonText
                    ],
                  )),
            ),
          )),
    );
  }
}
