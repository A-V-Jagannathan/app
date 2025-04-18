import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/patient_data_model.dart';

class CycleConfirmationDialog extends StatefulWidget {
  const CycleConfirmationDialog({super.key, required this.patient});

  final PatientData patient;

  @override
  State<CycleConfirmationDialog> createState() =>
      _CycleConfirmationDialogState();
}

class _CycleConfirmationDialogState extends State<CycleConfirmationDialog> {
  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      backgroundColor: Theme.of(context).dialogBackgroundColor.withOpacity(1),
      title: Text('Continue with current cycle?',
          style: Theme.of(context).textTheme.headlineMedium),
      content: SizedBox(
        height: screenSize.height * 0.25,
        width: screenSize.width * 0.75,
        child: Center(
            child: Text(
          "Patient ${widget.patient.epicID} is currently on Cycle ${widget.patient.currentCycleNum}.\nDo you want to continue with this cycle or start a new one?",
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium,
        )),
      ),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.only(bottom: 35),
      actions: [
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context, true);
          },
          style: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
              minimumSize: const Size(150, 50),
              backgroundColor: Theme.of(context).colorScheme.onPrimary,
              foregroundColor: Theme.of(context).colorScheme.primary),
          child: const Text('New Cycle'),
        ),
        const SizedBox(width: 20),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              textStyle: Theme.of(context).textTheme.titleLarge,
              minimumSize: const Size(150, 50),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary),
          onPressed: () {
            Navigator.pop(context, false);
          },
          child: const Text('Continue'),
        ),
      ],
    );
  }
}
