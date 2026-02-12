
import React from 'react';
import { DailyHoroscope, ZodiacSign } from '../types';
import ProgressBar from '../components/ProgressBar';
import AdBanner from '../components/AdBanner';
import { Sparkles, Star, Palette, Hash, Quote } from 'lucide-react';

interface DailyViewProps {
  zodiac: ZodiacSign;
  data: DailyHoroscope | null;
  loading: boolean;
  onRefresh: () => void;
  isPremium: boolean;
}

const DailyView: React.FC<DailyViewProps> = ({ zodiac, data, loading, onRefresh, isPremium }) => {
  if (loading) {
    return (
      <div className="flex flex-col items-center justify-center py-32 gap-6 text-center animate-pulse">
        <div className="w-16 h-16 glass-card rounded-[32px] flex items-center justify-center border-[#7B1FA2]/30">
            <Sparkles size={28} className="text-[var(--secondary)] animate-spin" />
        </div>
        <div className="space-y-2">
            <p className="text-sm font-black font-montserrat gold-text uppercase tracking-[4px]">Yıldızlar Okunuyor...</p>
            <p className="text-[10px] text-[var(--text-muted)] font-bold uppercase tracking-widest">Kozmik Bağlantı</p>
        </div>
      </div>
    );
  }

  if (!data) return null;

  return (
    <div className="flex flex-col gap-8 animate-fadeIn">
      {/* Motto Card */}
      <div className="relative glass-card rounded-[40px] p-8 overflow-hidden border border-[var(--border)] shadow-xl">
        <div className="absolute top-0 right-0 w-32 h-32 bg-[#D4AF37]/5 blur-[40px] rounded-full translate-x-10 -translate-y-10" />
        <div className="flex justify-center mb-4">
            <Quote size={24} className="text-[#D4AF37]/40" />
        </div>
        <h2 className="text-2xl font-black text-center text-[var(--text)] font-montserrat leading-tight italic tracking-tight">
          {data.motto}
        </h2>
        <div className="flex items-center justify-center gap-3 mt-8">
            <div className="h-[1px] flex-1 bg-gradient-to-r from-transparent to-[var(--text-muted)] opacity-20" />
            <Star size={12} className="text-[#D4AF37]" fill="currentColor" />
            <div className="h-[1px] flex-1 bg-gradient-to-l from-transparent to-[var(--text-muted)] opacity-20" />
        </div>
      </div>

      {!isPremium && <AdBanner type="rewarded-ui" label="Yarınki Kaderini Hemen Gör" />}

      {/* Main Commentary Card */}
      <div className="glass-card rounded-[40px] p-8 border border-[var(--border)] relative shadow-lg">
        <div className="text-[10px] font-black text-[#D4AF37] uppercase tracking-[4px] mb-6 flex items-center gap-3">
            <span className="w-8 h-[1.5px] bg-[#D4AF37]/30" />
            Zodi'nin Kehaneti
        </div>
        <p className="leading-relaxed font-lato text-lg text-[var(--text)] first-letter:text-6xl first-letter:font-black first-letter:gold-text first-letter:mr-3 first-letter:float-left first-letter:leading-none">
          {data.commentary}
        </p>
      </div>

      {!isPremium && <AdBanner type="native" />}

      {/* Metrics Section */}
      <div className="space-y-5">
        <div className="flex items-center gap-3 px-2">
           <div className="w-1.5 h-1.5 bg-[var(--secondary)] rounded-full shadow-[0_0_8px_var(--secondary)] animate-pulse" />
           <h3 className="text-[10px] font-black text-[var(--text-muted)] uppercase tracking-[4px]">Enerji Boyutların</h3>
        </div>
        <div className="grid grid-cols-2 gap-4">
          <ProgressBar label="Aşk" value={data.love} />
          <ProgressBar label="Finans" value={data.money} />
          <ProgressBar label="Hücre" value={data.health} />
          <ProgressBar label="Kariyer" value={data.career} />
        </div>
      </div>

      {!isPremium && <AdBanner type="banner" />}

      {/* Lucky Tokens */}
      <div className="grid grid-cols-2 gap-4">
        <div className="glass-card p-6 rounded-[40px] flex flex-col gap-4 border border-[var(--border)] active-scale shadow-md overflow-hidden relative">
          <div className="w-12 h-12 bg-white/5 rounded-xl flex items-center justify-center text-[var(--secondary)] border border-white/10">
            <Palette size={24} />
          </div>
          <div className="space-y-1">
            <span className="block text-[10px] text-[var(--text-muted)] font-bold uppercase tracking-widest">Kozmik Renk</span>
            <span className="text-base font-black text-[var(--text)] font-montserrat uppercase tracking-tight">{data.luckyColor}</span>
          </div>
        </div>
        <div className="glass-card p-6 rounded-[40px] flex flex-col gap-4 border border-[var(--border)] active-scale shadow-md overflow-hidden relative">
          <div className="w-12 h-12 bg-white/5 rounded-xl flex items-center justify-center text-[#7B1FA2] border border-white/10">
            <Hash size={24} />
          </div>
          <div className="space-y-1">
            <span className="block text-[10px] text-[var(--text-muted)] font-bold uppercase tracking-widest">Şanslı Sayı</span>
            <span className="text-2xl font-black text-[var(--text)] font-montserrat">{data.luckyNumber}</span>
          </div>
        </div>
      </div>
    </div>
  );
};

export default DailyView;
