import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:record/record.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';

class DeviceControls extends StatefulWidget {
  const DeviceControls(
      {super.key, required this.device, required this.onRecordingStart});

  final DeviceData device;
  final VoidCallback onRecordingStart;

  @override
  State<DeviceControls> createState() => _DeviceControlsState();
}

class _DeviceControlsState extends State<DeviceControls> {
  late final AudioRecorder _audioRecorder;

  bool _recordButtonPressed = false;
  bool _discardButtonPressed = false;
  bool _saveButtonPressed = false;
  bool _forceUpdatePressed = false;

  late final String _recordingDir;
  String? _currRecordingPath;

  @override
  void initState() {
    super.initState();
    _audioRecorder = AudioRecorder();
    // ensure recordings directory exists
    getApplicationDocumentsDirectory().then((appDocDir) {
      _recordingDir = path.join(appDocDir.path, 'audio_recordings');
      if (!Directory(_recordingDir).existsSync()) {
        Directory(_recordingDir).createSync();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: widget.device.statusNotifier,
      builder: (context, status, child) {
        switch (status) {
          case DeviceStatus.connected:
            _stopLocalRecording(upload: true).then((savedPath) {
              if (savedPath != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    context,
                    SnackBarType.warning,
                    'Stopped and saved local audio recording due to unscheduled recording end...'));
              }
            });
            return _buildConnectedControls(context);
          case DeviceStatus.disconnected:
            // ensure the local recording is stopped automatically if the device becomes disconnected for whatever reason
            _stopLocalRecording(upload: true).then((savedPath) {
              if (savedPath != null && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    context,
                    SnackBarType.warning,
                    'Stopped and saved local audio recording due to device disconnection...'));
              }
            });
            return _buildDisconnectedControls(context);
          case DeviceStatus.previewing:
            return _buildPreviewingControls(context);
          case DeviceStatus.recording:
            widget.onRecordingStart();
            return _buildRecordingControls(context);
        }
      },
    );
  }

  Widget _buildConnectedControls(BuildContext context) {
    return InkWell(
      onTap: _recordButtonPressed
          ? null
          : () async {
              setState(() {
                _recordButtonPressed = true;
              });

              final bool hasRecordingPermission =
                  await _audioRecorder.hasPermission();

              if (!hasRecordingPermission) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      context,
                      SnackBarType.warning,
                      'This device will NOT record audio locally...\nIf this was a mistake, please go to Settings and re-enable microphone permissions.',
                      const Duration(seconds: 10)));
                }
              }

              if (!context.mounted) return;
              final bool hasPatient =
                  context.read<PatientModel>().hasPatientData;

              if (!hasPatient) {
                ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                    context,
                    SnackBarType.error,
                    'Please select a patient before recording!'));
                return;
              }

              if (!context.mounted) return;
              final String patientID =
                  context.read<PatientModel>().patientData!.epicID;
              widget.device.startRecording(patientID).then((started) async {
                setState(() {
                  _recordButtonPressed = false;
                });

                if (!started) {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                      context,
                      SnackBarType.error,
                      'Failed to start recording... please check your device!'));
                } else if (hasRecordingPermission) {
                  // begin recording locally on device
                  final recordingTitle =
                      "patient_${patientID}_timestamp_${DateTime.now().millisecondsSinceEpoch}.wav";

                  _currRecordingPath = path.join(_recordingDir, recordingTitle);

                  debugPrint('Recording to: $_currRecordingPath');
                  await _audioRecorder.start(
                      const RecordConfig(encoder: AudioEncoder.wav),
                      path: _currRecordingPath!);

                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.success,
                        'Local audio recording started'));
                  }
                }
              });
            },
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.red.withOpacity(0.3),
      child: Ink(
        height: double.infinity,
        decoration: BoxDecoration(
            color: _recordButtonPressed ? Colors.grey.shade800 : Colors.black,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _recordButtonPressed
                ? const SizedBox(
                    height: 84,
                    width: 84,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: CircularProgressIndicator(
                        strokeAlign: BorderSide.strokeAlignInside,
                        color: Colors.red,
                        strokeWidth: 10,
                      ),
                    ))
                : const Icon(
                    Icons.fiber_manual_record_rounded,
                    size: 84,
                    color: Colors.red,
                  ),
            const SizedBox(width: 10),
            Text('REC',
                style: Theme.of(context)
                    .textTheme
                    .displayLarge!
                    .copyWith(color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _buildPreviewingControls(BuildContext context) {
    bool isBlocked = _discardButtonPressed || _saveButtonPressed;

    return Row(
      children: [
        Expanded(
            flex: 1,
            child: InkWell(
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20)),
              splashColor: Colors.red.withOpacity(0.3),
              onTap: isBlocked
                  ? null
                  : () {
                      setState(() {
                        _discardButtonPressed = true;
                      });
                      widget.device.discardRecording().then((discarded) {
                        setState(() {
                          _discardButtonPressed = false;
                        });
                        if (!discarded) {
                          ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                              context,
                              SnackBarType.error,
                              'Failed to delete recording... please check your device!'));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              getSnackBar(context, SnackBarType.success,
                                  'Successfully deleted recording!'));
                        }
                      });
                    },
              child: Ink(
                decoration: BoxDecoration(
                    color: _saveButtonPressed ? Colors.grey[400] : Colors.white,
                    border: const Border(
                        top: BorderSide(color: Colors.red, width: 5),
                        left: BorderSide(color: Colors.red, width: 5),
                        bottom: BorderSide(color: Colors.red, width: 5)),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        bottomLeft: Radius.circular(20))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('DISCARD',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    _discardButtonPressed
                        ? const SizedBox(
                            height: 64,
                            width: 64,
                            child: Padding(
                              padding: EdgeInsets.all(10.0),
                              child: CircularProgressIndicator(
                                color: Colors.red,
                                strokeWidth: 10,
                              ),
                            ),
                          )
                        : const Icon(Icons.cancel_outlined,
                            color: Colors.red, size: 64)
                  ],
                ),
              ),
            )),
        Container(
          width: 5,
          color: Colors.black,
        ),
        Expanded(
            flex: 1,
            child: InkWell(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20)),
                splashColor: Colors.green.withOpacity(0.3),
                onTap: isBlocked
                    ? null
                    : () {
                        setState(() {
                          _saveButtonPressed = true;
                        });
                        widget.device.saveRecording().then((saved) {
                          setState(() {
                            _saveButtonPressed = false;
                          });
                          if (!saved) {
                            ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                                context,
                                SnackBarType.error,
                                'Failed to save recording... please check your device!'));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                                getSnackBar(context, SnackBarType.success,
                                    'Successfully saved recording!'));
                          }
                        });
                      },
                child: Ink(
                  decoration: BoxDecoration(
                      color: _discardButtonPressed
                          ? Colors.grey[400]
                          : Colors.white,
                      border: const Border(
                          top: BorderSide(color: Colors.green, width: 5),
                          right: BorderSide(color: Colors.green, width: 5),
                          bottom: BorderSide(color: Colors.green, width: 5)),
                      borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(20),
                          bottomRight: Radius.circular(20))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'SAVE',
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall!
                            .copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      _saveButtonPressed
                          ? const SizedBox(
                              height: 64,
                              width: 64,
                              child: Padding(
                                padding: EdgeInsets.all(10.0),
                                child: CircularProgressIndicator(
                                  color: Colors.green,
                                  strokeWidth: 10,
                                ),
                              ),
                            )
                          : const Icon(
                              Icons.check_circle_outline_sharp,
                              color: Colors.green,
                              size: 64,
                            )
                    ],
                  ),
                )))
      ],
    );
  }

  Widget _buildRecordingControls(BuildContext context) {
    return InkWell(
      onTap: _recordButtonPressed
          ? null
          : () {
              setState(() {
                _recordButtonPressed = true;
              });

              widget.device.stopRecording().then((stopped) async {
                setState(() {
                  _recordButtonPressed = false;
                });
                final savedPath = await _stopLocalRecording(upload: true);

                if (!context.mounted) return;

                if (!stopped) {
                  if (savedPath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.warning,
                        'Saved local audio recording. Device failed to stop... please check your device!'));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.error,
                        'FATAL - Failed to stop recording locally and on the device... '));
                  }
                } else {
                  if (savedPath != null) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.success,
                        'Successfully stopped all recordings!'));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.error,
                        'Failed to stop recording locally...'));
                  }
                }
              });
            },
      borderRadius: BorderRadius.circular(20),
      splashColor: Colors.red.withOpacity(0.3),
      child: Ink(
        height: double.infinity,
        decoration: BoxDecoration(
            color: _recordButtonPressed ? Colors.grey.shade800 : Colors.black,
            borderRadius: BorderRadius.circular(20),
            border: _recordButtonPressed
                ? null
                : Border.all(color: Colors.red, width: 5),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ]),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _recordButtonPressed
                ? const SizedBox(
                    height: 84,
                    width: 84,
                    child: Padding(
                      padding: EdgeInsets.all(15.0),
                      child: CircularProgressIndicator(
                        strokeAlign: BorderSide.strokeAlignInside,
                        color: Colors.red,
                        strokeWidth: 10,
                      ),
                    ))
                : const Icon(
                    Icons.stop_circle_outlined,
                    size: 84,
                    color: Colors.red,
                  ),
            const SizedBox(width: 10),
            Text('STOP',
                style: Theme.of(context)
                    .textTheme
                    .displayMedium!
                    .copyWith(color: Colors.white))
          ],
        ),
      ),
    );
  }

  Widget _buildDisconnectedControls(BuildContext context) {
    return InkWell(
        onTap: _forceUpdatePressed
            ? null
            : () {
                setState(() {
                  _forceUpdatePressed = true;
                });

                widget.device.heartbeat.forceUpdate().then((health) {
                  setState(() {
                    _forceUpdatePressed = false;
                  });

                  if (!health) {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.error,
                        'Failed to refresh device status... please check your device!'));
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
                        context,
                        SnackBarType.success,
                        'Refreshed device status!'));
                  }
                });
              },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
            height: double.infinity,
            decoration: BoxDecoration(
                color: _forceUpdatePressed ? Colors.grey[400] : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.black, width: 5),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ]),
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Refresh',
                  style: Theme.of(context).textTheme.displayMedium!),
              const SizedBox(width: 10),
              _forceUpdatePressed
                  ? const SizedBox(
                      height: 75,
                      width: 75,
                      child: Padding(
                        padding: EdgeInsets.all(15.0),
                        child: CircularProgressIndicator(
                          strokeAlign: BorderSide.strokeAlignInside,
                          color: Colors.black,
                          strokeWidth: 10,
                        ),
                      ))
                  : const Icon(
                      Icons.refresh_sharp,
                      size: 75,
                      color: Colors.black,
                    )
            ])));
  }

  Future<String?> _stopLocalRecording({bool upload = true}) async {
    String? savedPath;
    if (_currRecordingPath != null || await _audioRecorder.isRecording()) {
      savedPath = await _audioRecorder.stop();
      _currRecordingPath = null;
    }

    if (upload && savedPath != null && context.mounted) {
      _uploadLocalRecording(savedPath);
    }

    return savedPath;
  }

  Future<void> _uploadLocalRecording(String recordingPath) async {
    widget.device.uploadRecording(recordingPath).then((bool success) {
      if (!context.mounted) return;

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context,
            SnackBarType.success,
            'Uploaded local audio recording to Dropbox!'));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context,
            SnackBarType.error,
            'Failed to upload local audio recording to Dropbox... please check your device!'));
      }
    });
  }
}
