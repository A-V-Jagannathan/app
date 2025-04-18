import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witnessing_data_app/models/firebase/embryo_model.dart';
import 'package:witnessing_data_app/models/firebase/patient_cycle_model.dart';
import 'package:witnessing_data_app/models/firebase/patient_data_model.dart';
import 'package:witnessing_data_app/providers/patient_provider.dart';
import 'package:witnessing_data_app/screens/patient_screen.dart';
import 'package:witnessing_data_app/services/patient_service.dart';
import 'package:witnessing_data_app/utilities/patient_screen_args.dart';
import 'package:witnessing_data_app/utilities/snackbars.dart';
import 'package:witnessing_data_app/widgets/embryo_form_card.dart';
import 'package:witnessing_data_app/widgets/embryo_num_picker.dart';

class NewPatientCycleForm extends StatefulWidget {
  const NewPatientCycleForm({super.key});

  @override
  State<NewPatientCycleForm> createState() => _NewPatientCycleFormState();
}

class _NewPatientCycleFormState extends State<NewPatientCycleForm> {
  final _formKey = GlobalKey<FormState>();

  int _numEmbryos = 1;
  late List<EmbryoData> _embryoList;
  final ValueNotifier<bool> _autoID = ValueNotifier<bool>(true);

  bool _submitting = false;
  bool _isEditing = false;
  late final PatientData _displayPatient;

  @override
  void initState() {
    super.initState();
    final patient = context.read<PatientModel>().patientData!;
    _displayPatient = patient.copyWith();
    _embryoList = List.generate(
        _numEmbryos,
        (index) => EmbryoData(
              id: '${patient.embryoscopeID}_${index + 1}',
              embryoNumber: index + 1,
            ));
  }

  @override
  Widget build(BuildContext context) {
    final patient = context.read<PatientModel>().patientData!;

    return SizedBox(
      width: double.infinity,
      child: Form(
        key: _formKey,
        child: Column(children: [
          NewPatientInfo(patient: _displayPatient),
          const SizedBox(height: 20),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Row(children: [
              SizedBox(
                width: 225,
                child: Text('Number of Embryos in Cycle',
                    softWrap: true,
                    style: Theme.of(context).textTheme.titleLarge),
              ),
              const SizedBox(width: 15),
              EmbryoNumberPicker(
                  onIncrease: () => setState(() {
                        _numEmbryos++;
                        _embryoList.add(EmbryoData(
                            id: '${patient.embryoscopeID}_$_numEmbryos',
                            embryoNumber: _numEmbryos));
                      }),
                  onDecrease: () => setState(() {
                        _numEmbryos--;
                        _embryoList.removeLast();
                      }))
            ]),
            const SizedBox(width: 10),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Text('Auto-ID Embryos',
                  style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(width: 15),
              Transform.scale(
                scale: 2,
                child: Checkbox(
                    materialTapTargetSize: MaterialTapTargetSize.padded,
                    value: _autoID.value,
                    onChanged: (checked) {
                      _autoID.value = checked!;
                      setState(() {});
                    }),
              )
            ])
          ]),
          const SizedBox(height: 10),
          Expanded(
              child: GridView(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 10,
                    childAspectRatio: 1 / 0.34,
                  ),
                  shrinkWrap: true,
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 40),
                  children: _embryoList
                      .map((embryo) =>
                          EmbryoFormCard(embryo: embryo, autoID: _autoID))
                      .toList())),
          Padding(
              padding: const EdgeInsets.symmetric(vertical: 25),
              child: Center(
                  child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          disabledBackgroundColor: Colors.grey[400],
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                          padding: _submitting
                              ? const EdgeInsets.symmetric(horizontal: 30)
                              : const EdgeInsets.fromLTRB(30, 15, 30, 15)),
                      onPressed: _submitAndAddCycle,
                      child: _submitting
                          ? SizedBox(
                              width: 72,
                              height: 54,
                              child: Center(
                                child: CircularProgressIndicator(
                                  color:
                                      Theme.of(context).colorScheme.onPrimary,
                                ),
                              ),
                            )
                          : Text("Continue",
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      fontWeight: FontWeight.w600)))))
        ]),
      ),
    );
  }

  Future<void> _submitAndAddCycle() async {
    debugPrint('submitting new cycle');
    setState(() {
      _submitting = true;
    });

    if (_formKey.currentState!.validate()) {
      final patient = context.read<PatientModel>().patientData!;

      PatientCycle nextCycle;
      bool submitSuccess = false;
      if (!_isEditing) {
        patient.currentCycleNum++;
        patient.totalNumCycles++;

        nextCycle = PatientCycle(
            cycleNum: patient.currentCycleNum,
            numEmbryos: _numEmbryos,
            embryos: _embryoList,
            cycleStartDate: DateTime.now());
        submitSuccess = await PatientService.addNewCycle(patient, nextCycle);
      } else {
        nextCycle = patient.cycles!.last;
        nextCycle.numEmbryos = _numEmbryos;
        nextCycle.embryos = _embryoList;
        submitSuccess = await PatientService.updateNewCycle(patient, nextCycle);
      }

      if (submitSuccess) {
        if (!mounted) return;
        context.read<PatientModel>().patientData = patient;
        Navigator.of(context)
            .pushNamed(PatientScreen.routeName,
                arguments: PatientScreenArgs(patient.embryoscopeID, false))
            .then((value) => setState(() {
                  _isEditing = true;
                  debugPrint('Editing mode for newly created cycle activated');
                }));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context,
            SnackBarType.error,
            "Something went wrong... Unable to ${_isEditing ? 'update' : 'create'} new cycle."));
      }
    }

    setState(() {
      _submitting = false;
    });
  }
}

class NewPatientInfo extends StatelessWidget {
  const NewPatientInfo({super.key, required this.patient});

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
              Text('New Cycle: ${patient.currentCycleNum + 1}',
                  style: Theme.of(context).textTheme.headlineLarge),
            ],
          ),
        ],
      ),
    );
  }
}
