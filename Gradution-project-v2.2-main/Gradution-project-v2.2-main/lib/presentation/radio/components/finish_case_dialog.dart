import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class FinishCasePhoto {
  final Uint8List bytes;
  final String filename;

  const FinishCasePhoto({required this.bytes, required this.filename});
}

/// Collects the liability-waiver photo required before a case can be
/// archived. Returns null if the user cancels.
class FinishCaseDialog extends StatefulWidget {
  const FinishCaseDialog({super.key});

  @override
  State<FinishCaseDialog> createState() => _FinishCaseDialogState();
}

class _FinishCaseDialogState extends State<FinishCaseDialog> {
  FinishCasePhoto? _photo;
  bool _picking = false;

  Future<void> _pickPhoto() async {
    setState(() => _picking = true);
    try {
      final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() => _photo = FinishCasePhoto(bytes: bytes, filename: picked.name));
      }
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('إنهاء المهمة'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('يجب رفع صورة إخلاء المسؤولية قبل أرشفة الحالة.'),
          const SizedBox(height: 16),
          if (_photo != null)
            Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 18),
                const SizedBox(width: 6),
                Expanded(child: Text(_photo!.filename, overflow: TextOverflow.ellipsis)),
              ],
            ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _picking ? null : _pickPhoto,
            icon: _picking
                ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.upload_file),
            label: Text(_photo == null ? 'اختيار صورة' : 'تغيير الصورة'),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('إلغاء'),
        ),
        ElevatedButton(
          onPressed: _photo == null ? null : () => Navigator.of(context).pop(_photo),
          child: const Text('إنهاء وأرشفة'),
        ),
      ],
    );
  }
}
