import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;
import '../providers/auth_provider.dart';
import '../services/ad_service.dart';
import '../constants/colors.dart';
import 'premium_screen.dart';

class BirthChartScreen extends StatefulWidget {
  const BirthChartScreen({super.key});

  @override
  State<BirthChartScreen> createState() => _BirthChartScreenState();
}

class _BirthChartScreenState extends State<BirthChartScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  final TextEditingController _cityController = TextEditingController();
  bool _showChart = false;
  final AdService _adService = AdService();
  bool _chartUnlockedByAd = false;

  final List<Map<String, dynamic>> _planets = [
    {
      'name': 'Güneş',
      'sign': '♋ Yengeç',
      'house': '10. Ev',
      'colors': [Color(0xFFFBBF24), Color(0xFFF59E0B)]
    },
    {
      'name': 'Ay',
      'sign': '♉ Boğa',
      'house': '7. Ev',
      'colors': [Color(0xFFBFDBFE), Color(0xFF93C5FD)]
    },
    {
      'name': 'Merkür',
      'sign': '♊ İkizler',
      'house': '9. Ev',
      'colors': [Color(0xFF34D399), Color(0xFF10B981)]
    },
    {
      'name': 'Venüs',
      'sign': '♌ Aslan',
      'house': '11. Ev',
      'colors': [Color(0xFFF472B6), Color(0xFFBE185D)]
    },
    {
      'name': 'Mars',
      'sign': '♈ Koç',
      'house': '6. Ev',
      'colors': [Color(0xFFFB7185), Color(0xFFE11D48)]
    },
    {
      'name': 'Jüpiter',
      'sign': '♐ Yay',
      'house': '2. Ev',
      'colors': [Color(0xFFA78BFA), Color(0xFF7C3AED)]
    },
  ];

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1995),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  void _submitForm() async {
    if (!(_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _selectedTime != null)) {
      return;
    }

    final authProvider = context.read<AuthProvider>();
    if (authProvider.isPremium || _chartUnlockedByAd) {
      setState(() => _showChart = true);
      return;
    }

    // Show gate dialog
    _showChartGateDialog();
  }

  void _showChartGateDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF9333EA)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF7C3AED).withOpacity(0.3),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Center(
                child: Text('🪐', style: TextStyle(fontSize: 36)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Doğum Haritanı Gör',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Gezegen konumlarını ve kişisel yorumunu görmek için reklam izle veya premium\'a geç!',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  Navigator.pop(ctx);
                  final success = await _adService.showRewardedAd(
                    placement: 'birth_chart_unlock',
                  );
                  if (success && mounted) {
                    setState(() {
                      _chartUnlockedByAd = true;
                      _showChart = true;
                    });
                  }
                },
                icon: const Icon(Icons.play_circle_outline),
                label: const Text('Reklam İzle & Haritayı Gör'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF7C3AED),
                  side: const BorderSide(color: Color(0xFF7C3AED)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(ctx);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const PremiumScreen()),
                  );
                },
                icon: const Icon(Icons.diamond, size: 18),
                label: const Text('Premium\'a Geç'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFDDD6FE), Color(0xFFFAE8FF), Color(0xFFFECDD3)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: _showChart ? _buildChartView() : _buildFormView(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF6B21A8)),
            onPressed: () {
              if (_showChart) {
                setState(() => _showChart = false);
              } else {
                Navigator.pop(context);
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFormView() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          const SizedBox(height: 20),
          _buildRotatingCircles(),
          const SizedBox(height: 16),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFF6366F1), Color(0xFF7C3AED)],
            ).createShader(bounds),
            child: const Text(
              'Doğum Haritası',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Kozmik kimliğini keşfet 🌟',
            style: TextStyle(
              fontSize: 16,
              color: Color(0xFF7C3AED),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.8),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Doğum Haritası Nedir?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF7C3AED),
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Doğduğun an gökyüzündeki gezegenlerin konumlarını gösteren haritadır. Kişiliğin, yeteneklerin ve yaşam yolun hakkında derin bilgiler verir.',
                  style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          _buildDateField(),
          const SizedBox(height: 16),
          _buildTimeField(),
          const SizedBox(height: 16),
          _buildCityField(),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _submitForm,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF7C3AED),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 8,
              ),
              child: Builder(
                builder: (ctx) {
                  final isPremium = ctx.read<AuthProvider>().isPremium;
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome),
                      const SizedBox(width: 8),
                      const Text(
                        'Haritamı Oluştur',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      if (!isPremium && !_chartUnlockedByAd) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.play_circle_outline, color: Colors.white, size: 14),
                              SizedBox(width: 3),
                              Text('AD', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDDD6FE),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF7C3AED), width: 2),
            ),
            child: const Text(
              '💡 Doğum saatinizi bilmiyorsanız, 12:00 yazabilirsiniz',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B21A8)),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRotatingCircles() {
    return SizedBox(
      width: 96,
      height: 96,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA78BFA), width: 2),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 20.seconds),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF7C3AED), width: 2),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF6366F1), width: 2),
            ),
          ),
          const Text('✨', style: TextStyle(fontSize: 32)),
        ],
      ),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA78BFA), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: Color(0xFF7C3AED)),
            const SizedBox(width: 12),
            Text(
              _selectedDate == null
                  ? 'Doğum Tarihiniz'
                  : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedDate == null
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeField() {
    return GestureDetector(
      onTap: _selectTime,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFA78BFA), width: 2),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF7C3AED)),
            const SizedBox(width: 12),
            Text(
              _selectedTime == null
                  ? 'Doğum Saatiniz'
                  : '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 16,
                color: _selectedTime == null
                    ? const Color(0xFFA78BFA)
                    : const Color(0xFF7C3AED),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCityField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA78BFA), width: 2),
      ),
      child: Row(
        children: [
          const Icon(Icons.location_on, color: Color(0xFF7C3AED)),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Doğduğun şehir',
                hintStyle: TextStyle(color: Color(0xFFA78BFA)),
              ),
              style: const TextStyle(fontSize: 16, color: Color(0xFF7C3AED)),
              validator: (value) =>
                  value?.isEmpty ?? true ? 'Lütfen şehir girin' : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartView() {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Text(
          'Senin Doğum Haritam',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF7C3AED),
          ),
        ),
        if (_selectedDate != null && _selectedTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year} - ${_selectedTime!.format(context)} - ${_cityController.text}',
              style: const TextStyle(fontSize: 14, color: Color(0xFF9333EA)),
            ),
          ),
        const SizedBox(height: 32),
        _buildZodiacWheel(),
        const SizedBox(height: 32),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            '🪐 Gezegen Konumların',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF7C3AED),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ..._planets.asMap().entries.map((entry) {
          final index = entry.key;
          final planet = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: planet['colors']),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: planet['colors'][0].withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        planet['name'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        planet['house'],
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                  Text(
                    planet['sign'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            )
                .animate(delay: Duration(milliseconds: index * 100))
                .fadeIn()
                .slideX(begin: -0.2, end: 0),
          );
        }).toList(),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '📖 Kısa Yorum',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF7C3AED),
                ),
              ),
              SizedBox(height: 12),
              Text(
                'Güneşin Yengeç burcunda olması duygusal derinliğine ve empati yeteneğine işaret eder. Ay\'ın Boğa\'da olması seni sakinlik arayışında ve güvenlik odaklı yapar. Yükselen burcun Aslan ise karizmatik ve yaratıcı bir kişiliğe sahip olduğunu gösterir.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black87,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7C3AED),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.download),
                SizedBox(width: 8),
                Text('Haritayı İndir', style: TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            onPressed: () => setState(() => _showChart = false),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFF7C3AED)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'Yeni Harita Oluştur',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF7C3AED),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildZodiacWheel() {
    final zodiacSigns = ['♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑', '♒', '♓'];
    return SizedBox(
      width: 280,
      height: 280,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFA78BFA), width: 4),
            ),
          )
              .animate(onPlay: (controller) => controller.repeat())
              .rotate(duration: 60.seconds),
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFF9A8D4), width: 4),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF818CF8), width: 4),
              gradient: const LinearGradient(
                colors: [Color(0xFFF5F3FF), Color(0xFFFCE7F3)],
              ),
            ),
          ),
          const Text('🌟', style: TextStyle(fontSize: 48)),
          ...zodiacSigns.asMap().entries.map((entry) {
            final index = entry.key;
            final sign = entry.value;
            final angle = (index * 30) - 90;
            final radian = angle * math.pi / 180;
            final x = math.cos(radian) * 120;
            final y = math.sin(radian) * 120;
            return Positioned(
              left: 140 + x - 12,
              top: 140 + y - 12,
              child: Text(
                sign,
                style: const TextStyle(fontSize: 24, color: Color(0xFF7C3AED)),
              ),
            );
          }).toList(),
        ],
      ),
    ).animate().scale(begin: const Offset(0, 0), duration: 1.seconds, curve: Curves.elasticOut);
  }
}