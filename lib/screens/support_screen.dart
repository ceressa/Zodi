import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../constants/colors.dart';

/// Destek ve SSS ekranı — Kapsamlı yardım merkezi
class SupportScreen extends StatelessWidget {
  const SupportScreen({super.key});

  // ─── Kategorize SSS Verileri ───
  static const List<_FaqCategory> _categories = [
    _FaqCategory(
      title: 'Genel',
      icon: '🔮',
      faqs: [
        _FaqData(
          q: 'Astro Dozi nedir?',
          a: 'Astro Dozi, yapay zeka destekli kişiselleştirilmiş astroloji uygulamasıdır. '
              'Google Gemini AI ve İsviçre Efemeris hesaplamalarıyla günlük burç yorumu, tarot falı, '
              'yükselen burç hesabı, uyumluluk analizi, rüya yorumu ve daha birçok özellik sunar.',
        ),
        _FaqData(
          q: 'Astroloji yorumları ne kadar doğrudur?',
          a: 'Tüm astroloji yorumları eğlence ve kişisel gelişim amaçlıdır. Gezegen pozisyonları '
              'İsviçre Efemeris verileriyle astronomik olarak doğru hesaplanır, ancak yorumlar '
              'kesinlik taşımaz. Önemli kararlarınızda profesyonel danışmanlık almanızı öneririz.',
        ),
        _FaqData(
          q: 'Uygulama hangi dilleri destekliyor?',
          a: 'Astro Dozi şu an yalnızca Türkçe desteklemektedir. İlerleyen dönemlerde yeni dil '
              'desteği eklemeyi planlıyoruz.',
        ),
        _FaqData(
          q: 'Verilerim güvende mi?',
          a: 'Tüm verileriniz Firebase üzerinde şifreli olarak saklanır. Kişisel bilgileriniz '
              'hiçbir üçüncü tarafla paylaşılmaz. İstediğiniz zaman hesabınızı ve tüm verilerinizi '
              'kalıcı olarak silebilirsiniz.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'Üyelik & Yıldız Tozu',
      icon: '👑',
      faqs: [
        _FaqData(
          q: 'Ücretsiz hesapla neler yapabilirim?',
          a: 'Ücretsiz hesapla günlük burç yorumu, temel tarot falı, burç uyumluluğu ve '
              'bazı eğlenceli özelliklerden yararlanabilirsin. Reklam izleyerek Yıldız Tozu kazanıp '
              'premium özelliklerin kilidini açabilirsin.',
        ),
        _FaqData(
          q: 'Üyelik planları arasındaki fark nedir?',
          a: 'Altın üyelik: Günlük bonus Yıldız Tozu, daha fazla reklam ödülü.\n'
              'Elmas üyelik: Reklamsız deneyim, tüm özellikler açık, yüksek günlük bonus.\n'
              'Platinyum üyelik: Her şey dahil — reklamsız, sınırsız özellikler, en yüksek günlük bonus.',
        ),
        _FaqData(
          q: 'Üyeliğimi nasıl iptal edebilirim?',
          a: 'Google Play Store → Profil simgesi → Ödemeler ve abonelikler → Abonelikler '
              'adımlarını izleyerek Astro Dozi aboneliğini iptal edebilirsin. İptal sonrası '
              'mevcut dönem sonuna kadar premium özelliklerini kullanmaya devam edersin.',
        ),
        _FaqData(
          q: 'Yıldız Tozlarım neden kayboldu?',
          a: 'Yıldız Tozları, özellikleri kullandığında otomatik olarak harcanır (tarot falı, detaylı analiz, '
              'kahve falı vb.). Yıldız Tozu bakiyeni Profil sekmesinden ve Premium ekranından görebilirsin. '
              'Reklam izleyerek veya Yıldız Tozu paketi satın alarak bakiyeni artırabilirsin.',
        ),
        _FaqData(
          q: 'Reklam izledim ama Yıldız Tozu yüklenmedi. Ne yapmalıyım?',
          a: 'Bazen reklam ağı gecikmeli yanıt verebilir. Uygulamayı kapatıp tekrar açmayı dene. '
              'Sorun devam ederse internet bağlantını kontrol et ve birkaç dakika sonra tekrar dene. '
              'Sürekli sorun yaşıyorsan bize astrodozi@dozi.app adresinden ulaş.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'Astroloji & Özellikler',
      icon: '⭐',
      faqs: [
        _FaqData(
          q: 'Yükselen burcum nasıl hesaplanıyor?',
          a: 'Yükselen burç hesabı için doğum tarihi, saati ve yeri gereklidir. '
              'İsviçre Efemeris verileri kullanılarak astronomik olarak doğru gezegen pozisyonları '
              'hesaplanır. Bilgilerini Doğum Bilgileri ekranından girebilirsin.',
        ),
        _FaqData(
          q: 'Tarot falı nasıl çalışıyor?',
          a: 'Tarot falında 22 Major Arcana kartından rastgele seçim yapılır. Her kart, '
              'senin burç bilgilerine ve kişisel profiline göre yapay zeka tarafından '
              'kişiselleştirilmiş bir yorumla sunulur. Günlük, haftalık ve genel olmak üzere '
              'farklı açılım türleri mevcuttur.',
        ),
        _FaqData(
          q: 'Doğum bilgilerimi neden girmeliyim?',
          a: 'Doğum tarihi burcunu, doğum saati yükselen burcunu, doğum yeri ise ev '
              'pozisyonlarını belirler. Bu bilgiler sayesinde çok daha kişiselleştirilmiş ve '
              'doğru astrolojik yorumlar alırsın. Doğum saatini bilmiyorsan sadece tarih ve '
              'şehir bilgisi de yeterlidir.',
        ),
        _FaqData(
          q: 'Burç uyumluluğu nasıl hesaplanıyor?',
          a: 'Burç uyumluluğu, iki burcun element (ateş, toprak, hava, su) ve modalite '
              '(kardinal, sabit, değişken) uyumuna göre hesaplanır. Yapay zeka bu verileri '
              'analiz ederek aşk, arkadaşlık ve iş uyumluluğunu ayrı ayrı değerlendirir.',
        ),
        _FaqData(
          q: 'Günlük burç yorumum her gün değişiyor mu?',
          a: 'Evet! Günlük burç yorumların her gün güncel gezegen geçişlerine ve kozmik '
              'enerjilere göre yapay zeka tarafından yeniden oluşturulur. Aynı gün içinde '
              'tekrar baktığında aynı yorumu görürsün (önbellek).',
        ),
        _FaqData(
          q: 'Kozmik Takvim ne işe yarar?',
          a: 'Kozmik Takvim, yaklaşan ay evreleri, gezegen retroları, tutulmalar ve önemli '
              'astrolojik geçişleri takip etmeni sağlar. Bu olayların burcunu nasıl '
              'etkileyebileceği hakkında bilgi verir.',
        ),
        _FaqData(
          q: 'Retro Takip nedir?',
          a: 'Retro Takip özelliği, hangi gezegenlerin retrograd (geri görünümlü) hareket '
              'ettiğini gösterir. Özellikle Merkür retrosu gibi önemli dönemlerde dikkat '
              'etmen gereken konuları ve önerileri sunar.',
        ),
      ],
    ),
    _FaqCategory(
      title: 'Teknik Sorunlar',
      icon: '🔧',
      faqs: [
        _FaqData(
          q: 'Uygulama çok yavaş çalışıyor. Ne yapabilirim?',
          a: '1. Uygulamayı tamamen kapatıp yeniden aç.\n'
              '2. İnternet bağlantını kontrol et (WiFi veya mobil veri).\n'
              '3. Telefonunun depolama alanının yeterli olduğundan emin ol.\n'
              '4. Uygulamayı Play Store\'dan güncelleyerek en son sürümü kullan.',
        ),
        _FaqData(
          q: 'Bildirimler gelmiyor. Ne yapmalıyım?',
          a: 'Telefon Ayarları → Uygulamalar → Astro Dozi → Bildirimler bölümünden bildirimlerin '
              'açık olduğunu kontrol et. Ayrıca uygulama içi Profil → Bildirimler bölümünden '
              'günlük bildirim saatini ayarlayabilirsin. Pil tasarrufu modunun bildirimleri '
              'engelleyebileceğini unutma.',
        ),
        _FaqData(
          q: 'Uygulamada hata alıyorum. Ne yapmalıyım?',
          a: '1. Uygulamayı kapatıp tekrar aç.\n'
              '2. İnternet bağlantını kontrol et.\n'
              '3. Play Store\'dan uygulama güncellemesi var mı kontrol et.\n'
              '4. Sorun devam ederse Geri Bildirim ekranından veya astrodozi@dozi.app '
              'adresinden bize hatanın ekran görüntüsüyle birlikte ulaş.',
        ),
        _FaqData(
          q: 'Hesabımı nasıl silebilirim?',
          a: 'Profil → Hesap & Destek → Hesap Yönetimi → Hesabı Sil adımlarını izleyerek '
              'hesabını ve tüm verilerini kalıcı olarak silebilirsin. Bu işlem geri alınamaz.',
        ),
        _FaqData(
          q: 'Farklı bir cihazda giriş yapabilir miyim?',
          a: 'Evet! Aynı Google hesabınla veya e-posta/şifrenle farklı bir cihazdan giriş '
              'yapabilirsin. Tüm verilerin, Yıldız Tozu bakiyen ve üyelik bilgilerin Firebase\'de '
              'saklandığı için otomatik olarak senkronize edilir.',
        ),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F5FF),
      appBar: AppBar(
        title: const Text(
          'Destek & SSS',
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
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Hero Section ───
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.accentPurple.withOpacity(0.12),
                    AppColors.accentBlue.withOpacity(0.08),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.accentPurple.withOpacity(0.15)),
              ),
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: AppColors.purpleGradient,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Nasıl yardımcı olabiliriz?',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Aradığın cevabı bulamadıysan bize ulaş',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.05),

            const SizedBox(height: 20),

            // ─── İletişim Kartı ───
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.accentPurple.withOpacity(0.12)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.accentPurple.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.email_outlined, color: AppColors.accentPurple, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'E-posta ile ulaş',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const Text(
                          'astrodozi@dozi.app',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.accentPurple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: AppColors.textMuted.withOpacity(0.5)),
                ],
              ),
            ).animate().fadeIn(delay: 100.ms, duration: 400.ms),

            const SizedBox(height: 28),

            // ─── SSS Kategorileri ───
            const Text(
              'Sıkça Sorulan Sorular',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${_categories.fold<int>(0, (sum, c) => sum + c.faqs.length)} soru & cevap',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),

            ...List.generate(_categories.length, (catIndex) {
              final category = _categories[catIndex];
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: _CategorySection(
                  category: category,
                  delay: 200 + catIndex * 100,
                ),
              );
            }),

            const SizedBox(height: 16),

            // ─── Alt bilgi ───
            Center(
              child: Text(
                'Sorunu bulamadın mı? astrodozi@dozi.app adresine yaz.\nEn kısa sürede dönüş yapacağız.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Data Models ───

class _FaqData {
  final String q;
  final String a;
  const _FaqData({required this.q, required this.a});
}

class _FaqCategory {
  final String title;
  final String icon;
  final List<_FaqData> faqs;
  const _FaqCategory({required this.title, required this.icon, required this.faqs});
}

// ─── Kategori Bölümü Widget'ı ───

class _CategorySection extends StatelessWidget {
  final _FaqCategory category;
  final int delay;

  const _CategorySection({required this.category, required this.delay});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: category.title == 'Genel',
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          leading: Text(category.icon, style: const TextStyle(fontSize: 24)),
          title: Row(
            children: [
              Text(
                category.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.accentPurple.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${category.faqs.length}',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.accentPurple,
                  ),
                ),
              ),
            ],
          ),
          iconColor: AppColors.accentPurple,
          collapsedIconColor: AppColors.textMuted,
          children: List.generate(category.faqs.length, (i) {
            return _FaqItem(
              question: category.faqs[i].q,
              answer: category.faqs[i].a,
            );
          }),
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: delay), duration: 400.ms)
        .slideX(begin: 0.03, end: 0);
  }
}

// ─── Tek SSS Widget'ı ───

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> with SingleTickerProviderStateMixin {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => setState(() => _expanded = !_expanded),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: _expanded
              ? AppColors.accentPurple.withOpacity(0.06)
              : const Color(0xFFFAF8FF),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _expanded
                ? AppColors.accentPurple.withOpacity(0.25)
                : Colors.grey.shade200,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _expanded ? Icons.help : Icons.help_outline,
                  size: 18,
                  color: _expanded ? AppColors.accentPurple : AppColors.textMuted,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.question,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: _expanded ? AppColors.accentPurple : AppColors.textDark,
                    ),
                  ),
                ),
                AnimatedRotation(
                  turns: _expanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 250),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: _expanded ? AppColors.accentPurple : AppColors.textMuted,
                    size: 22,
                  ),
                ),
              ],
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox.shrink(),
              secondChild: Padding(
                padding: const EdgeInsets.only(top: 10, left: 28),
                child: Text(
                  widget.answer,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.textMuted,
                    height: 1.6,
                  ),
                ),
              ),
              crossFadeState:
                  _expanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 250),
            ),
          ],
        ),
      ),
    );
  }
}
