import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../pdf_service.dart';

class BenefitsScreen extends StatefulWidget {
  const BenefitsScreen({super.key});

  @override
  State<BenefitsScreen> createState() => _BenefitsScreenState();
}

class _BenefitsScreenState extends State<BenefitsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _applicantNameController =
      TextEditingController();
  final TextEditingController _deceasedNameController = TextEditingController();
  final TextEditingController _pensionShareController = TextEditingController();

  String _kinship = 'ابنة';
  File? _marriageDocImage;

  @override
  void dispose() {
    _applicantNameController.dispose();
    _deceasedNameController.dispose();
    _pensionShareController.dispose();
    super.dispose();
  }

  Future<void> _pickMarriageContract(
    ImageSource source,
    StateSetter modalSetState,
  ) async {
    final picked = await _picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      modalSetState(() {
        _marriageDocImage = File(picked.path);
      });
    }
  }

  void _openNewMarriageGrantModal() {
    _marriageDocImage = null;
    _kinship = 'ابنة';
    _applicantNameController.clear();
    _deceasedNameController.clear();
    _pensionShareController.clear();

    final parentMessenger = ScaffoldMessenger.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
        bool isSubmitting = false;

        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom:
                    MediaQuery.of(bottomSheetContext).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: const [
                        CircleAvatar(
                          backgroundColor: Color(0xFFFCE7F3),
                          child: Icon(
                            Icons.female_rounded,
                            color: Color(0xFFBE185D),
                          ),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'تسجيل طلب منحة زواج (بنات)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE185D),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    TextField(
                      controller: _applicantNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم الفتاة المستفيدة (العروسة)',
                        prefixIcon: const Icon(
                          Icons.person,
                          color: Color(0xFFBE185D),
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            initialValue: _kinship,
                            decoration: InputDecoration(
                              labelText: 'صلة القرابة',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'ابنة',
                                child: Text('ابنة'),
                              ),
                              DropdownMenuItem(
                                value: 'أخت',
                                child: Text('أخت'),
                              ),
                            ],
                            onChanged: (val) {
                              if (val != null) {
                                modalSetState(() => _kinship = val);
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _pensionShareController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: 'النصيب الشهري (ر.ي)',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deceasedNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم المؤمن عليه المتوفى',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'صورة عقد القران الرسمي:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () => _pickMarriageContract(
                            ImageSource.camera,
                            modalSetState,
                          ),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('تصوير العقد'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () => _pickMarriageContract(
                            ImageSource.gallery,
                            modalSetState,
                          ),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('المعرض'),
                        ),
                      ],
                    ),
                    if (_marriageDocImage != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _marriageDocImage!,
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (_applicantNameController.text
                                        .trim()
                                        .isEmpty ||
                                    _marriageDocImage == null) {
                                  parentMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'يرجى إدخال الاسم وإرفاق عقد القران',
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                modalSetState(() => isSubmitting = true);

                                final double monthlyShare =
                                    double.tryParse(
                                      _pensionShareController.text.trim(),
                                    ) ??
                                    25000.0;
                                final double totalGrant = monthlyShare * 12;

                                try {
                                  await _firestore
                                      .collection('benefit_requests')
                                      .add({
                                        'beneficiary_name':
                                            _applicantNameController.text
                                                .trim(),
                                        'kinship':
                                            '$_kinship المستحق (${_deceasedNameController.text.trim()})',
                                        'type': 'منحة زواج (بنات)',
                                        'amount': totalGrant,
                                        'date': DateTime.now()
                                            .toIso8601String()
                                            .substring(0, 10),
                                        'status': 'PENDING',
                                        'doc_reference':
                                            'وثيقة عقد قران شرعي (مرفقة)',
                                        'image_path': _marriageDocImage!.path,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });

                                  if (bottomSheetContext.mounted) {
                                    Navigator.pop(bottomSheetContext);
                                  }

                                  parentMessenger.showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'تم قيد طلب المنحة بنجاح في السحابة',
                                      ),
                                      backgroundColor: Color(0xFFBE185D),
                                    ),
                                  );
                                } catch (e) {
                                  modalSetState(() => isSubmitting = false);
                                  parentMessenger.showSnackBar(
                                    SnackBar(content: Text('فشل الحفظ: $e')),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE185D),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check, color: Colors.white),
                        label: Text(
                          isSubmitting ? 'جاري الحفظ...' : 'حفظ الطلب',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showImagePreview(String path) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppBar(
              title: const Text(
                'معاينة عقد القران',
                style: TextStyle(fontSize: 16),
              ),
              backgroundColor: const Color(0xFFBE185D),
              elevation: 0,
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            Image.file(File(path), fit: BoxFit.contain),
          ],
        ),
      ),
    );
  }

  Future<void> _updateRequestStatus(
    String docId,
    Map<String, dynamic> item,
    String newStatus,
  ) async {
    final messenger = ScaffoldMessenger.of(context);

    try {
      await _firestore.collection('benefit_requests').doc(docId).update({
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (newStatus == 'APPROVED') {
        await _firestore.collection('journal_entries').add({
          'entry_no':
              'JV-2026-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}',
          'date': DateTime.now().toIso8601String().substring(0, 10),
          'description':
              'صرف منحة زواج بنات - المستفيدة ${item['beneficiary_name']}',
          'type': 'DEBIT',
          'amount': item['amount'],
          'account': 'صندوق التأمينات والمعاشات الرئيسي',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      messenger.showSnackBar(
        SnackBar(
          content: Text(
            newStatus == 'APPROVED'
                ? 'تم اعتماد الصرف وترحيل القيد آلياً إلى السحابة!'
                : 'تم رفض الطلب',
          ),
          backgroundColor: newStatus == 'APPROVED'
              ? const Color(0xFF16A34A)
              : Colors.red,
        ),
      );
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('تعذر تحديث الحالة: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'إدارة المنافع (منح زواج البنات)',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFFBE185D),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openNewMarriageGrantModal,
        backgroundColor: const Color(0xFFBE185D),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'تسجيل طلب',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _firestore
            .collection('benefit_requests')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('خطأ في الاتصال: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text('لا توجد طلبات حالياً'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final doc = docs[index];
              final item = doc.data();
              final docId = doc.id;

              final bool isPending = item['status'] == 'PENDING';
              final bool isApproved = item['status'] == 'APPROVED';

              return Card(
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['beneficiary_name'] ?? '',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isApproved
                                  ? Colors.green.withValues(alpha: 0.12)
                                  : isPending
                                  ? Colors.orange.withValues(alpha: 0.12)
                                  : Colors.red.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isApproved
                                  ? 'معتمد للصرف'
                                  : isPending
                                  ? 'قيد التدقيق'
                                  : 'مرفوض',
                              style: TextStyle(
                                color: isApproved
                                    ? Colors.green[800]
                                    : isPending
                                    ? Colors.orange[900]
                                    : Colors.red[800],
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'الصفة: ${item['kinship'] ?? ''}',
                        style: const TextStyle(
                          color: Color(0xFF475569),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['doc_reference'] ?? '',
                            style: const TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 12,
                            ),
                          ),
                          if (item['image_path'] != null)
                            TextButton.icon(
                              onPressed: () =>
                                  _showImagePreview(item['image_path']),
                              icon: const Icon(
                                Icons.remove_red_eye,
                                size: 16,
                                color: Color(0xFFBE185D),
                              ),
                              label: const Text(
                                'معاينة العقد',
                                style: TextStyle(color: Color(0xFFBE185D)),
                              ),
                            ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'مبلغ المنحة (معاش 12 شهراً):',
                            style: TextStyle(
                              color: Color(0xFF64748B),
                              fontSize: 13,
                            ),
                          ),
                          Text(
                            '${item['amount']} ر.ي',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFBE185D),
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      if (isPending) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () => _updateRequestStatus(
                                  docId,
                                  item,
                                  'APPROVED',
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF16A34A),
                                ),
                                icon: const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                label: const Text(
                                  'اعتماد وصرف',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: () => _updateRequestStatus(
                                  docId,
                                  item,
                                  'REJECTED',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.red,
                                  side: const BorderSide(color: Colors.red),
                                ),
                                icon: const Icon(Icons.close, size: 18),
                                label: const Text('رفض'),
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (isApproved) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              PdfService.printMarriageGrantDocument(
                                applicantName: item['beneficiary_name'] ?? '',
                                kinship: item['kinship'] ?? '',
                                grantAmount: (item['amount'] as num).toDouble(),
                                date: item['date'] ?? '2026-10-25',
                                refNo: 'DEC-2026-${docId.substring(0, 5)}',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(
                                color: Color(0xFF0F766E),
                                width: 1.5,
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            icon: const Icon(
                              Icons.print,
                              color: Color(0xFF0F766E),
                            ),
                            label: const Text(
                              'طباعة قرار وسند الصرف الرسمي (PDF)',
                              style: TextStyle(
                                color: Color(0xFF0F766E),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
