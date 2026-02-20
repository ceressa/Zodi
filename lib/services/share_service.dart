import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

/// Paylaşım servisi — uygulama genelinde kullanılabilir
class ShareService {
  static final ShareService _instance = ShareService._internal();
  factory ShareService() => _instance;
  ShareService._internal();

  /// Metin paylaşımı
  Future<void> shareText(String text) async {
    await Share.share(text);
  }

  /// Günlük fal paylaşımı
  Future<void> shareDailyHoroscope({
    required String zodiacName,
    required String zodiacSymbol,
    required String motto,
    required String commentary,
    required int love,
    required int money,
    required int health,
    required int career,
    required String luckyColor,
    required int luckyNumber,
  }) async {
    final text = '''
$zodiacSymbol $zodiacName Günlük Fal — Zodi

"$motto"

💕 Aşk: %$love | 💰 Para: %$money
💪 Sağlık: %$health | 💼 Kariyer: %$career

🎨 Şanslı Renk: $luckyColor
🔢 Şanslı Sayı: $luckyNumber

${commentary.length > 200 ? '${commentary.substring(0, 200)}...' : commentary}

📱 Zodi uygulamasıyla sen de falına baktır!
🔮 #Zodi #$zodiacName #GünlükBurç
''';
    await Share.share(text);
  }

  /// Uyum sonucu paylaşımı
  Future<void> shareCompatibility({
    required String sign1Name,
    required String sign1Symbol,
    required String sign2Name,
    required String sign2Symbol,
    required int score,
    required int love,
    required int communication,
    required int trust,
    required String summary,
  }) async {
    final text = '''
$sign1Symbol $sign1Name & $sign2Symbol $sign2Name Uyumu — Zodi

💫 Genel Uyum: %$score

💕 Aşk: %$love
💬 İletişim: %$communication
🤝 Güven: %$trust

${summary.length > 200 ? '${summary.substring(0, 200)}...' : summary}

📱 Sen de uyumunu öğren! Zodi'yi indir!
🔮 #Zodi #BurcUyumu
''';
    await Share.share(text);
  }

  /// Tarot kartı paylaşımı
  Future<void> shareTarot({
    required String cardName,
    required String interpretation,
  }) async {
    final text = '''
🎴 Tarot Kartım: $cardName — Zodi

$interpretation

📱 Sen de kartını çek! Zodi'yi indir!
🔮 #Zodi #Tarot #GünlükKart
''';
    await Share.share(text);
  }

  /// Kozmik kutu paylaşımı
  Future<void> shareCosmicBox({
    required String rewardType,
    required String rewardName,
    required String description,
    required String emoji,
  }) async {
    final text = '''
🎁 Kozmik Kutumdan Çıkan: $emoji $rewardName

$description

📱 Sen de günlük kozmik kutunu aç! Zodi'yi indir!
✨ #Zodi #KozmikKutu
''';
    await Share.share(text);
  }

  /// Profil kartı paylaşımı
  Future<void> shareProfileCard({
    required String name,
    required String sunSign,
    required String sunSymbol,
    String? risingSign,
    String? moonSign,
    required String element,
  }) async {
    final text = '''
✨ Astrolojik Profilim — Zodi

👤 $name
☀️ Güneş: $sunSymbol $sunSign
${risingSign != null ? '⬆️ Yükselen: $risingSign' : ''}
${moonSign != null ? '🌙 Ay: $moonSign' : ''}
🔥 Element: $element

📱 Sen de profilini oluştur! Zodi'yi indir!
🔮 #Zodi #AstrolojikProfil #$sunSign
''';
    await Share.share(text);
  }

  /// Widget'ı görüntü olarak yakala ve paylaş (ekranda mevcut RepaintBoundary için)
  Future<void> shareWidgetAsImage(
    GlobalKey repaintBoundaryKey, {
    String? text,
  }) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) return;

      final bytes = byteData.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/zodi_share_${DateTime.now().millisecondsSinceEpoch}.png');
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? '📱 Astro Dozi uygulamasıyla sen de falına baktır! 🔮',
      );

      _cleanupTempFiles(tempDir);
    } catch (e) {
      if (text != null) {
        await Share.share(text);
      }
    }
  }

  /// Paylaşım kartı widget'ını offscreen render edip paylaş
  Future<void> shareCardWidget(
    BuildContext context,
    Widget cardWidget, {
    String? text,
    double width = 1080,
    double height = 1920,
  }) async {
    try {
      final cardKey = GlobalKey();

      final overlayEntry = OverlayEntry(
        builder: (_) => Positioned(
          left: -width * 2,
          top: -height * 2,
          child: RepaintBoundary(
            key: cardKey,
            child: SizedBox(
              width: width,
              height: height,
              child: MediaQuery(
                data: const MediaQueryData(devicePixelRatio: 1.0),
                child: Material(
                  color: Colors.transparent,
                  child: cardWidget,
                ),
              ),
            ),
          ),
        ),
      );

      Overlay.of(context).insert(overlayEntry);
      await Future.delayed(const Duration(milliseconds: 500));

      final boundary = cardKey.currentContext?.findRenderObject()
          as RenderRepaintBoundary?;

      if (boundary == null) {
        overlayEntry.remove();
        if (text != null) await Share.share(text);
        return;
      }

      final image = await boundary.toImage(pixelRatio: 1.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      overlayEntry.remove();

      if (byteData == null) {
        if (text != null) await Share.share(text);
        return;
      }

      final bytes = byteData.buffer.asUint8List();
      final tempDir = await getTemporaryDirectory();
      final file = File(
        '${tempDir.path}/zodi_card_${DateTime.now().millisecondsSinceEpoch}.png',
      );
      await file.writeAsBytes(bytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: text ?? '📱 Astro Dozi uygulamasıyla sen de falına baktır! 🔮\n#AstroDozi #Astroloji',
      );

      _cleanupTempFiles(tempDir);
    } catch (e) {
      debugPrint('Share card error: $e');
      if (text != null) {
        await Share.share(text);
      }
    }
  }

  /// Eski temp dosyalarını temizle
  void _cleanupTempFiles(Directory tempDir) {
    try {
      final now = DateTime.now();
      tempDir.listSync().where((f) {
        return f.path.contains('zodi_share_') || f.path.contains('zodi_card_');
      }).forEach((f) {
        final stat = f.statSync();
        if (now.difference(stat.modified).inHours > 1) {
          f.deleteSync();
        }
      });
    } catch (_) {}
  }
}
