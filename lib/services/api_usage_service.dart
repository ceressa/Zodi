import 'package:flutter/foundation.dart';

/// Gemini API kullanım takip servisi — token kullanımını loglar
class ApiUsageService {
  static final ApiUsageService _instance = ApiUsageService._internal();
  factory ApiUsageService() => _instance;
  ApiUsageService._internal();

  int _totalInputTokens = 0;
  int _totalOutputTokens = 0;
  int _totalCalls = 0;

  int get totalInputTokens => _totalInputTokens;
  int get totalOutputTokens => _totalOutputTokens;
  int get totalCalls => _totalCalls;

  /// Metin için tahmini token sayısını hesapla
  /// Yaklaşık: 4 karakter ≈ 1 token (Türkçe için biraz daha fazla)
  static int estimateTokens(String text) {
    if (text.isEmpty) return 0;
    return (text.length / 3.5).ceil();
  }

  /// API çağrısını logla
  Future<void> logApiCall({
    required String feature,
    required int inputTokens,
    required int outputTokens,
    required int totalTokens,
  }) async {
    _totalInputTokens += inputTokens;
    _totalOutputTokens += outputTokens;
    _totalCalls++;

    debugPrint(
      '[ApiUsage] $feature — '
      'in: $inputTokens, out: $outputTokens, total: $totalTokens | '
      'Kümülatif: $_totalCalls çağrı, ${_totalInputTokens + _totalOutputTokens} token',
    );
  }

  /// Kullanım istatistiklerini sıfırla
  void resetStats() {
    _totalInputTokens = 0;
    _totalOutputTokens = 0;
    _totalCalls = 0;
  }
}
