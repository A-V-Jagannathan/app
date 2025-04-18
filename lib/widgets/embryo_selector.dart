import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/device_data_model.dart';
import 'package:witnessing_data_app/models/firebase/device_log_data_model.dart';
import 'package:witnessing_data_app/providers/embryo_provider.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';

class EmbryoSelector extends StatelessWidget {
  const EmbryoSelector(
      {super.key, required this.selectedDevice, required this.deviceStatus});

  final DeviceData selectedDevice;
  final DeviceStatus deviceStatus;

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientModel>(builder: (_, patientProvider, __) {
      final patient = patientProvider.patientData!;

      if (patient.cycles == null) {
        return Center(
            child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Text(
            "This patient has no cycles/embryos in the system.",
            style: Theme.of(context).textTheme.displaySmall,
            textAlign: TextAlign.center,
          ),
        ));
      }

      final activeCycle = patient.cycles!.last;

      return ShaderMask(
        shaderCallback: (bounds) => LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.center,
          colors: [Theme.of(context).colorScheme.surface, Colors.transparent],
          stops: const [0.0, 0.03],
        ).createShader(bounds),
        blendMode: BlendMode.dstOut,
        child: Consumer<EmbryoModel>(
          builder: (_, embryoProvider, __) {
            return GridView.builder(
                padding: const EdgeInsets.only(top: 10),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 4),
                shrinkWrap: true,
                itemCount: activeCycle.numEmbryos,
                itemBuilder: (context, index) {
                  final bool isSelected =
                      embryoProvider.selectedEmbryoIndex == index;
                  return GestureDetector(
                    onTap: () {
                      if (isSelected) {
                        embryoProvider.clearSelectedEmbryo();
                        if (deviceStatus == DeviceStatus.recording) {
                          debugPrint(
                              '[ EmrbyoSelection ] Logging an Embryo Deselection Event with Firebase');
                          selectedDevice.logEvent(
                              DeviceLogEvent.embryoSelection,
                              'Embryo ${index + 1} deselected after being selected');
                        }
                      } else {
                        embryoProvider.setSelectedEmbryo(
                            activeCycle.embryos![index], index);
                        // if the device is recording, additionally log when an embryo is selected
                        if (deviceStatus == DeviceStatus.recording) {
                          debugPrint(
                              '[ EmrbyoSelection ] Logging an Embryo Selection Event with Firebase');
                          selectedDevice.logEvent(
                              DeviceLogEvent.embryoSelection,
                              'Embryo ${index + 1}, Cycle ${activeCycle.cycleNum} selected');
                        }
                      }
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          color: isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: isSelected
                              ? const []
                              : [
                                  BoxShadow(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withOpacity(0.2),
                                      blurRadius: 3,
                                      spreadRadius: 2,
                                      offset: const Offset(0, 2)),
                                ]),
                      margin: const EdgeInsets.symmetric(horizontal: 10),
                      child: Center(
                        child: Text('Embryo \n${index + 1}',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  color: isSelected
                                      ? Theme.of(context).colorScheme.onPrimary
                                      : Theme.of(context).colorScheme.onSurface,
                                )),
                      ),
                    ),
                  );
                });
          },
        ),
      );
    });
  }
}
