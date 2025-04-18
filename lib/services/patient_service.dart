import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/embryo_model.dart';
import 'package:witnessing_data_app/models/firebase/patient_cycle_model.dart';
import 'package:witnessing_data_app/models/firebase/patient_data_model.dart';

import 'package:witnessing_data_app/services/firebase_service.dart';

class PatientService {
  PatientService._();

  static final _patientController = WitnessingDatabase.instance
      .collection(WitnessingDatabase.collections.patients)
      .withConverter<PatientData?>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            // ensure firebaseID is set on the actual object
            data?['embryoscopeID'] = snapshot.id;

            return data == null ? null : PatientData.fromJson(data);
          },
          toFirestore: (patient, _) => patient!.toJson());

  static CollectionReference<PatientCycle?> _cycleController(
      String emrbyoscopeID) {
    return _patientController
        .doc(emrbyoscopeID)
        .collection('cycles')
        .withConverter<PatientCycle?>(
          fromFirestore: (snapshot, _) {
            final Map<String, dynamic>? data = snapshot.data();
            // ensure firebaseID is set on the actual object
            data?['cycle_num'] = int.parse(snapshot.id);

            return data == null ? null : PatientCycle.fromJson(data);
          },
          toFirestore: (cycle, _) => cycle!.toJson(),
        );
  }

  static CollectionReference<EmbryoData?> _embryoController(
      String embryoscopeID, int cycleNum) {
    return _patientController
        .doc(embryoscopeID)
        .collection('cycles')
        .doc(cycleNum.toString())
        .collection('embryos')
        .withConverter<EmbryoData?>(
          fromFirestore: (snapshot, _) {
            final data = snapshot.data();
            // ensure firebaseID is set on the actual object
            data?['id'] = snapshot.id;

            return data == null ? null : EmbryoData.fromJson(data);
          },
          toFirestore: (embryo, _) => embryo!.toJson(),
        );
  }

  ///
  ///
  /// CREATE Section
  ///
  ///
  static Future<bool> createPatient(PatientData patient) async {
    try {
      return WitnessingDatabase.instance
          .runTransaction((transaction) async {
            // create the actual patient
            await _patientController.doc(patient.embryoscopeID).set(patient);

            // // Create cycles for the patient
            for (final PatientCycle cycle in patient.cycles ?? []) {
              await _cycleController(patient.embryoscopeID)
                  .doc(cycle.cycleNum.toString())
                  .set(cycle);

              for (final EmbryoData? embryo in cycle.embryos ?? []) {
                if (embryo == null) continue;

                await _embryoController(patient.embryoscopeID, cycle.cycleNum)
                    .doc(embryo.id)
                    .set(embryo);
              }
            }
          })
          .then((value) => true)
          .onError((error, stackTrace) {
            debugPrint('Error creating patient: $error');
            return false;
          });
    } catch (e) {
      debugPrint('Error creating patient: $e');
      return false;
    }
  }

  static Future<bool> addNewCycle(
      PatientData patient, PatientCycle newCycle) async {
    try {
      return WitnessingDatabase.instance
          .runTransaction((transaction) async {
            // set the end date of the current cycle
            await _cycleController(patient.embryoscopeID)
                .doc((patient.currentCycleNum - 1).toString())
                .update({'cycle_end_date': DateTime.now()});

            await _patientController
                .doc(patient.embryoscopeID)
                .set(patient, SetOptions(merge: true));

            // add the new cycle to the database
            if (patient.cycles == null) {
              patient.cycles = [newCycle];
            } else {
              patient.cycles!.add(newCycle);
            }

            await _cycleController(patient.embryoscopeID)
                .doc(newCycle.cycleNum.toString())
                .set(newCycle);

            // add the embryos in the cycle to the database
            newCycle.embryos ??= List.generate(
                newCycle.numEmbryos,
                (index) => EmbryoData(
                    id: 'embryo_${patient.embryoscopeID}_${index + 1}',
                    embryoNumber: index + 1));

            await Future.wait(newCycle.embryos!.map((newEmbryo) =>
                _embryoController(patient.embryoscopeID, newCycle.cycleNum)
                    .doc(newEmbryo.id)
                    .set(newEmbryo)));
          })
          .then((value) => true)
          .onError((error, stackTrace) {
            debugPrint('Error adding cycle: $error');
            return false;
          });
    } catch (e) {
      debugPrint('Error adding cycle: $e');
      return false;
    }
  }

  ///
  ///
  /// READ Section
  ///
  ///
  static Future<PatientData?> getPatient(String embryoscopeID) async {
    try {
      final patientDoc = await _patientController.doc(embryoscopeID).get();

      if (!patientDoc.exists) {
        debugPrint("Patient with id '$embryoscopeID' does not exist.");
        return null;
      }

      final PatientData basePatient = patientDoc.data()!;

      final activeCycle = await _cycleController(embryoscopeID)
          .doc(basePatient.currentCycleNum.toString())
          .get();
      if (!activeCycle.exists) {
        return null;
      }
      final activeCycleData = activeCycle.data()!;

      final embryoRefs =
          await _embryoController(embryoscopeID, activeCycleData.cycleNum)
              .get();
      activeCycleData.embryos = embryoRefs.docs.isNotEmpty
          ? embryoRefs.docs.map((e) => e.data()!).toList()
          : [];

      basePatient.cycles = [activeCycleData];

      return basePatient;
    } catch (e) {
      debugPrint('Error getting patient: $e');
      return null;
    }
  }

  // static Future<PatientData?> getPatientWithAllEmbryos(String patientID) async {
  //   try {
  //     final patientDoc = await _patientController.doc(patientID).get();

  //     if (!patientDoc.exists) {
  //       debugPrint("Patient with id '$patientID' does not exist.");
  //       return null;
  //     }

  //     final patientData = patientDoc.data()!;
  //     final embryos =
  //         await _embryoController(patientID).orderBy('embryo_number').get();

  //     patientData.embryos = embryos.docs.isNotEmpty
  //         ? embryos.docs.map((e) => e.data()!).toList()
  //         : [];

  //     return patientData;
  //   } catch (e) {
  //     debugPrint('Error getting patient with embryos: $e');
  //     return null;
  //   }
  // }

  // static Future<PatientData?> getPatientWithEmbryoById(
  //     String patientID, String embryoID) async {
  //   try {
  //     final patientDoc = await _patientController.doc(patientID).get();

  //     if (!patientDoc.exists) {
  //       debugPrint("Patient with id '$patientID' does not exist.");
  //       return null;
  //     }

  //     final patientData = patientDoc.data()!;
  //     final embryoDoc = await _embryoController(patientID).doc(embryoID).get();

  //     if (!embryoDoc.exists) {
  //       debugPrint("Embryo with id '$embryoID' does not exist.");
  //       return null;
  //     }

  //     patientData.embryos = [embryoDoc.data()!];
  //     return patientData;
  //   } catch (e) {
  //     debugPrint('Error getting patient with embryo by ID: $e');
  //     return null;
  //   }
  // }

  ///
  ///
  /// UPDATE Section
  ///
  ///

  static Future<bool> updateNewCycle(
      PatientData patient, PatientCycle updateCycle) async {
    try {
      return WitnessingDatabase.instance.runTransaction((transaction) async {
        await _cycleController(patient.embryoscopeID)
            .doc(updateCycle.cycleNum.toString())
            .set(updateCycle, SetOptions(merge: true));

        // Delete old embryos and replace with new set
        final oldEmbryos =
            await _embryoController(patient.embryoscopeID, updateCycle.cycleNum)
                .get();

        await Future.wait(
            oldEmbryos.docs.map((embryoRef) => embryoRef.reference.delete()));

        if (updateCycle.embryos == null) return true;
        await Future.wait(updateCycle.embryos!.map((newEmbryo) =>
            _embryoController(patient.embryoscopeID, updateCycle.cycleNum)
                .doc(newEmbryo.id)
                .set(newEmbryo)));

        return true;
      });
    } catch (e) {
      debugPrint('Error updating new cycle: $e');
      return false;
    }
  }

  static Future<bool> updatePatientCreation(PatientData newData) async {
    try {
      return WitnessingDatabase.instance
          .runTransaction((transaction) async {
            // create the actual patient
            await _patientController
                .doc(newData.embryoscopeID)
                .set(newData, SetOptions(merge: true));

            // Create embryos for the newData
            final databaseCycles =
                await _cycleController(newData.embryoscopeID).get();

            try {
              debugPrint(
                  'Deleting existing cycles + embryos for patient ${newData.embryoscopeID}');
              await Future.wait(databaseCycles.docs.map((cycleRef) async {
                final embryos = await _embryoController(
                        newData.embryoscopeID, int.parse(cycleRef.id))
                    .get();
                await Future.wait(embryos.docs
                    .map((embryoRef) => embryoRef.reference.delete()));
                await cycleRef.reference.delete();
              }), eagerError: true);
            } catch (e) {
              debugPrint('Error deleting embryos: $e');
              return false;
            }

            // Create cycles and embryos for the patients
            await Future.wait(newData.cycles!.map((newCycle) async {
              await _cycleController(newData.embryoscopeID)
                  .doc(newCycle.cycleNum.toString())
                  .set(newCycle);

              if (newCycle.embryos == null) return;
              await Future.wait(newCycle.embryos!.map((newEmbryo) =>
                  _embryoController(newData.embryoscopeID, newCycle.cycleNum)
                      .doc(newEmbryo!.id)
                      .set(newEmbryo)));
            }));
          })
          .then((value) => true)
          .onError((error, stackTrace) {
            debugPrint('Error creating patient: $error');
            return false;
          });
    } catch (e) {
      debugPrint('Error updating patient: $e');
      return false;
    }
  }

  ///
  ///
  /// DELETE Section
  ///
  ///
  static Future<bool> deletePatient(String patientId) async {
    // TODO: Implement this method
    return false;
  }
}
