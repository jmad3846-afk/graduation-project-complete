// lib/presentation/reports/components/reports_page_body.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'caller_info_card.dart';
import 'patient_info_card.dart';
import 'medical_info_card.dart';
import 'location_info_card.dart';
import 'report_header.dart';
import 'staff_info_card.dart';
import 'package:ems_op_room/core/providers/case_provider.dart';

class ReportsBody extends ConsumerStatefulWidget {
  const ReportsBody({super.key});

  @override
  ConsumerState<ReportsBody> createState() => _ReportsBodyState();
}

class _ReportsBodyState extends ConsumerState<ReportsBody> {
  // Required Controllers
  final _callerNameController = TextEditingController();
  final _relationController = TextEditingController();
  final _relationNumberController = TextEditingController();
  final _reportTimeController = TextEditingController();
  final _reportDateController = TextEditingController();

  // Patient Controllers
  final _patientNameController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _medicalHistoryController = TextEditingController();

  // Medical Controllers
  final _oxygenLevelController = TextEditingController();
  final _bloodPressureController = TextEditingController();
  final _bloodSugarController = TextEditingController();
  final _oxygenSupportLevelController = TextEditingController();
  final _oxygenAfterSupportController = TextEditingController();
  final _intubatedNotifier = ValueNotifier<bool>(false);
  final _consciousNotifier = ValueNotifier<bool>(false);

  // Location Controllers
  final _locationController = TextEditingController();
  final _supervisingDoctorController = TextEditingController();
  final _doctorPhoneController = TextEditingController();
  final _goingToController = TextEditingController();
  final _receivingDoctorController = TextEditingController();
  final _hospitalPhoneController = TextEditingController();

  @override
  void dispose() {
    // Dispose all controllers and notifiers
    _callerNameController.dispose();
    _relationController.dispose();
    _relationNumberController.dispose();
    _reportTimeController.dispose();
    _reportDateController.dispose();
    _patientNameController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _medicalHistoryController.dispose();
    _oxygenLevelController.dispose();
    _bloodPressureController.dispose();
    _bloodSugarController.dispose();
    _oxygenSupportLevelController.dispose();
    _oxygenAfterSupportController.dispose();
    _intubatedNotifier.dispose();
    _consciousNotifier.dispose();
    _locationController.dispose();
    _supervisingDoctorController.dispose();
    _doctorPhoneController.dispose();
    _goingToController.dispose();
    _receivingDoctorController.dispose();
    _hospitalPhoneController.dispose();
    super.dispose();
  }

  Map<String, dynamic> _buildPayload() {
    // Helper to convert empty strings to null
String? nullIfEmpty(String text) => text.isEmpty ? null : text;
    return {
      // Required fields
      'caller_name': _callerNameController.text,
      'relation': _relationController.text,
      'caller_phone': _relationNumberController.text,
      'report_time': _reportTimeController.text,
      'report_date': _reportDateController.text,
      // Optional patient fields
      'patient_name': nullIfEmpty(_patientNameController.text),
      'age': nullIfEmpty(_ageController.text),
      'weight': nullIfEmpty(_weightController.text),
      'medical_history': nullIfEmpty(_medicalHistoryController.text),
      // Optional medical fields
      'oxygen_level': nullIfEmpty(_oxygenLevelController.text),
      'blood_pressure': nullIfEmpty(_bloodPressureController.text),
      'blood_sugar': nullIfEmpty(_bloodSugarController.text),
      'oxygen_support_level': nullIfEmpty(_oxygenSupportLevelController.text),
      'oxygen_level_after': nullIfEmpty(_oxygenAfterSupportController.text),
      'is_intubated': _intubatedNotifier.value,
      'is_conscious': _consciousNotifier.value,
      // Optional location fields
      'location': nullIfEmpty(_locationController.text),
      'supervising_doctor': nullIfEmpty(_supervisingDoctorController.text),
      'doctor_phone': nullIfEmpty(_doctorPhoneController.text),
      'going_to': nullIfEmpty(_goingToController.text),
      'receiving_doctor': nullIfEmpty(_receivingDoctorController.text),
      'hospital_phone': nullIfEmpty(_hospitalPhoneController.text),
    };
  }

  void _submit() async {
    // Client‑side validation for required fields
    if (_callerNameController.text.isEmpty ||
        _relationController.text.isEmpty ||
        _relationNumberController.text.isEmpty ||
        _reportTimeController.text.isEmpty ||
        _reportDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }
    final payload = _buildPayload();
    debugPrint('Submitting payload: $payload');
    await ref.read(caseProvider.notifier).submitCase(payload: payload);
    if (!mounted) return;
    final state = ref.read(caseProvider);
    if (state.successMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.successMessage!)));
      // Clear form
      _clearAll();
    } else if (state.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
    }
  }

  void _clearAll() {
    _callerNameController.clear();
    _relationController.clear();
    _relationNumberController.clear();
    _reportTimeController.clear();
    _reportDateController.clear();
    _patientNameController.clear();
    _ageController.clear();
    _weightController.clear();
    _medicalHistoryController.clear();
    _oxygenLevelController.clear();
    _bloodPressureController.clear();
    _bloodSugarController.clear();
    _oxygenSupportLevelController.clear();
    _oxygenAfterSupportController.clear();
    _intubatedNotifier.value = false;
    _consciousNotifier.value = false;
    _locationController.clear();
    _supervisingDoctorController.clear();
    _doctorPhoneController.clear();
    _goingToController.clear();
    _receivingDoctorController.clear();
    _hospitalPhoneController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = isDark ? Colors.white : Colors.black87;
    final secondary = isDark ? Colors.white70 : Colors.grey[600]!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const ReportHeader(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 4))],
            ),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CallerInfoCard(
                        primary: primary,
                        secondary: secondary,
                        callerNameController: _callerNameController,
                        relationController: _relationController,
                        relationNumberController: _relationNumberController,
                        reportTimeController: _reportTimeController,
                        reportDateController: _reportDateController,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: PatientInfoCard(
                        primary: primary,
                        secondary: secondary,
                        patientNameController: _patientNameController,
                        ageController: _ageController,
                        weightController: _weightController,
                        medicalHistoryController: _medicalHistoryController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: MedicalInfoCard(
                        primary: primary,
                        secondary: secondary,
                        oxygenLevelController: _oxygenLevelController,
                        bloodPressureController: _bloodPressureController,
                        bloodSugarController: _bloodSugarController,
                        oxygenSupportLevelController: _oxygenSupportLevelController,
                        oxygenAfterSupportController: _oxygenAfterSupportController,
                        intubatedNotifier: _intubatedNotifier,
                        consciousNotifier: _consciousNotifier,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      flex: 2,
                      child: LocationInfoCard(
                        primary: primary,
                        secondary: secondary,
                        locationController: _locationController,
                        supervisingDoctorController: _supervisingDoctorController,
                        doctorPhoneController: _doctorPhoneController,
                        goingToController: _goingToController,
                        receivingDoctorController: _receivingDoctorController,
                        hospitalPhoneController: _hospitalPhoneController,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                StaffInfoCard(primary, secondary),
                const SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: _submit,
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
