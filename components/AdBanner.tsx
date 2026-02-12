
import React from 'react';
import { ExternalLink, Shield, Gift, Sparkles, Play, ChevronRight } from 'lucide-react';

interface AdBannerProps {
  type?: 'native' | 'banner' | 'rewarded-ui';
  onAction?: () => void;
  label?: string;
}

const AdBanner: React.FC<AdBannerProps> = ({ type = 'native', onAction, label }) => {
  if (type === 'rewarded-ui') {
    return (
      <div className="p-1 glass-card rounded-[36px] border border-[#D4AF37]/30 shadow-[0_0_40px_rgba(212,175,55,0.1)]">
          <button 
            onClick={onAction}
            className="w-full bg-[#D4AF37] text-black active-scale py-5 rounded-[32px] font-black uppercase text-[11px] tracking-[2px] flex items-center justify-center gap-3 shadow-[0_10px_30px_rgba(212,175,55,0.3)] rewarded-btn group"
          >
            <div className="bg-black/10 p-2 rounded-full group-hover:rotate-12 transition-transform">
                <Play size={16} fill="black" />
            </div>
            {label || 'Hemen İzle & Kilidi Aç'}
            <ChevronRight size={16} />
          </button>
      </div>
    );
  }

  if (type === 'banner') {
    return (
      <div className="w-full h-24 bg-gradient-to-r from-[#1A1A1A] to-[#252525] rounded-3xl flex items-center px-5 gap-4 border border-white/5 relative overflow-hidden active-scale shadow-xl group">
        <div className="absolute top-0 right-0 p-1.5 bg-black/60 text-[8px] font-bold text-white/30 rounded-bl-xl border-l border-b border-white/5">AD</div>
        <div className="w-14 h-14 rounded-2xl bg-white/5 flex items-center justify-center text-[#D4AF37] border border-white/5 group-hover:scale-110 transition-transform">
          <Gift size={28} />
        </div>
        <div className="flex-1 min-w-0">
          <p className="text-sm font-black text-white uppercase tracking-tight truncate">Şans Paketi</p>
          <p className="text-[11px] text-white/40 leading-tight mt-1">Bugüne özel teklifi kaçırma.</p>
        </div>
        <button className="px-5 py-2.5 bg-[#4FC3F7] rounded-xl text-[10px] font-black uppercase text-black shadow-lg">FIRSAT</button>
        <div className="absolute inset-0 shimmer pointer-events-none opacity-10" />
      </div>
    );
  }

  return (
    <div className="w-full bg-[#12081f] rounded-[40px] p-6 flex items-center gap-5 border border-white/5 relative overflow-hidden active-scale shadow-2xl">
      <div className="absolute top-4 right-4 bg-black/40 px-2 py-0.5 rounded text-[8px] font-bold text-white/30 uppercase tracking-[2px] border border-white/5">
        SPONSORLU
      </div>
      <div className="w-16 h-16 bg-gradient-to-br from-[#7B1FA2] to-[#4FC3F7] rounded-3xl flex items-center justify-center shrink-0 shadow-[0_0_30px_rgba(123,31,162,0.3)] border border-white/10">
        <Shield size={36} className="text-white" />
      </div>
      <div className="flex-1 min-w-0">
        <h4 className="text-lg font-black text-white font-montserrat uppercase tracking-tight">Kozmik Kalkan</h4>
        <p className="text-xs text-white/50 leading-snug mt-1 italic">Merkür retrosuna karşı tam koruma paketi yayında.</p>
      </div>
      <div className="w-10 h-10 bg-white/5 rounded-full flex items-center justify-center text-[#4FC3F7] border border-white/10">
        <ExternalLink size={18} />
      </div>
      <div className="absolute inset-0 shimmer pointer-events-none opacity-10" />
    </div>
  );
};

export default AdBanner;
