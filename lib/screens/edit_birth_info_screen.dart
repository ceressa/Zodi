import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../constants/colors.dart';

/// Doğum bilgilerini düzenleme ekranı
class EditBirthInfoScreen extends StatefulWidget {
  const EditBirthInfoScreen({super.key});

  @override
  State<EditBirthInfoScreen> createState() => _EditBirthInfoScreenState();
}

class _EditBirthInfoScreenState extends State<EditBirthInfoScreen> {
  final _birthPlaceController = TextEditingController();
  final _birthTimeController = TextEditingController();
  DateTime? _birthDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = context.read<AuthProvider>().userProfile;
    if (profile != null) {
      _birthDate = profile.birthDate;
      _birthPlaceController.text = profile.birthPlace;
      _birthTimeController.text = profile.birthTime;
    }
  }

  @override
  void dispose() {
    _birthPlaceController.dispose();
    _birthTimeController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(1995, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  Future<void> _save() async {
    if (_isSaving) return;
    setState(() => _isSaving = true);
    try {
      await context.read<AuthProvider>().updateProfile(
            birthDate: _birthDate,
            birthTime: _birthTimeController.text.trim(),
            birthPlace: _birthPlaceController.text.trim(),
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Doğum bilgileri güncellendi!'),
            backgroundColor: AppColors.positive,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        Navigator.pop(context);
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Doğum Bilgileri',
          style: TextStyle(
            color: AppColors.textDark,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: const Color(0xFFF8F5FF),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Doğum bilgilerini güncelle',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: isDark ? Colors.white : AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Daha doğru astrolojik hesaplamalar için bilgilerini gir.',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white60 : AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 32),

            // Doğum tarihi
            _buildLabel('Doğum Tarihi', isDark),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.accentPurple.withOpacity(0.3)),
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? const Color(0xFF1E1B4B) : Colors.white,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.cake_rounded, color: AppColors.accentPurple),
                    const SizedBox(width: 12),
                    Text(
                      _birthDate != null
                          ? '${_birthDate!.day}.${_birthDate!.month}.${_birthDate!.year}'
                          : 'Tarih seç',
                      style: TextStyle(
                        fontSize: 16,
                        color: _birthDate != null
                            ? (isDark ? Colors.white : AppColors.textDark)
                            : AppColors.textMuted,
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.chevron_right, color: AppColors.accentPurple),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Doğum saati
            _buildLabel('Doğum Saati (isteğe bağlı)', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _birthTimeController,
              decoration: InputDecoration(
                hintText: 'örn: 14:30',
                prefixIcon: const Icon(Icons.access_time_rounded, color: AppColors.accentPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.3)),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Doğum yeri
            _buildLabel('Doğum Yeri (isteğe bağlı)', isDark),
            const SizedBox(height: 8),
            TextField(
              controller: _birthPlaceController,
              decoration: InputDecoration(
                hintText: 'örn: İstanbul',
                prefixIcon: const Icon(Icons.location_on_rounded, color: AppColors.accentPurple),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: AppColors.accentPurple.withOpacity(0.3)),
                ),
              ),
            ),

            const SizedBox(height: 40),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accentPurple,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Kaydet',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: isDark ? Colors.white70 : AppColors.textDark,
      ),
    );
  }
}
