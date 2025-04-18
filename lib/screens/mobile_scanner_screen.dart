import 'dart:async';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/qr_code_model.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';
import 'package:witnessing_data_app/screens/patient_screen.dart';
import 'package:witnessing_data_app/screens/selected_device_screen.dart';
import 'package:witnessing_data_app/utilities/patient_screen_args.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';
import 'package:witnessing_data_app/widgets/scan_result.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';
import 'package:witnessing_data_app/widgets/mobile_scanner_buttons.dart';
import 'package:witnessing_data_app/widgets/mobile_scanner_error.dart';

class MobileScannerScreen extends StatefulWidget {
  final QRCodeType? lookFor;
  const MobileScannerScreen({super.key, this.lookFor});

  @override
  State<MobileScannerScreen> createState() => _MobileScannerScreenState();
}

class _MobileScannerScreenState extends State<MobileScannerScreen>
    with WidgetsBindingObserver {
  final MobileScannerController controller = MobileScannerController(
    torchEnabled: false, useNewCameraSelector: true,
    // formats: [BarcodeFormat.qrCode]
    // facing: CameraFacing.front,
    // detectionSpeed: DetectionSpeed.normal
    // detectionTimeoutMs: 1000,
    // returnImage: false,
  );

  bool _snackBarActive = false;
  bool _isProcessingScan = false;
  Barcode? _barcode;
  StreamSubscription<Object?>? _subscription;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _subscription = controller.barcodes.listen(_handleBarcode);

    unawaited(controller.start());
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!controller.value.isInitialized) {
      return;
    }

    switch (state) {
      case AppLifecycleState.detached:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        return;
      case AppLifecycleState.resumed:
        _subscription = controller.barcodes.listen(_handleBarcode);
        unawaited(controller.start());
      case AppLifecycleState.inactive:
        unawaited(_subscription?.cancel());
        _subscription = null;
        unawaited(controller.stop());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MGBAppBar(),
      body: LayoutMargins(
        child: Column(
          children: [
            Expanded(
              flex: 5,
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 40, 20, 20),
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.black),
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: controller,
                      errorBuilder: (context, error, child) {
                        return ScannerErrorWidget(error: error);
                      },
                      fit: BoxFit.contain,
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        alignment: Alignment.bottomCenter,
                        height: 100,
                        decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20))),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Expanded(
                              flex: 1,
                              child: StartStopMobileScannerButton(
                                  controller: controller),
                            ),
                            Expanded(
                                flex: 6,
                                child: ScanResult(
                                  controller: controller,
                                  barcode: _barcode,
                                )),
                            Expanded(
                              flex: 1,
                              child: SwitchCameraButton(controller: controller),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const Expanded(
              flex: 1,
              child: SizedBox(),
            )
          ],
        ),
      ),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (!mounted) return;

    _barcode = barcodes.barcodes.firstOrNull;
    if (_barcode == null) return;
    // Sets the state to update the UI with the barcode value
    setState(() {});

    // only continue if the barcode has a display value and there's no current scan processing
    if (_barcode!.displayValue == null || _isProcessingScan) {
      return;
    }

    // ensure that the scan is not processed multiple times
    _isProcessingScan = true;
    final QRCode qrCode = _processBarcode(_barcode!.displayValue!);

    if (widget.lookFor != null && qrCode.codeType != widget.lookFor) {
      _showInSnackBar(
          "[Error] Scanned '${qrCode.codeType.name}' code. Expected '${widget.lookFor!.name}' code.");
      _isProcessingScan = false;
      return;
    }

    _navigateToScreen(qrCode);
  }

  @override
  Future<void> dispose() async {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_subscription?.cancel());
    _subscription = null;
    super.dispose();
    await controller.dispose();
  }

  void _showInSnackBar(String message) {
    if (_snackBarActive) {
      return;
    }

    _snackBarActive = true;
    ScaffoldMessenger.of(context)
        .showSnackBar(getSnackBar(context, SnackBarType.error, message))
        .closed
        .then((reason) {
      _snackBarActive = false;
    });
  }

  QRCode _processBarcode(String displayValue) {
    bool isDeviceQRCode = InternetAddress.tryParse(displayValue) != null;
    if (isDeviceQRCode) {
      return DeviceQRCode(deviceIP: displayValue);
    }

    bool isValidURL = Uri.tryParse(displayValue)?.hasAbsolutePath ?? false;
    bool isSentence = displayValue.contains(' ');
    bool isPotentialEmail = displayValue.contains('@');
    if (isValidURL || isSentence || isPotentialEmail) {
      _showInSnackBar("Unknown QR Code Found: [ Error ] Invalid Type");
      return UnknownQRCode();
    }

    // if not obviously a device code or unknown, then we consider it a patient
    // this will allow for pre-existing and new patients
    return PatientQRCode(patientID: displayValue);
  }

  Future<void> _navigateToScreen(QRCode code) async {
    final contextPatientData = context.read<PatientModel>().patientData;
    switch (code.codeType) {
      case QRCodeType.patient:
        await Navigator.pushReplacementNamed(context, PatientScreen.routeName,
                arguments: PatientScreenArgs((code as PatientQRCode).patientID))
            .then((value) => _isProcessingScan = false);

      case QRCodeType.device:
        if (contextPatientData == null) {
          _showInSnackBar(
              'No patient data to reference. Scan Patient QR Code first.');
          _isProcessingScan = false;
          break;
        }
        await Navigator.pushReplacementNamed(
                context, SelectedDeviceScreen.routeName,
                arguments: InternetAddress((code as DeviceQRCode).deviceIP))
            .then((value) => _isProcessingScan = false);
      default:
        _showInSnackBar("Unknown QR Code Found: [ Error ] Invalid Type");
        _isProcessingScan = false;
    }
  }
}
