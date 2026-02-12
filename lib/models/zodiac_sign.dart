enum ZodiacSign {
  aries('Koç', '21 Mart - 19 Nisan', '♈'),
  taurus('Boğa', '20 Nisan - 20 Mayıs', '♉'),
  gemini('İkizler', '21 Mayıs - 20 Haziran', '♊'),
  cancer('Yengeç', '21 Haziran - 22 Temmuz', '♋'),
  leo('Aslan', '23 Temmuz - 22 Ağustos', '♌'),
  virgo('Başak', '23 Ağustos - 22 Eylül', '♍'),
  libra('Terazi', '23 Eylül - 22 Ekim', '♎'),
  scorpio('Akrep', '23 Ekim - 21 Kasım', '♏'),
  sagittarius('Yay', '22 Kasım - 21 Aralık', '♐'),
  capricorn('Oğlak', '22 Aralık - 19 Ocak', '♑'),
  aquarius('Kova', '20 Ocak - 18 Şubat', '♒'),
  pisces('Balık', '19 Şubat - 20 Mart', '♓');

  final String displayName;
  final String dateRange;
  final String symbol;

  const ZodiacSign(this.displayName, this.dateRange, this.symbol);
  
  // Getter for Turkish name (same as displayName)
  String get turkishName => displayName;

  static ZodiacSign? fromString(String name) {
    try {
      return ZodiacSign.values.firstWhere(
        (sign) => sign.displayName == name,
      );
    } catch (e) {
      return null;
    }
  }
}
