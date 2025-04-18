import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/patient_data_model.dart';

class PatientInfo extends StatelessWidget {
  const PatientInfo({super.key, required this.patient});

  final PatientData patient;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: Theme.of(context).colorScheme.onSecondary,
            child: Icon(Icons.person,
                size: 64, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Patient Epic ID: ${patient.epicID}',
                  style: Theme.of(context).textTheme.headlineLarge),
              Text('Cycle: ${patient.currentCycleNum}',
                  style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ],
      ),
    );
  }
}
