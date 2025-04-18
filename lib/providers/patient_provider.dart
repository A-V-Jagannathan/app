import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/patient_data_model.dart';
import 'package:witnessing_data_app/services/patient_service.dart';

class PatientModel extends ChangeNotifier {
  ///
  /// PatientData Section
  ///
  PatientData? _patientData;
  PatientData? get patientData => _patientData;
  bool get hasPatientData => _patientData != null;
  set patientData(PatientData? patientData) {
    _patientData = patientData;
    notifyListeners();
  }

  ///
  /// All Section
  ///
  void clearPatientData({bool notify = true}) {
    _patientData = null;

    if (notify) notifyListeners();
  }

  Future<bool?> loadPatient(String patientID) async {
    // _patientData = PatientData(
    //     id: '3XEz4geirSvlKShLvCKg',
    //     numEmbryos: 6,
    //     embryos: List<EmbryoData>.generate(
    //         6,
    //         (index) => EmbryoData(
    //             id: '3XEz4geirSvlKShLvCKg', //|${index + 1}',
    //             embryoNumber: index + 1,
    //             date: DateTime.now())));
    // return true;

    _patientData = await PatientService.getPatient(patientID);
    // Returns null if the patient was not found
    return _patientData == null ? null : true;
  }
}
