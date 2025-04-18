import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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

class NewPatientForm extends StatefulWidget {
  const NewPatientForm({super.key, required this.embryoscopeID});

  final String embryoscopeID;

  @override
  State<NewPatientForm> createState() => _NewPatientFormState();
}

class _NewPatientFormState extends State<NewPatientForm> {
  final _formKey = GlobalKey<FormState>();

  late final Map<String, TextEditingController> _textControllers;
  late final Map<String, FocusNode> _focusNodes;

  int _numEmbryos = 1;
  late List<EmbryoData> _embryoList;
  final ValueNotifier<bool> _autoID = ValueNotifier<bool>(true);

  bool _submitting = false;
  bool _isEditing = false;

  // Error flags for form validation
  bool _firstNameError = false;
  bool _lastNameError = false;
  bool _birthdayError = false;
  bool _epicPatientIDError = false;

  @override
  void initState() {
    super.initState();
    _textControllers = {
      'firstName': TextEditingController(),
      'lastName': TextEditingController(),
      'dateOfBirth': TextEditingController(),
      'epicPatientID': TextEditingController()
    };
    _focusNodes = {
      'lastName': FocusNode(),
      'dateOfBirth': FocusNode(),
      'epicPatientID': FocusNode()
    };
    _textControllers['dateOfBirth']!.addListener(() {
      if (_textControllers['dateOfBirth']!.text.isNotEmpty) {
        debugPrint('Requesting focus on epic patient number');
        FocusScope.of(context).requestFocus(_focusNodes['epicPatientID']);
      } else {
        debugPrint('Date of birth is empty');
      }
    });
    _embryoList = [
      EmbryoData(id: '${widget.embryoscopeID}_1', embryoNumber: 1)
    ];
  }

  @override
  void dispose() {
    _textControllers.forEach((_, controller) => controller.dispose());
    _focusNodes.forEach((_, focusNode) => focusNode.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final normalBorder = OutlineInputBorder(
        borderSide:
            BorderSide(color: Theme.of(context).colorScheme.primary, width: 2));
    const errorBorder =
        OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2));

    return SizedBox(
        width: double.infinity,
        child: Form(
          key: _formKey,
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('New Patient Form',
                style: Theme.of(context).textTheme.displaySmall),
            const SizedBox(height: 10),
            Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [PatientInfoID(embryoscopeID: widget.embryoscopeID)]),
            const SizedBox(height: 10),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('First Name',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                controller: _textControllers['firstName'],
                                style: Theme.of(context).textTheme.titleMedium,
                                decoration: InputDecoration(
                                    filled: true,
                                    fillColor:
                                        Theme.of(context).colorScheme.onPrimary,
                                    border: normalBorder,
                                    enabledBorder: normalBorder,
                                    errorBorder: _firstNameError
                                        ? errorBorder
                                        : normalBorder,
                                    focusedErrorBorder: _firstNameError
                                        ? errorBorder
                                        : normalBorder,
                                    hintText: _firstNameError
                                        ? 'First name is required'
                                        : null,
                                    hintStyle: _firstNameError
                                        ? Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(color: Colors.red)
                                        : null,
                                    contentPadding: const EdgeInsets.all(10),
                                    errorStyle: const TextStyle(
                                        fontSize: 0, color: Colors.black)),
                                validator: (value) {
                                  if (value == null ||
                                      value.isEmpty ||
                                      value.trim().isEmpty) {
                                    setState(() {
                                      _firstNameError = true;
                                    });
                                    return '';
                                  }
                                  return null;
                                },
                                onTap: () => setState(
                                  () {
                                    _firstNameError = false;
                                  },
                                ),
                                onFieldSubmitted: (_) =>
                                    _focusNodes['lastName']!.requestFocus(),
                                textInputAction: TextInputAction.next,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text('Date of Birth',
                                style: Theme.of(context).textTheme.titleLarge),
                            const SizedBox(height: 5),
                            SizedBox(
                              width: 300,
                              child: TextFormField(
                                  controller: _textControllers['dateOfBirth'],
                                  focusNode: _focusNodes['dateOfBirth']!,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      border: normalBorder,
                                      enabledBorder: normalBorder,
                                      errorBorder: _birthdayError
                                          ? errorBorder
                                          : normalBorder,
                                      focusedErrorBorder: _birthdayError
                                          ? errorBorder
                                          : normalBorder,
                                      hintText: _birthdayError
                                          ? 'Date of birth is required'
                                          : null,
                                      hintStyle: _birthdayError
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.red)
                                          : null,
                                      contentPadding: const EdgeInsets.all(10),
                                      errorStyle: const TextStyle(
                                          fontSize: 0, color: Colors.black)),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().isEmpty) {
                                      setState(() {
                                        _birthdayError = true;
                                      });
                                      return '';
                                    }
                                    return null;
                                  },
                                  onTap: () {
                                    setState(
                                      () {
                                        _birthdayError = false;
                                      },
                                    );
                                    _selectDate(context);
                                  },
                                  onTapAlwaysCalled: true,
                                  onChanged: (_) =>
                                      debugPrint('changed date of birth'),
                                  onEditingComplete: () => debugPrint(
                                      'editing complete date of birth'),
                                  onFieldSubmitted: (_) {
                                    debugPrint('submitted date of birth');
                                    _focusNodes['epicPatientID']!
                                        .requestFocus();
                                  },
                                  textInputAction: TextInputAction.next),
                            )
                          ])),
                  const Spacer(flex: 1),
                  Expanded(
                    flex: 3,
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Last Name',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 5),
                          SizedBox(
                              width: 300,
                              child: TextFormField(
                                  controller: _textControllers['lastName'],
                                  focusNode: _focusNodes['lastName']!,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      border: normalBorder,
                                      enabledBorder: normalBorder,
                                      errorBorder: _lastNameError
                                          ? errorBorder
                                          : normalBorder,
                                      focusedErrorBorder: _lastNameError
                                          ? errorBorder
                                          : normalBorder,
                                      hintText: _lastNameError
                                          ? 'Last name is required'
                                          : null,
                                      hintStyle: _lastNameError
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.red)
                                          : null,
                                      contentPadding: const EdgeInsets.all(10),
                                      errorStyle: const TextStyle(
                                          fontSize: 0, color: Colors.black)),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().isEmpty) {
                                      setState(() {
                                        _lastNameError = true;
                                      });
                                      return '';
                                    }
                                    return null;
                                  },
                                  onTap: () => setState(() {
                                        _lastNameError = false;
                                      }),
                                  onFieldSubmitted: (_) {
                                    _focusNodes['dateOfBirth']!.requestFocus();
                                    _selectDate(context);
                                  },
                                  textInputAction: TextInputAction.next)),
                          const SizedBox(height: 10),
                          Text('Epic Patient ID',
                              style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 5),
                          SizedBox(
                              width: 300,
                              child: TextFormField(
                                  controller: _textControllers['epicPatientID'],
                                  focusNode: _focusNodes['epicPatientID']!,
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Theme.of(context)
                                          .colorScheme
                                          .onPrimary,
                                      border: normalBorder,
                                      enabledBorder: normalBorder,
                                      errorBorder: _epicPatientIDError
                                          ? errorBorder
                                          : normalBorder,
                                      focusedErrorBorder: _epicPatientIDError
                                          ? errorBorder
                                          : normalBorder,
                                      hintText: _epicPatientIDError
                                          ? 'Epic Patient Number is required'
                                          : null,
                                      hintStyle: _epicPatientIDError
                                          ? Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.red)
                                          : null,
                                      contentPadding: const EdgeInsets.all(10),
                                      errorStyle: const TextStyle(
                                          fontSize: 0, color: Colors.black)),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        value.trim().isEmpty) {
                                      setState(() {
                                        _epicPatientIDError = true;
                                      });
                                      return '';
                                    }
                                    return null;
                                  },
                                  onTap: () => setState(() {
                                        _epicPatientIDError = false;
                                      }),
                                  onFieldSubmitted: (_) =>
                                      FocusScope.of(context).unfocus(),
                                  textInputAction: TextInputAction.go))
                        ]),
                  )
                ]),
            const SizedBox(height: 10),
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
                              id: '${widget.embryoscopeID}_$_numEmbryos',
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
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
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
                        onPressed: _submitAndCreatePatient,
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
        ));
  }

  Future<void> _submitAndCreatePatient() async {
    debugPrint('submitting form');
    setState(() {
      _submitting = true;
    });
    if (_formKey.currentState!.validate()) {
      final newPatientData = PatientData(
          embryoscopeID: widget.embryoscopeID,
          epicID: _textControllers['epicPatientID']!.text,
          firstName: _textControllers['firstName']!.text,
          lastName: _textControllers['lastName']!.text,
          dateOfBirth: DateFormat('MM/dd/yyyy')
              .parse(_textControllers['dateOfBirth']!.text),
          cycles: [
            PatientCycle(
                cycleNum: 1,
                embryos: _embryoList,
                numEmbryos: _numEmbryos,
                cycleStartDate: DateTime.now())
          ],
          totalNumCycles: 1,
          currentCycleNum: 1);

      bool submitSuccess = false;
      if (_isEditing) {
        debugPrint('updating patient instead of creating');
        submitSuccess =
            await PatientService.updatePatientCreation(newPatientData);
      } else {
        // if we're editing, we don't want to create a new patient (we're updating the existing one
        debugPrint('creating new patient');
        submitSuccess = await PatientService.createPatient(newPatientData);
      }
      if (submitSuccess) {
        if (!mounted) return;
        context.read<PatientModel>().patientData = newPatientData;
        Navigator.of(context)
            .pushNamed(PatientScreen.routeName,
                arguments: PatientScreenArgs(widget.embryoscopeID, false))
            .then((value) => setState(() {
                  // came back means we're editing and shouldn't create a new patient
                  _isEditing = true;
                  debugPrint(
                      'Editing Mode is now on since returned from patient screen');
                }));
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(getSnackBar(
            context,
            SnackBarType.error,
            "Something went wrong... Unable to ${_isEditing ? 'update' : 'create'} new patient."));
      }
    }
    setState(() {
      _submitting = false;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
        initialDate: DateTime.now());

    if (pickedDate != null) {
      _textControllers['dateOfBirth']!.text =
          DateFormat('MM/dd/yyyy').format(pickedDate);
    }
  }
}

class PatientInfoID extends StatelessWidget {
  const PatientInfoID({
    super.key,
    required this.embryoscopeID,
  });

  final String embryoscopeID;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      CircleAvatar(
          radius: 30,
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Icon(Icons.person,
              size: 48, color: Theme.of(context).colorScheme.onPrimary)),
      const SizedBox(width: 20),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text.rich(TextSpan(
            text: 'Embryoscope ID: ',
            style: Theme.of(context).textTheme.headlineLarge,
            children: [
              TextSpan(
                  text: embryoscopeID,
                  style: Theme.of(context).textTheme.headlineMedium)
            ])),
        Text('Cycle: 1', style: Theme.of(context).textTheme.headlineLarge)
      ])
    ]);
  }
}
