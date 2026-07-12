class ArchiveModel {
  final int id;
  final int caseId;
  final String? disclaimerImage;
  final bool printed;
  final DateTime? archivedAt;
  final String? patientName;
  final String? centerName;
  final String? triageCode;

  ArchiveModel({
    required this.id,
    required this.caseId,
    this.disclaimerImage,
    required this.printed,
    this.archivedAt,
    this.patientName,
    this.centerName,
    this.triageCode,
  });

  factory ArchiveModel.fromJson(Map<String, dynamic> json) {
    final emsCase = json['ems_case'] as Map<String, dynamic>?;
    final patient = emsCase?['patient'] as Map<String, dynamic>?;
    final center = emsCase?['center'] as Map<String, dynamic>?;

    return ArchiveModel(
      id: json['id'] as int,
      caseId: json['case_id'] as int,
      disclaimerImage: json['disclaimer_image'] as String?,
      printed: json['printed'] == true || json['printed'] == 1,
      archivedAt: json['archived_at'] != null ? DateTime.tryParse(json['archived_at'] as String) : null,
      patientName: patient?['full_name'] as String?,
      centerName: center?['name'] as String?,
      triageCode: emsCase?['triage_code'] as String?,
    );
  }
}
