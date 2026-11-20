import 'package:flutter/material.dart';

class InspectionScreen extends StatefulWidget {
  const InspectionScreen({super.key});

  @override
  State<InspectionScreen> createState() => _InspectionScreenState();
}

class _InspectionScreenState extends State<InspectionScreen> {
  // القائمة فارغة تماماً بدون سجلات تجريبية
  final List<Map<String, dynamic>> _inspectionReports = [];

  final _formKey = GlobalKey<FormState>();
  final _facilityController = TextEditingController();
  final _inspectorController = TextEditingController();
  final _unregisteredWorkersController = TextEditingController();
  final _fineController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isCompliant = true;

  @override
  void dispose() {
    _facilityController.dispose();
    _inspectorController.dispose();
    _unregisteredWorkersController.dispose();
    _fineController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _showAddReportDialog() {
    _facilityController.clear();
    _inspectorController.clear();
    _unregisteredWorkersController.text = '0';
    _fineController.text = '0';
    _notesController.clear();
    _isCompliant = true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'تحرير محضر تفتيش ميداني',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFD97706),
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _facilityController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المنشأة',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) => v == null || v.isEmpty
                        ? 'يرجى إدخال اسم المنشأة'
                        : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _inspectorController,
                    decoration: const InputDecoration(
                      labelText: 'اسم المفتش المسؤول',
                      border: OutlineInputBorder(),
                    ),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'يرجى إدخال اسم المفتش' : null,
                  ),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    title: const Text('حالة المنشأة: ملتزمة نظامياً'),
                    value: _isCompliant,
                    activeThumbColor: const Color(0xFFD97706),
                    onChanged: (val) {
                      setModalState(() {
                        _isCompliant = val;
                        if (_isCompliant) {
                          _unregisteredWorkersController.text = '0';
                          _fineController.text = '0';
                        }
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (!_isCompliant) ...[
                    TextFormField(
                      controller: _unregisteredWorkersController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'عدد العمالة غير المسجلة',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _fineController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'إجمالي الغرامة المقيدة (ر.ي)',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  TextFormField(
                    controller: _notesController,
                    decoration: const InputDecoration(
                      labelText: 'ملاحظات المحضر',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD97706),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        final now = DateTime.now();
                        setState(() {
                          _inspectionReports.insert(0, {
                            'facility': _facilityController.text.trim(),
                            'inspector': _inspectorController.text.trim(),
                            'date':
                                '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}',
                            'status': _isCompliant
                                ? 'منشأة ملتزمة'
                                : 'مخالفة مضبوطة',
                            'workers': _unregisteredWorkersController.text
                                .trim(),
                            'fine':
                                double.tryParse(_fineController.text.trim()) ??
                                0.0,
                            'notes': _notesController.text.trim().isEmpty
                                ? 'لا توجد ملاحظات'
                                : _notesController.text.trim(),
                          });
                        });
                        Navigator.pop(ctx);
                      }
                    },
                    child: const Text(
                      'اعتماد المحضر وحفظه',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'إدارة التفتيش والرقابة الميدانية',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        backgroundColor: const Color(0xFFD97706),
        centerTitle: true,
      ),
      body: _inspectionReports.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fact_check_outlined,
                    size: 70,
                    color: Colors.black26,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'لا توجد محاضر تفتيش مسجلة حالياً',
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _inspectionReports.length,
              itemBuilder: (context, index) {
                final r = _inspectionReports[index];
                final isFine = r['status'] == 'مخالفة مضبوطة';
                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              r['facility'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: isFine
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.green.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                r['status'],
                                style: TextStyle(
                                  color: isFine ? Colors.red : Colors.green,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'المفتش: ${r['inspector']}',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              r['date'],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'عمالة غير مسجلة: ${r['workers']} عامل',
                          style: TextStyle(
                            fontSize: 13,
                            color: isFine
                                ? Colors.red.shade800
                                : Colors.green.shade800,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (isFine) ...[
                          const SizedBox(height: 4),
                          Text(
                            'إجمالي الغرامة: ${r['fine']} ر.ي',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                        const SizedBox(height: 6),
                        Text(
                          'ملاحظات: ${r['notes']}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReportDialog,
        backgroundColor: const Color(0xFFD97706),
        icon: const Icon(Icons.add_task, color: Colors.white),
        label: const Text(
          'تحرير محضر +',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
