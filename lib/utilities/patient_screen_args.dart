class PatientScreenArgs {
  final String embryoscopeID;
  final bool clearPatientOnPop;

  PatientScreenArgs(this.embryoscopeID, [this.clearPatientOnPop = true]);
}
