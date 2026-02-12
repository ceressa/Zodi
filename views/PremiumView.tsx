
import React from 'react';
import { Sparkles, Crown, Check, X, ShieldCheck, Zap, Star, Heart } from 'lucide-react';

interface PremiumViewProps {
  onPurchase: () => void;
  onBack: () => void;
}

const PremiumView: React.FC<PremiumViewProps> = ({ onPurchase, onBack }) => {
  return (
    <div className="fixed inset-0 bg-[#050209] z-[200] flex flex-col overflow-y-auto">
      {/* Background Effects */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-0 left-0 w-full h-[60%] bg-gradient-to-b from-[#7B1FA2]/20 to-transparent" />
        <div className="absolute top-[20%] right-[-10%] w-96 h-96 bg-[#D4AF37]/10 blur-[120px] rounded-full animate-pulse" />
      </div>

      {/* Header */}
      <div className="relative p-6 flex justify-between items-center z-10">
        <button onClick={onBack} className="w-10 h-10 rounded-full bg-white/5 flex items-center justify-center text-white/40">
          <X size={20} />
        </button>
        <div className="flex items-center gap-2">
           <Crown size={16} className="text-[#D4AF37]" />
           <span className="text-[10px] font-bold text-[#D4AF37] uppercase tracking-[4px]">Zodi Premium</span>
        </div>
        <div className="w-10" /> {/* Spacer */}
      </div>

      {/* Content */}
      <div className="relative z-10 px-8 pt-4 pb-12 flex flex-col items-center">
        <div className="w-24 h-24 bg-gradient-to-tr from-[#D4AF37] to-[#F9D976] rounded-[40px] flex items-center justify-center shadow-[0_20px_60px_rgba(212,175,55,0.3)] mb-10 relative">
          <div className="absolute inset-[-10px] border border-[#D4AF37]/20 rounded-[50px] animate-ping opacity-20" />
          <Crown size={48} className="text-black" />
        </div>

        <h2 className="text-4xl font-black text-white font-montserrat tracking-tight text-center mb-4">
          KOZMİK <br /> <span className="gold-text">AYRICALIK</span>
        </h2>
        <p className="text-white/40 text-sm font-medium text-center mb-12 max-w-[280px]">
          Yıldızların tüm sırlarını kısıtlama olmadan, en saf haliyle keşfet.
        </p>

        {/* Benefits List */}
        <div className="w-full space-y-5 mb-12">
          <BenefitItem icon={<ShieldCheck className="text-[#4FC3F7]" size={20} />} text="Sıfır Reklam Deneyimi" />
          <BenefitItem icon={<Heart className="text-[#F44336]" size={20} />} text="Derin Uyum Analizleri (Kilit Yok)" />
          <BenefitItem icon={<Zap className="text-[#D4AF37]" size={20} />} text="Sınırsız Günlük Ek Analizler" />
          <BenefitItem icon={<Star className="text-[#7B1FA2]" size={20} />} text="Yarınki Kaderine Erken Erişim" />
        </div>

        {/* Pricing Tiers */}
        <div className="w-full space-y-4">
          <PricingCard title="HAFTALIK" price="₺49.99" desc="Kısa bir kozmik yolculuk." />
          <PricingCard title="AYLIK" price="₺129.99" desc="Popüler Tercih" highlighted />
          <PricingCard title="ÖMÜR BOYU" price="₺899.99" desc="Yıldızlarla Ebedi Dostluk" />
        </div>

        <button 
          onClick={onPurchase}
          className="w-full bg-[#D4AF37] text-black py-6 rounded-[32px] font-black uppercase text-xs tracking-[4px] shadow-[0_20px_40px_rgba(212,175,55,0.3)] active-scale mt-10 mb-8"
        >
          Aboneliği Başlat
        </button>

        <div className="flex flex-col gap-4 text-center">
           <p className="text-[10px] text-white/20 font-bold uppercase tracking-widest">Abonelik Her Zaman İptal Edilebilir</p>
           <div className="flex gap-4 justify-center text-[9px] font-black text-white/30 uppercase tracking-widest">
             <button>Hükümler</button>
             <button>Gizlilik</button>
             <button onClick={onPurchase}>Satın Alımı Geri Yükle</button>
           </div>
        </div>
      </div>
    </div>
  );
};

const BenefitItem = ({ icon, text }: { icon: any, text: string }) => (
  <div className="flex items-center gap-4 px-4 py-3 bg-white/5 rounded-2xl border border-white/5">
    <div className="shrink-0">{icon}</div>
    <span className="text-sm font-bold text-white/70">{text}</span>
    <Check size={16} className="text-[#4CAF50] ml-auto" />
  </div>
);

const PricingCard = ({ title, price, desc, highlighted = false }: { title: string, price: string, desc: string, highlighted?: boolean }) => (
  <button className={`w-full p-6 rounded-[32px] flex items-center justify-between border active-scale transition-all ${
    highlighted 
      ? 'bg-[#12081f] border-[#D4AF37] shadow-[0_0_30px_rgba(212,175,55,0.1)]' 
      : 'bg-white/5 border-white/10'
  }`}>
    <div className="text-left">
      <span className={`block text-[10px] font-black tracking-[2px] mb-1 ${highlighted ? 'text-[#D4AF37]' : 'text-white/40'}`}>
        {title}
      </span>
      <span className="block text-2xl font-black text-white font-montserrat">{price}</span>
      <span className="block text-[9px] font-bold text-white/30 uppercase tracking-widest mt-1">{desc}</span>
    </div>
    {highlighted && (
      <div className="bg-[#D4AF37] p-2 rounded-full">
         <Check size={16} className="text-black" />
      </div>
    )}
  </button>
);

export default PremiumView;
