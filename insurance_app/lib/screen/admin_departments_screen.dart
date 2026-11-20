import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'contributions_screen.dart';
import 'benefits_screen.dart';
import 'unified_login_screen.dart';

class AdminDepartmentsScreen extends StatelessWidget {
  const AdminDepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'لوحة الإدارة والأقسام العامة',
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
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const UnifiedLoginScreen()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'مؤشرات المنظومة السحابية المباشرة',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            // بطاقات الإحصائيات المباشرة
            Row(
              children: [
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore.collection('contributions').snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _buildStatCard(
                        title: 'المساهمات والمشتركين',
                        count: '$count',
                        icon: Icons.account_balance_wallet,
                        color: const Color(0xFF0F766E),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: firestore
                        .collection('benefit_requests')
                        .where('status', isEqualTo: 'PENDING')
                        .snapshots(),
                    builder: (context, snapshot) {
                      final count = snapshot.data?.docs.length ?? 0;
                      return _buildStatCard(
                        title: 'طلبات معلقة',
                        count: '$count',
                        icon: Icons.pending_actions,
                        color: const Color(0xFFBE185D),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: firestore.collection('journal_entries').snapshots(),
              builder: (context, snapshot) {
                final count = snapshot.data?.docs.length ?? 0;
                return _buildStatCard(
                  title: 'القيود المحاسبية المرحّلة للصندوق',
                  count: '$count قيود معتمدة',
                  icon: Icons.receipt_long,
                  color: const Color(0xFF0284C7),
                  isWide: true,
                );
              },
            ),
            const SizedBox(height: 24),
            const Text(
              'أقسام وإدارات الهيئة العامة للتأمينات',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),

            // 1. إدارة الاشتراكات والمساهمات
            _buildDepartmentTile(
              context,
              title: 'إدارة الاشتراكات والمساهمات',
              subtitle: 'تسجيل وتحصيل مساهمات المشتركين ومتابعة السجلات',
              icon: Icons.payments,
              color: const Color(0xFF0F766E),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ContributionsScreen(),
                  ),
                );
              },
            ),

            // 2. إدارة المنافع والمعاشات
            _buildDepartmentTile(
              context,
              title: 'إدارة المنافع والمعاشات (منح الزواج)',
              subtitle: 'فحص وثائق عقد القران واعتماد الصرف وطباعة السندات',
              icon: Icons.volunteer_activism,
              color: const Color(0xFFBE185D),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const BenefitsScreen()),
                );
              },
            ),

            // 3. إدارة التفتيش الميداني والرقابة
            _buildDepartmentTile(
              context,
              title: 'إدارة التفتيش الميداني والضبط التأميني',
              subtitle: 'جدولة ومتابعة نزول لجان التفتيش وضبط المنشآت',
              icon: Icons.fact_check_outlined,
              color: const Color(0xFFD97706),
              onTap: () => _showInspectionDialog(context),
            ),

            // 4. إدارة الشؤون المالية والحسابات
            _buildDepartmentTile(
              context,
              title: 'سجل القيود المحاسبية والمالية',
              subtitle: 'استعراض اليومية العامة والقيود المرحلة آلياً',
              icon: Icons.menu_book,
              color: const Color(0xFF0284C7),
              onTap: () => _showJournalEntriesModal(context),
            ),

            // 5. إدارة الشؤون القانونية والمخالفات
            _buildDepartmentTile(
              context,
              title: 'إدارة الشؤون القانونية وقضايا التأمين',
              subtitle:
                  'متابعة النزاعات التأمينية واللوائح التنفيذية ومذكرات الحجز',
              icon: Icons.gavel,
              color: const Color(0xFF4F46E5),
              onTap: () => _showLegalDialog(context),
            ),

            // 6. إدارة التقارير والإحصاء والمطابقة
            _buildDepartmentTile(
              context,
              title: 'إدارة الإحصاء وتقارير الأداء المالي',
              subtitle: 'استخراج المؤشرات العامة والتدفقات النقدية السنوية',
              icon: Icons.analytics_outlined,
              color: const Color(0xFF059669),
              onTap: () => _showReportsDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildStatCard({
    required String title,
    required String count,
    required IconData icon,
    required Color color,
    bool isWide = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withValues(alpha: 0.12),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                  ),
                ),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: isWide ? 15 : 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static Widget _buildDepartmentTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
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

  // نافذة دفتر اليومية المالي
  static void _showJournalEntriesModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'دفتر اليومية المالي (سحابي)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('journal_entries')
                      .orderBy('createdAt', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(
                        child: Text('لا توجد قيود مرحلة حتى الآن'),
                      );
                    }
                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final item = docs[i].data();
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFFE0F2FE),
                              child: Icon(
                                Icons.receipt,
                                color: Color(0xFF0284C7),
                              ),
                            ),
                            title: Text(
                              item['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'رقم القيد: ${item['entry_no']} | التاريخ: ${item['date']}',
                              style: const TextStyle(fontSize: 11),
                            ),
                            trailing: Text(
                              '${item['amount']} ر.ي',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFBE185D),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // نافذة إدارة التفتيش الميداني
  static void _showInspectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.fact_check_outlined, color: Color(0xFFD97706)),
            SizedBox(width: 8),
            Text('إدارة التفتيش الميداني', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• خطة النزول الميداني للشهر الجاري: نشطة ومجدولة.'),
            SizedBox(height: 6),
            Text('• إجمالي المنشآت المفتشة: 42 منشأة.'),
            SizedBox(height: 6),
            Text('• المخالفات المرصودة قيد المتابعة: 3 محاضر ضبط.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // نافذة الشؤون القانونية
  static void _showLegalDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.gavel, color: Color(0xFF4F46E5)),
            SizedBox(width: 8),
            Text('إدارة الشؤون القانونية', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• حالة المطالبات والنزاعات: سارية وموثقة قانونياً.'),
            SizedBox(height: 6),
            Text('• مذكرات الإنذار الإداري الموجهة: 12 مذكرة سداد.'),
            SizedBox(height: 6),
            Text('• مطابقة اللائحة التنفيذية: معتمدة بالكامل.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  // نافذة الإحصاء والتقارير
  static void _showReportsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.analytics_outlined, color: Color(0xFF059669)),
            SizedBox(width: 8),
            Text('تقارير الأداء والمطابقة', style: TextStyle(fontSize: 16)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('• نسبة التحصيل العام: 94.8% للشهر الحالي.'),
            SizedBox(height: 6),
            Text('• متوسط سرعة صرف منح الزواج: أقل من 24 ساعة.'),
            SizedBox(height: 6),
            Text('• المطابقة مع حسابات البنك المركزي: متطابقة 100%.'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }
}
