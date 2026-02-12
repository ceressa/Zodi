
import React, { useState } from 'react';
import { ZodiacSign, CompatibilityResult } from '../types';
import { ALL_ZODIAC_SIGNS, ZODIAC_DATA } from '../constants';
import { fetchCompatibility } from '../geminiService';
import { Heart, Zap, ShieldCheck, RefreshCw, ChevronDown, Lock, Sparkles, Eye, X } from 'lucide-react';
import AdBanner from '../components/AdBanner';

interface MatchViewProps {
  userZodiac: ZodiacSign;
  isPremium: boolean;
}

const MatchView: React.FC<MatchViewProps> = ({ userZodiac, isPremium }) => {
  const [partnerZodiac, setPartnerZodiac] = useState<ZodiacSign | null>(null);
  const [result, setResult] = useState<CompatibilityResult | null>(null);
  const [loading, setLoading] = useState(false);
  const [showPicker, setShowPicker] = useState(false);
  const [isSummaryUnlocked, setIsSummaryUnlocked] = useState(false);
  const [adLoading, setAdLoading] = useState(false);

  const handleMatch = async (sign: ZodiacSign) => {
    setPartnerZodiac(sign);
    setShowPicker(false);
    setIsSummaryUnlocked(false);
    setLoading(true);
    try {
      const data = await fetchCompatibility(userZodiac, sign);
      setResult(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const unlockSummary = () => {
    if (isPremium) {
      setIsSummaryUnlocked(true);
      return;
    }
    setAdLoading(true);
    setTimeout(() => {
      setAdLoading(false);
      setIsSummaryUnlocked(true);
    }, 5000);
  };

  if (adLoading) {
    return (
      <div className="fixed inset-0 bg-black/95 z-[300] flex flex-col items-center justify-center p-8 text-center animate-fadeIn">
        <div className="w-20 h-20 rounded-full border-4 border-[#D4AF37]/20 border-t-[#D4AF37] animate-spin mb-8" />
        <h3 className="text-xl font-black text-white uppercase tracking-widest mb-2">Kozmik Sırlar Çözülüyor</h3>
        <p className="text-white/40 text-sm italic">"Yıldızların fısıltısı biraz zaman alır..."</p>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-8 animate-fadeIn pb-12">
      <div className="text-center space-y-3">
        <h2 className="text-3xl font-black gold-text font-montserrat tracking-tight uppercase">Kozmik Uyum</h2>
        <p className="text-[var(--text-muted)] text-[10px] font-bold tracking-[4px] uppercase">Ruh Eşini Yıldızlarda Ara</p>
      </div>

      {/* Comparison Head */}
      <div className="flex items-center justify-around py-10 relative">
        <div className="absolute left-1/2 top-1/2 -translate-x-1/2 -translate-y-1/2 z-10">
          <div className="w-14 h-14 bg-[var(--accent)]/20 rounded-full flex items-center justify-center border border-[var(--accent)]/30 animate-pulse shadow-[0_0_20px_rgba(123,31,162,0.3)]">
            <Zap size={28} className="text-[var(--gold)]" fill="currentColor" />
          </div>
        </div>

        <div className="flex flex-col items-center gap-4 group">
          <div className="w-24 h-24 glass-card rounded-[40px] flex items-center justify-center text-[var(--secondary)] shadow-2xl border-[var(--secondary)]/20 transform transition-transform group-hover:scale-110">
            {React.cloneElement(ZODIAC_DATA[userZodiac].icon as React.ReactElement, { size: 48 })}
          </div>
          <span className="text-xs font-black text-[var(--text)] uppercase tracking-widest opacity-60">{userZodiac}</span>
        </div>

        <div className="flex flex-col items-center gap-4">
          <button 
            onClick={() => setShowPicker(true)}
            className={`w-24 h-24 rounded-[40px] flex items-center justify-center transition-all duration-500 shadow-2xl relative group overflow-hidden ${
              partnerZodiac ? 'glass-card text-[var(--accent)] border-[var(--accent)]/30' : 'bg-[var(--text-muted)]/5 border-2 border-dashed border-[var(--text-muted)]/20 text-[var(--text-muted)] hover:border-[var(--secondary)]/40'
            }`}
          >
            {partnerZodiac ? (
              <>
                <div className="absolute inset-0 bg-gradient-to-br from-[var(--accent)]/5 to-transparent animate-pulse" />
                {React.cloneElement(ZODIAC_DATA[partnerZodiac].icon as React.ReactElement, { size: 48, className: "relative z-10 animate-fadeIn" })}
              </>
            ) : (
              <div className="flex flex-col items-center gap-2 animate-bounce">
                <ChevronDown size={32} />
              </div>
            )}
          </button>
          <span className="text-xs font-black text-[var(--text)] uppercase tracking-widest opacity-60">
            {partnerZodiac || 'EŞ SEÇ'}
          </span>
        </div>
      </div>

      {showPicker && (
        <div className="fixed inset-0 z-[200] bg-black/80 backdrop-blur-xl flex items-center justify-center p-6 animate-fadeIn">
          <div className="glass-card w-full max-w-sm rounded-[48px] p-8 border-[var(--border)] relative shadow-[0_32px_64px_rgba(0,0,0,0.5)]">
            <button 
              onClick={() => setShowPicker(false)}
              className="absolute top-6 right-6 text-[var(--text-muted)] hover:text-[var(--text)] p-2"
            >
              <X size={24} />
            </button>
            <h3 className="text-xl font-black text-center mb-8 uppercase tracking-widest text-[var(--text)]">Ruh Eşini Seç</h3>
            <div className="grid grid-cols-3 gap-4">
              {ALL_ZODIAC_SIGNS.map(sign => (
                <button 
                  key={sign}
                  onClick={() => handleMatch(sign)}
                  className="flex flex-col items-center gap-2 p-3 rounded-2xl hover:bg-white/5 transition-all active:scale-90"
                >
                  <div className="text-[var(--accent)]">
                    {React.cloneElement(ZODIAC_DATA[sign].icon as React.ReactElement, { size: 28 })}
                  </div>
                  <span className="text-[10px] font-black text-[var(--text-muted)] uppercase">{sign}</span>
                </button>
              ))}
            </div>
          </div>
        </div>
      )}

      {loading ? (
        <div className="flex flex-col items-center justify-center py-20 gap-6">
          <div className="relative">
            <RefreshCw className="animate-spin text-[var(--secondary)]" size={48} />
            <div className="absolute inset-0 bg-[var(--secondary)]/20 blur-2xl rounded-full" />
          </div>
          <p className="text-[11px] font-black tracking-[5px] uppercase gold-text animate-pulse text-center">Yıldız Haritaları <br/> Karşılaştırılıyor...</p>
        </div>
      ) : result ? (
        <div className="space-y-10 animate-slideUp">
          <div className="glass-card rounded-[48px] p-10 text-center relative overflow-hidden shadow-2xl border-[var(--border)]">
            <div className="absolute top-0 left-0 w-full h-1 bg-gradient-to-r from-transparent via-[var(--accent)] to-transparent opacity-30" />
            <span className="text-8xl font-black gold-text font-montserrat tracking-tighter">%{result.score}</span>
            <p className="text-[11px] font-black text-[var(--text-muted)] uppercase tracking-[6px] mt-6">Kozmik Sinerji</p>
          </div>

          {!isPremium && <AdBanner type="banner" />}

          {/* Detailed Reports for Each Aspect */}
          <div className="space-y-8">
            <AspectCard 
              label="Aşk Uyumu" 
              value={result.aspects.love} 
              icon={<Heart size={20} />} 
              color="#E91E63" 
            />
            <AspectCard 
              label="İletişim Gücü" 
              value={result.aspects.communication} 
              icon={<Zap size={20} />} 
              color="#4FC3F7" 
            />
            <AspectCard 
              label="Güven Bağı" 
              value={result.aspects.trust} 
              icon={<ShieldCheck size={20} />} 
              color="#4CAF50" 
            />
          </div>

          <div className="relative pt-4">
            <div className={`glass-card rounded-[40px] p-10 transition-all duration-700 border-[var(--border)] ${!isSummaryUnlocked && !isPremium ? 'blur-md grayscale pointer-events-none opacity-50 scale-95' : ''}`}>
              <div className="flex items-center gap-3 mb-6">
                <Sparkles size={16} className="text-[var(--gold)]" />
                <h3 className="text-xs font-black text-[var(--secondary)] uppercase tracking-[4px]">Zodi'nin Son Sözü</h3>
              </div>
              <p className="text-xl leading-relaxed text-[var(--text)] italic font-lato opacity-90">"{result.summary}"</p>
            </div>

            {!isSummaryUnlocked && !isPremium && (
              <div className="absolute inset-0 flex flex-col items-center justify-center z-20">
                <div className="bg-[var(--text)] p-8 rounded-[40px] shadow-[0_32px_64px_rgba(0,0,0,0.4)] text-center max-w-[300px] border-4 border-white">
                  <div className="w-16 h-16 bg-[var(--bg)] rounded-full flex items-center justify-center mx-auto mb-4 border border-[var(--gold)]/20 shadow-inner">
                    <Lock size={28} className="text-[var(--gold)]" />
                  </div>
                  <h4 className="text-[var(--bg)] font-black text-base uppercase tracking-widest mb-2">Gizli Rapor</h4>
                  <p className="text-[var(--bg)] opacity-60 text-[11px] mb-8 leading-relaxed font-bold">Zodi'nin en derin ve belki de en acımasız yorumunu duymaya hazır mısın?</p>
                  <button 
                    onClick={unlockSummary}
                    className="w-full bg-[var(--gold)] text-[var(--bg)] py-5 rounded-2xl font-black uppercase text-xs tracking-[2px] active-scale flex items-center justify-center gap-3 shadow-[0_10px_30px_rgba(166,124,0,0.3)]"
                  >
                    <Eye size={18} />
                    Reklam İzle & Oku
                  </button>
                </div>
              </div>
            )}
          </div>
        </div>
      ) : !showPicker && (
        <div className="text-center py-24 opacity-20 text-[var(--text)] flex flex-col items-center gap-6">
          <div className="w-20 h-20 rounded-full border-2 border-dashed border-[var(--text-muted)] flex items-center justify-center animate-pulse">
            <Heart size={40} />
          </div>
          <p className="text-sm font-bold uppercase tracking-[4px] leading-relaxed">Senin yıldızın kiminle <br/> aynı frekansta?</p>
        </div>
      )}
    </div>
  );
};

const AspectCard = ({ label, value, icon, color }: { label: string, value: number, icon: any, color: string }) => (
  <div className="space-y-3">
    <div className="flex items-center justify-between px-4">
      <div className="flex items-center gap-2">
        <div style={{ color }} className="opacity-80">{icon}</div>
        <span className="text-[10px] font-black text-[var(--text-muted)] uppercase tracking-[3px]">Yıldızların Raporu</span>
      </div>
      <span className="text-sm font-black text-[var(--text)]" style={{ color }}>%{value} {label}</span>
    </div>
    <div className="glass-card p-2 rounded-[32px] overflow-hidden border-[var(--border)]">
      <div className="h-4 bg-black/5 rounded-[24px] overflow-hidden">
        <div 
          className="h-full transition-all duration-1000 ease-out rounded-[24px] shadow-[0_0_15px_rgba(0,0,0,0.1)]"
          style={{ width: `${value}%`, backgroundColor: color }}
        />
      </div>
    </div>
  </div>
);

const MatchMetric = ({ label, value, icon }: { label: string, value: number, icon: any }) => (
    <div className="glass-card p-4 rounded-[28px] flex flex-col items-center gap-2 shadow-md border-[var(--border)]">
        <div className="text-[var(--gold)]">{icon}</div>
        <span className="text-xl font-black text-[var(--text)]">%{value}</span>
        <span className="text-[8px] font-bold text-[var(--text-muted)] uppercase tracking-widest">{label}</span>
    </div>
);

export default MatchView;
