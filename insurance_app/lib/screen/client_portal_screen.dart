import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ClientPortalScreen extends StatefulWidget {
  final String userName;
  final String insuranceNo;

  const ClientPortalScreen({
    super.key,
    required this.userName,
    required this.insuranceNo,
  });

  @override
  State<ClientPortalScreen> createState() => _ClientPortalScreenState();
}

class _ClientPortalScreenState extends State<ClientPortalScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ImagePicker _picker = ImagePicker();
  File? _marriageContract;
  bool _isUploading = false;

  final TextEditingController _deceasedNameController = TextEditingController();
  final TextEditingController _monthlyShareController = TextEditingController();
  String _kinship = 'ابنة';

  @override
  void dispose() {
    _deceasedNameController.dispose();
    _monthlyShareController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, StateSetter modalSetState) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      final picked = await _picker.pickImage(source: source, imageQuality: 75);
      if (picked != null) {
        modalSetState(() {
          _marriageContract = File(picked.path);
        });
      }
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(SnackBar(content: Text('تعذر اختيار الصورة: $e')));
    }
  }

  Future<void> _submitMarriageGrant(
    BuildContext modalContext,
    StateSetter modalSetState,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(modalContext);

    if (_deceasedNameController.text.trim().isEmpty ||
        _marriageContract == null) {
      messenger.showSnackBar(
        const SnackBar(
          content: Text('يرجى ملء كافة البيانات وإرفاق صورة العقد'),
        ),
      );
      return;
    }

    modalSetState(() => _isUploading = true);

    final double monthlyShare =
        double.tryParse(_monthlyShareController.text.trim()) ?? 25000.0;
    final double totalGrant = monthlyShare * 12;

    try {
      await _firestore.collection('benefit_requests').add({
        'beneficiary_name': widget.userName,
        'insurance_no': widget.insuranceNo,
        'kinship': '$_kinship المستحق (${_deceasedNameController.text.trim()})',
        'type': 'منحة زواج (بنات)',
        'amount': totalGrant,
        'date': DateTime.now().toIso8601String().substring(0, 10),
        'status': 'PENDING',
        'doc_reference': 'عقد قران مرفق عبر البوابة',
        'image_path': _marriageContract!.path,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      modalSetState(() => _isUploading = false);
      navigator.pop();

      messenger.showSnackBar(
        const SnackBar(
          content: Text(
            'تم رفع طلب المنحة ووثيقة العقد بنجاح ووصلت لإدارة المنافع!',
          ),
          backgroundColor: Color(0xFFBE185D),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      modalSetState(() => _isUploading = false);
      messenger.showSnackBar(SnackBar(content: Text('تعذر إرسال الطلب: $e')));
    }
  }

  void _openMarriageGrantModal() {
    _marriageContract = null;
    _deceasedNameController.clear();
    _monthlyShareController.clear();
    _isUploading = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (bottomSheetContext) {
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
                          child: Icon(Icons.favorite, color: Color(0xFFBE185D)),
                        ),
                        SizedBox(width: 10),
                        Text(
                          'تقديم طلب منحة زواج (إناث)',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFBE185D),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'تصرف منحة الزواج للابنة أو الأخت المستحقة لمعاش والدها بمقدار نصيب 12 شهراً.',
                      style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                    ),
                    const Divider(height: 20),
                    DropdownButtonFormField<String>(
                      initialValue: _kinship,
                      decoration: InputDecoration(
                        labelText: 'صفة القرابة بالمؤمن عليه المتوفى',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'ابنة',
                          child: Text('ابنة المستحق'),
                        ),
                        DropdownMenuItem(
                          value: 'أخت',
                          child: Text('أخت المستحق'),
                        ),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          modalSetState(() => _kinship = val);
                        }
                      },
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _deceasedNameController,
                      decoration: InputDecoration(
                        labelText: 'اسم صاحب المعاش المتوفى (الوالد/الأخ)',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _monthlyShareController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'النصيب الشهري المعتاد من المعاش (ر.ي)',
                        prefixIcon: const Icon(Icons.payments_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'صورة عقد القران الرسمي الموثق (إلزامي):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFF475569),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.camera, modalSetState),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('الكاميرا'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickImage(ImageSource.gallery, modalSetState),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('المعرض'),
                        ),
                      ],
                    ),
                    if (_marriageContract != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _marriageContract!,
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
                        onPressed: _isUploading
                            ? null
                            : () => _submitMarriageGrant(
                                bottomSheetContext,
                                modalSetState,
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFBE185D),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        icon: _isUploading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.cloud_upload_outlined,
                                color: Colors.white,
                              ),
                        label: Text(
                          _isUploading
                              ? 'جاري الحفظ والرفع...'
                              : 'إرسال الطلب إلى المؤسسة',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'بوابة المستفيدين',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF0F766E),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'تسجيل خروج',
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF134E4A)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        widget.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.greenAccent.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'حساب نشط',
                          style: TextStyle(
                            color: Colors.greenAccent,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'الرقم التأميني: ${widget.insuranceNo}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'الفرع المعتمد: فرع المركز الرئيسي',
                    style: TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'الخدمات والمعاملات التأمينية',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            _buildServiceItem(
              icon: Icons.favorite,
              color: const Color(0xFFBE185D),
              title: 'التقديم على منحة زواج (خاص بالبنات)',
              subtitle: 'رفع طلب إلكتروني مرفق به صورة عقد القران الشرعي',
              onTap: _openMarriageGrantModal,
            ),
            _buildServiceItem(
              icon: Icons.receipt_long,
              color: const Color(0xFF0284C7),
              title: 'سجل الاشتراكات ومدد الخدمة',
              subtitle: 'استعراض الاشتراكات المسددة وفترات العمل المسجلة',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('كشف الحساب التأميني'),
                    content: const Text(
                      'إجمالي المدد المسجلة: 54 شهراً\nالاشتراكات مسددة بانتظام حتى تاريخه.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              },
            ),
            _buildServiceItem(
              icon: Icons.card_membership,
              color: const Color(0xFF16A34A),
              title: 'البطاقة التأمينية الإلكترونية',
              subtitle: 'استخراج وعرض البطاقة المعتمدة مع الباركود التعريفي',
              onTap: () {
                showDialog(
                  context: context,
                  builder: (dialogCtx) => AlertDialog(
                    title: const Text('البطاقة التأمينية الرقمية'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.qr_code_2,
                          size: 100,
                          color: Color(0xFF0F766E),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          widget.userName,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text('رقم التأمين: ${widget.insuranceNo}'),
                      ],
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(dialogCtx),
                        child: const Text('إغلاق'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceItem({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor: color.withValues(alpha: 0.12),
          child: Icon(icon, color: color),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
        ),
        trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
        onTap: onTap,
      ),
    );
  }
}
