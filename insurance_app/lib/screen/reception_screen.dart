import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../data/insurance_repository.dart';

class ReceptionScreen extends StatefulWidget {
  const ReceptionScreen({super.key});

  @override
  State<ReceptionScreen> createState() => _ReceptionScreenState();
}

class _ReceptionScreenState extends State<ReceptionScreen> {
  final repository = InsuranceRepository();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _nidController = TextEditingController();
  final TextEditingController _salaryController = TextEditingController();

  File? _idCardImage;
  final ImagePicker _picker = ImagePicker();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _nameController.dispose();
    _nidController.dispose();
    _salaryController.dispose();
    super.dispose();
  }

  Future<void> _pickIdImage(
    ImageSource source,
    StateSetter modalSetState,
  ) async {
    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 75,
    );
    if (pickedFile != null) {
      modalSetState(() {
        _idCardImage = File(pickedFile.path);
      });
    }
  }

  void _openRegisterDialog() {
    _idCardImage = null;
    _nameController.clear();
    _nidController.clear();
    _salaryController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, modalSetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'تسجيل مؤمن عليه جديد بالبطاقة',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0284C7),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'الاسم الرباعي',
                        prefixIcon: const Icon(Icons.person),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _nidController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الرقم الوطني / الهوية',
                        prefixIcon: const Icon(Icons.badge),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _salaryController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'الراتب الأساسي (ر.ي)',
                        prefixIcon: const Icon(Icons.money),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'صورة البطاقة الشخصية:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickIdImage(ImageSource.camera, modalSetState),
                          icon: const Icon(Icons.camera_alt),
                          label: const Text('الكاميرا'),
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: () =>
                              _pickIdImage(ImageSource.gallery, modalSetState),
                          icon: const Icon(Icons.photo_library),
                          label: const Text('المعرض'),
                        ),
                      ],
                    ),
                    if (_idCardImage != null) ...[
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.file(
                          _idCardImage!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ],
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_nameController.text.trim().isEmpty ||
                              _nidController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('يرجى ملء الحقول الأساسية'),
                              ),
                            );
                            return;
                          }

                          setState(() {
                            repository.addInsuredMember({
                              'insurance_no':
                                  'INS-2026-${8911 + repository.insuredMembers.length}',
                              'full_name': _nameController.text.trim(),
                              'national_id': _nidController.text.trim(),
                              'employer': 'شركة محلية معتمدة',
                              'status': 'نشط',
                              'basic_salary':
                                  double.tryParse(
                                    _salaryController.text.trim(),
                                  ) ??
                                  100000.0,
                              'id_image_path': _idCardImage?.path,
                            });
                          });

                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم إصدار الرقم التأميني وحفظ البيانات في النظام',
                              ),
                              backgroundColor: Color(0xFF0284C7),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0284C7),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        icon: const Icon(Icons.save, color: Colors.white),
                        label: const Text(
                          'حفظ وإصدار الرقم التأميني',
                          style: TextStyle(
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
    final filteredList = repository.insuredMembers.where((m) {
      return m['full_name'].toString().contains(_searchQuery) ||
          m['national_id'].toString().contains(_searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'إدارة الاستقبال والتسجيل',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        backgroundColor: const Color(0xFF0284C7),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openRegisterDialog,
        backgroundColor: const Color(0xFF0284C7),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'تسجيل مشترك',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث بالاسم أو الرقم الوطني...',
                prefixIcon: const Icon(Icons.search, color: Color(0xFF0284C7)),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              onChanged: (val) => setState(() => _searchQuery = val.trim()),
            ),
            const SizedBox(height: 18),
            Expanded(
              child: filteredList.isEmpty
                  ? const Center(child: Text('لا توجد سجلات مطابقة للبحث'))
                  : ListView.builder(
                      itemCount: filteredList.length,
                      itemBuilder: (context, index) {
                        final m = filteredList[index];
                        return Card(
                          elevation: 2,
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      m['full_name'] ?? '',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.green.withValues(alpha: 0.12),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        m['status'] ?? 'نشط',
                                        style: TextStyle(
                                          color: Colors.green[800],
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(height: 18),
                                Text(
                                  'رقم التأمين: ${m['insurance_no']}',
                                  style: const TextStyle(
                                    color: Color(0xFF0284C7),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الرقم الوطني: ${m['national_id']}',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'الراتب: ${m['basic_salary']} ر.ي',
                                  style: const TextStyle(
                                    color: Color(0xFF64748B),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
