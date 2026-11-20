import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'admin_departments_screen.dart';
import 'client_portal_screen.dart';

class UnifiedLoginScreen extends StatefulWidget {
  const UnifiedLoginScreen({super.key});

  @override
  State<UnifiedLoginScreen> createState() => _UnifiedLoginScreenState();
}

class _UnifiedLoginScreenState extends State<UnifiedLoginScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  bool _isAdminMode = true;
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _passwordController.dispose();
    super.dispose();
  }

  // التحقق من كلمة المرور عبر Firestore
  Future<void> _login() async {
    final enteredPassword = _passwordController.text.trim();

    if (enteredPassword.isEmpty) {
      _showErrorDialog('يرجى إدخال كلمة المرور أولاً');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final docId = _isAdminMode ? 'admin_config' : 'client_config';
      final docRef = _firestore.collection('system_auth').doc(docId);
      final snapshot = await docRef.get();

      String validPassword;

      if (!snapshot.exists) {
        // تهيئة كلمات المرور الافتراضية في Firestore لأول مرة
        validPassword = _isAdminMode ? 'admin' : '123';
        await docRef.set({
          'password': validPassword,
          'role': _isAdminMode ? 'admin' : 'client',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        validPassword =
            snapshot.data()?['password'] ?? (_isAdminMode ? 'admin' : '123');
      }

      if (enteredPassword == validPassword) {
        if (!mounted) return;
        if (_isAdminMode) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const AdminDepartmentsScreen()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const ClientPortalScreen(
                userName: 'المؤمن عليه',
                insuranceNo: 'INS-2026-001',
              ),
            ),
          );
        }
      } else {
        _showErrorDialog(
          _isAdminMode
              ? 'كلمة مرور الإدارة غير صحيحة'
              : 'رمز دخول بوابة المستفيدين غير صحيح',
        );
      }
    } catch (e) {
      _showErrorDialog('تعذر الاتصال بقاعدة البيانات: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showErrorDialog(String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(
          'فشل الدخول',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }

  // نافذة تغيير كلمة المرور وتحديثها في Firestore
  void _openChangePasswordModal() {
    final oldPassController = TextEditingController();
    final newPassController = TextEditingController();
    final confirmPassController = TextEditingController();
    bool isSaving = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setModalState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.key,
                color: _isAdminMode
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFBE185D),
              ),
              const SizedBox(width: 8),
              Text(
                _isAdminMode ? 'تغيير كلمة مرور الإدارة' : 'تغيير رمز المستفيد',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: oldPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الحالية',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: newPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'كلمة المرور الجديدة',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: confirmPassController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'تأكيد كلمة المرور الجديدة',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSaving ? null : () => Navigator.pop(ctx),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _isAdminMode
                    ? const Color(0xFF0F766E)
                    : const Color(0xFFBE185D),
              ),
              onPressed: isSaving
                  ? null
                  : () async {
                      final oldP = oldPassController.text.trim();
                      final newP = newPassController.text.trim();
                      final confP = confirmPassController.text.trim();

                      if (oldP.isEmpty || newP.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('يرجى ملء كافة الحقول')),
                        );
                        return;
                      }
                      if (newP != confP) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('كلمة المرور الجديدة غير متطابقة'),
                          ),
                        );
                        return;
                      }

                      setModalState(() => isSaving = true);

                      try {
                        final docId = _isAdminMode
                            ? 'admin_config'
                            : 'client_config';
                        final docRef = _firestore
                            .collection('system_auth')
                            .doc(docId);
                        final snapshot = await docRef.get();

                        String currentPass = _isAdminMode ? 'admin' : '123';
                        if (snapshot.exists) {
                          currentPass =
                              snapshot.data()?['password'] ?? currentPass;
                        }

                        if (oldP == currentPass) {
                          await docRef.set({
                            'password': newP,
                            'role': _isAdminMode ? 'admin' : 'client',
                            'updatedAt': FieldValue.serverTimestamp(),
                          }, SetOptions(merge: true));

                          if (!context.mounted) return;
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم تحديث كلمة المرور في السحابة بنجاح!',
                              ),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          setModalState(() => isSaving = false);
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('كلمة المرور الحالية غير صحيحة'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      } catch (e) {
                        setModalState(() => isSaving = false);
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('تعذر الحفظ في قاعدة البيانات: $e'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              child: isSaving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'تحديث وحفظ',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = _isAdminMode
        ? const Color(0xFF0F766E)
        : const Color(0xFFBE185D);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: activeColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isAdminMode ? Icons.admin_panel_settings : Icons.person_pin,
                  size: 64,
                  color: activeColor,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'منظومة التأمينات الاجتماعية والمعاشات',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                _isAdminMode
                    ? 'تسجيل دخول الكادر الإداري'
                    : 'بوابة المستفيدين والمؤمن عليهم',
                style: TextStyle(
                  fontSize: 14,
                  color: activeColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ChoiceChip(
                      label: const Text('لوحة الإدارة'),
                      selected: _isAdminMode,
                      selectedColor: const Color(0xFF0F766E),
                      labelStyle: TextStyle(
                        color: _isAdminMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _isAdminMode = true;
                          _passwordController.clear();
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('بوابة المستفيد'),
                      selected: !_isAdminMode,
                      selectedColor: const Color(0xFFBE185D),
                      labelStyle: TextStyle(
                        color: !_isAdminMode ? Colors.white : Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        setState(() {
                          _isAdminMode = false;
                          _passwordController.clear();
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: _isAdminMode
                      ? 'كلمة المرور (الافتراضية: admin)'
                      : 'رمز الدخول (الافتراضي: 123)',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: Icon(Icons.lock_outline, color: activeColor),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _openChangePasswordModal,
                  icon: Icon(Icons.lock_reset, size: 18, color: activeColor),
                  label: Text(
                    'تغيير كلمة المرور؟',
                    style: TextStyle(
                      color: activeColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: activeColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 36),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.asset(
                      'assets/images/pnm_logo.jpg',
                      width: 26,
                      height: 26,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.laptop,
                        size: 22,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'تصميم: شركة بي إن إم سوفت (P.N.M SOFT)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF64748B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
