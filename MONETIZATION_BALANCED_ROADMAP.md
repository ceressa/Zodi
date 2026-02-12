# Balanced Revenue Roadmap (Retention-Safe)

Bu doküman Zodi için **orta agresif, retention dostu** gelir modelinin yol haritasıdır.

## Hedef Prensipler
- Kullanıcı deneyimini bozmadan gelir artırmak
- Reklam yorgunluğunu (ad fatigue) önlemek
- Rewarded + Premium hibrit modeli güçlendirmek
- Veriye dayalı iterasyon yapmak

---

## Bu PR ile Canlıya Alınanlar

### 1) Interstitial için Balanced Guardrails
- Yeni kullanıcılar için daha düşük günlük limit (`2/gün`)
- Mevcut kullanıcılar için kontrollü limit (`3/gün`)
- Yeni kullanıcılar için daha seyrek gösterim (`4 ekran`), mevcut kullanıcılar için (`3 ekran`)
- Minimum gösterim aralığı (`4 dakika` cooldown)
- Install yaşına göre dinamik karar

### 2) Reklam Event Entegrasyonu
- Navigation interstitial gösteriminde analytics event
- Daily “yarın önizleme” rewarded akışında success/fail event

---

## Sıradaki Fazlar

### Faz 1 — Ad Ops & Mediation
- Test ad unit’lerden production ad unit’lere geçiş
- Mediation kurulumu (en az 2 ağ)
- Fill-rate ve eCPM bazlı günlük raporlama

### Faz 2 — Rewarded Economy
- Rewarded ile açılabilen 2-3 yeni değerli aksiyon
- Rewarded sonrası kısa süreli ad-light penceresi
- Cooldown ve günlük hak yönetimi

### Faz 3 — Premium Dönüşüm
- Tek plan yerine çoklu paket (Lite/Plus/Pro)
- Aylık-yıllık-lifetime seçenekleri
- Paywall A/B testleri (fiyat ve metin)

### Faz 4 — Segment Bazlı Kişiselleştirme
- New / Engaged / Rewarded-heavy / Dormant segmentleri
- Segmente göre ad cap, interstitial eşiği, paywall zamanı

### Faz 5 — Otomasyon
- Remote config/feature flag ile canlı optimizasyon
- Guardrail: retention düşerse agresifliği otomatik azalt

---

## KPI’lar
- Ad ARPDAU
- Rewarded completion rate
- Paywall conversion
- D1/D7 retention etkisi
- Free→Premium dönüşüm oranı

## Başarı Ölçütü
- Gelir artarken retention’de anlamlı bozulma olmaması.
