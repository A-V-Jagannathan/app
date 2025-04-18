import 'package:flutter/material.dart';
import 'package:witnessing_data_app/models/firebase/embryo_model.dart';

class EmbryoModel extends ChangeNotifier {
  ///
  /// EmbryoData Section
  ///
  EmbryoData? _selectedEmbryo;
  EmbryoData? get selectedEmbryo => _selectedEmbryo;

  int? _selectedEmbryoIndex;
  int? get selectedEmbryoIndex => _selectedEmbryoIndex;

  bool get hasSelectedEmbryo =>
      _selectedEmbryo != null && _selectedEmbryoIndex != null;

  void setSelectedEmbryo(EmbryoData embryo, int index) {
    _selectedEmbryo = embryo;
    _selectedEmbryoIndex = index;
    notifyListeners();
  }

  void clearSelectedEmbryo({bool notify = true}) {
    _selectedEmbryo = null;
    _selectedEmbryoIndex = null;

    if (notify) notifyListeners();
  }

  // Future<bool?> selectEmbryo(String embryoID) async {
  //   if (_patientData == null || _patientData!.embryos == null) return null;

  //   _selectedEmbryoIndex =
  //       _patientData!.embryos!.indexWhere((element) => element.id == embryoID);

  //   if (_selectedEmbryoIndex == null || _selectedEmbryoIndex == -1) {
  //     _selectedEmbryoIndex = null;
  //     _selectedEmbryo = null;
  //     return null;
  //   }

  //   _selectedEmbryo = _patientData!.embryos![_selectedEmbryoIndex!];
  //   return true;
  // }
}
