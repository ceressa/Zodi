
import React from 'react';
import { 
  Bell, 
  ShieldCheck, 
  Info, 
  RefreshCcw, 
  ChevronRight, 
  Share2,
  Crown,
  Star,
  Moon,
  Sun
} from 'lucide-react';

interface SettingsViewProps {
  onSignReset: () => void;
  onGoPremium: () => void;
  isPremium: boolean;
  theme: 'dark' | 'light';
  onToggleTheme: () => void;
}

const SettingsView: React.FC<SettingsViewProps> = ({ onSignReset, onGoPremium, isPremium, theme, onToggleTheme }) => {
  return (
    <div className="flex flex-col gap-8 pb-10">
      
      {/* Premium Upgrade Banner */}
      {!isPremium ? (
        <button 
          onClick={onGoPremium}
          className="relative overflow-hidden group p-1 rounded-[40px] bg-gradient-to-tr from-[#D4AF37] via-[#F9D976] to-[#D4AF37] shadow-[0_20px_40px_rgba(212,175,55,0.2)] active-scale mt-4"
        >
          <div className="bg-[var(--card)] rounded-[36px] p-8 flex items-center gap-6 relative overflow-hidden">
             <div className="absolute top-0 right-0 p-4 opacity-5 group-hover:scale-150 transition-transform duration-1000">
               <Crown size={120} />
             </div>
             <div className="w-16 h-16 rounded-[28px] bg-[#D4AF37]/10 flex items-center justify-center text-[#D4AF37] border border-[#D4AF37]/20">
               <Crown size={32} />
             </div>
             <div className="text-left flex-1">
               <h4 className="text-xl font-black text-[var(--text)] font-montserrat leading-tight uppercase">PREMIUM <br /><span className="gold-text">AYRICALIĞI</span></h4>
               <p className="text-[10px] text-[var(--text-muted)] font-bold uppercase tracking-widest mt-2">Kısıtlamaları Kaldır</p>
             </div>
             <ChevronRight size={20} className="text-[#D4AF37]" />
          </div>
        </button>
      ) : (
        <div className="glass-card p-8 rounded-[40px] border-[#D4AF37]/30 flex items-center gap-6 mt-4 relative overflow-hidden">
           <div className="absolute top-0 right-0 w-24 h-24 bg-[#D4AF37]/10 blur-3xl rounded-full" />
           <div className="w-14 h-14 bg-[#D4AF37] rounded-[24px] flex items-center justify-center text-black">
             <Star size={32} fill="currentColor" />
           </div>
           <div>
             <h4 className="text-lg font-black text-[var(--text)] font-montserrat">SÜPERNOVA ÜYE</h4>
             <p className="text-[10px] text-[#D4AF37] font-bold uppercase tracking-widest mt-1 italic">Kaderin Tam Kontrolünde</p>
           </div>
        </div>
      )}

      <div className="space-y-4">
        <h3 className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-[4px] px-2">Görünüm</h3>
        <button 
          onClick={onToggleTheme}
          className="w-full glass-card p-6 rounded-[32px] flex items-center justify-between active-scale transition-colors group border-white/5"
        >
          <div className="flex items-center gap-5">
            <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-[var(--secondary)]">
              {theme === 'dark' ? <Moon size={22} /> : <Sun size={22} />}
            </div>
            <div className="text-left">
              <span className="block font-bold text-[var(--text)]">{theme === 'dark' ? 'Karanlık Mod' : 'Aydınlık Mod'}</span>
              <span className="block text-[10px] text-[var(--text-muted)]">Enerjini gözlerine uyarla.</span>
            </div>
          </div>
          <div className={`w-12 h-6 rounded-full relative transition-colors ${theme === 'light' ? 'bg-[#D4AF37]' : 'bg-white/10'}`}>
            <div className={`absolute top-1 w-4 h-4 rounded-full bg-white transition-all ${theme === 'light' ? 'left-7' : 'left-1'}`} />
          </div>
        </button>
      </div>

      <div className="space-y-4">
        <h3 className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-[4px] px-2">Kader Ayarları</h3>
        
        <button 
          onClick={onSignReset}
          className="w-full glass-card p-6 rounded-[32px] flex items-center justify-between active-scale transition-colors group border-white/5"
        >
          <div className="flex items-center gap-5">
            <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-[var(--secondary)]">
              <RefreshCcw size={22} />
            </div>
            <div className="text-left">
              <span className="block font-bold text-[var(--text)]">Burcumu Değiştir</span>
              <span className="block text-[10px] text-[var(--text-muted)]">Kaderini yeniden çiz.</span>
            </div>
          </div>
          <ChevronRight size={20} className="text-[var(--text-muted)] group-hover:translate-x-1 transition-transform" />
        </button>
      </div>

      <div className="space-y-4">
        <h3 className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-[4px] px-2">Tercihler</h3>
        <SettingsItem icon={<Bell size={20} />} label="Bildirimler" />
        <SettingsItem icon={<Share2 size={20} />} label="Arkadaşlarınla Paylaş" />
      </div>

      <div className="space-y-4">
        <h3 className="text-xs font-bold text-[var(--text-muted)] uppercase tracking-[4px] px-2">Zodi Hakkında</h3>
        <SettingsItem icon={<ShieldCheck size={20} />} label="Gizlilik Politikası" />
        <SettingsItem icon={<Info size={20} />} label="Destek & İletişim" />
      </div>

      <div className="mt-8 text-center space-y-2 opacity-30">
        <p className="text-[9px] font-bold text-[var(--text)] uppercase tracking-[3px]">ZODI PREMIUM v2.0</p>
      </div>
    </div>
  );
};

const SettingsItem: React.FC<{ icon: React.ReactNode; label: string }> = ({ icon, label }) => (
  <button className="w-full glass-card p-6 rounded-[32px] flex items-center justify-between active-scale transition-colors group border-white/5">
    <div className="flex items-center gap-5">
      <div className="w-12 h-12 rounded-2xl bg-white/5 flex items-center justify-center text-[var(--text)] opacity-60">
        {icon}
      </div>
      <span className="font-bold text-[var(--text)]">{label}</span>
    </div>
    <ChevronRight size={20} className="text-[var(--text-muted)] group-hover:translate-x-1 transition-transform" />
  </button>
);

export default SettingsView;
