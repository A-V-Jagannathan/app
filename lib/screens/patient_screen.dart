import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/dialogs/cycle_confirmation_dialog.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/models/qr_code_model.dart';
import 'package:witnessing_data_app/providers/device_provider.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';
import 'package:witnessing_data_app/screens/selected_device_screen.dart';
import 'package:witnessing_data_app/widgets/device_selector.dart';
import 'package:witnessing_data_app/widgets/new_patient_cycle_form.dart';
import 'package:witnessing_data_app/widgets/new_patient_form.dart';
import 'package:witnessing_data_app/widgets/patient_info.dart';
import 'package:witnessing_data_app/widgets/layout_margins.dart';
import 'package:witnessing_data_app/widgets/mgb_app_bar.dart';
import 'package:witnessing_data_app/widgets/full_page_lookup_progress.dart';
import 'package:witnessing_data_app/widgets/scan_qr_code_button.dart';

class PatientScreen extends StatefulWidget {
  static const String routeName = '/patients';

  final String emrbyoscopeID;
  final bool clearPatientOnPop;

  const PatientScreen(
      {super.key, required this.emrbyoscopeID, this.clearPatientOnPop = true});

  @override
  State<PatientScreen> createState() => _PatientScreenState();
}

class _PatientScreenState extends State<PatientScreen> {
  late final Future<bool?> _patientDataFuture;
  bool _startNewCycle = false;

  @override
  void initState() {
    super.initState();
    final patientProvider = context.read<PatientModel>();
    if (!patientProvider.hasPatientData) {
      _patientDataFuture =
          patientProvider.loadPatient(widget.emrbyoscopeID).then((success) {
        if (success == null) {
          return null;
        } else {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            await Future.delayed(const Duration(milliseconds: 300), () async {
              _startNewCycle = await showDialog(
                  context: context,
                  builder: (context) => CycleConfirmationDialog(
                        patient: patientProvider.patientData!,
                      ),
                  barrierDismissible: false);
              setState(() {});
            });
          });
          return true;
        }
      });
    } else {
      _patientDataFuture = Future.value(true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        onPopInvoked: (didPop) {
          if (didPop) {
            if (widget.clearPatientOnPop) {
              context.read<PatientModel>().clearPatientData(notify: false);
            }
            context.read<DeviceModel>().clearSelectedDevice();
          }
        },
        child: Scaffold(
            appBar: const MGBAppBar(),
            body: LayoutMargins(
                child: FutureBuilder(
                    future: _patientDataFuture,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        if (snapshot.hasData) {
                          final patient =
                              context.read<PatientModel>().patientData!;

                          if (_startNewCycle == true) {
                            return const NewPatientCycleForm();
                          }
                          return Column(
                            children: [
                              PatientInfo(patient: patient),
                              const SizedBox(height: 20),
                              Consumer<DeviceModel>(
                                builder: (_, deviceProvider, __) {
                                  return ScanQRCodeButton(
                                    buttonText: Text("Scan Device QR Code",
                                        style: Theme.of(context)
                                            .textTheme
                                            .headlineMedium),
                                    buttonPadding: const EdgeInsets.fromLTRB(
                                        30, 20, 30, 20),
                                    lookFor: QRCodeType.device,
                                    onPriorToPush: () {
                                      deviceProvider.clearSelectedDevice();
                                    },
                                  );
                                },
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Text(
                                    "Or select a device from below...",
                                    style:
                                        Theme.of(context).textTheme.titleLarge,
                                  ),
                                  _buildDeviceContinueButton()
                                ],
                              ),
                              const SizedBox(height: 20),
                              // const cannot be added here because it needs to change when the context gets popped!
                              Expanded(child: DeviceSelector()),
                            ],
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Error: ${snapshot.error}',
                                style:
                                    Theme.of(context).textTheme.displaySmall),
                          );
                        } else {
                          return NewPatientForm(
                              embryoscopeID: widget.emrbyoscopeID);
                        }
                      } else if (snapshot.connectionState ==
                          ConnectionState.waiting) {
                        return FullPageLookupProgress(
                            progressText:
                                "Looking up Patient\n'${widget.emrbyoscopeID}'");
                      }
                      return const SizedBox.shrink();
                      // ConnectionState is not finished
                    }))));
  }

  Widget _buildDeviceContinueButton() {
    return Selector<DeviceModel, DeviceData?>(
        selector: (_, deviceProvider) => deviceProvider.selectedDevice,
        builder: (_, selectedDevice, __) {
          if (selectedDevice == null) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                disabledBackgroundColor: Colors.grey[400],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              onPressed: null,
              child: Text("Continue",
                  style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600)),
            );
          } else {
            return ValueListenableBuilder(
                valueListenable: selectedDevice.statusNotifier,
                builder: (context, status, _) {
                  final bool selectable = status == DeviceStatus.connected;
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      disabledBackgroundColor: Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    onPressed: selectable
                        ? () async {
                            await Navigator.of(context)
                                .pushNamed(SelectedDeviceScreen.routeName,
                                    arguments: selectedDevice.ipAddress)
                                // setState is called to update the UI once it returns from the screen
                                .then((value) => setState(() {}));
                          }
                        : null,
                    child: Text("Continue",
                        style: selectable
                            ? Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onPrimary,
                                fontWeight: FontWeight.w600)
                            : Theme.of(context).textTheme.bodyMedium!.copyWith(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w600)),
                  );
                });
          }
        });
  }
}
