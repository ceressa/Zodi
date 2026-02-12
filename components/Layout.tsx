
import React from 'react';
import { AppView, ZodiacSign } from '../types';
import { 
  Sparkles, 
  Crown, 
  Zap, 
  Target,
  User,
  Star
} from 'lucide-react';
import { ZODIAC_DATA } from '../constants';

interface LayoutProps {
  children: React.ReactNode;
  activeView: AppView;
  setView: (view: AppView) => void;
  selectedZodiac: ZodiacSign | null;
}

const Logo = () => (
  <div className="flex items-center gap-1.5 select-none">
    <div className="relative flex items-center justify-center w-8 h-8">
      <div className="absolute inset-0 bg-gradient-to-tr from-[#7B1FA2] to-[#4FC3F7] rounded-lg rotate-12 opacity-20"></div>
      <Star size={18} className="text-[#D4AF37] relative z-10" fill="currentColor" />
    </div>
    <div className="flex flex-col leading-none">
      <span className="text-xl font-black logo-font tracking-[-0.08em] text-[var(--text)] flex items-center">
        Z<span className="gold-text">O</span>DI
      </span>
      <span className="text-[7px] font-black uppercase tracking-[0.4em] opacity-30 text-[var(--text)] ml-0.5">Premium</span>
    </div>
  </div>
);

const Layout: React.FC<LayoutProps> = ({ children, activeView, setView, selectedZodiac }) => {
  return (
    <div className="flex flex-col h-full w-full bg-[var(--bg)] overflow-hidden transition-colors duration-400">
      {/* Header */}
      <header className="shrink-0 px-6 pt-12 pb-5 flex items-center justify-between z-[110] border-b border-[var(--border)] bg-[var(--header-bg)] transition-colors">
        <Logo />
        
        {selectedZodiac && (
          <button 
            onClick={() => setView(AppView.SETTINGS)}
            className="w-10 h-10 rounded-xl glass-card flex items-center justify-center active-scale shadow-sm"
          >
            {React.cloneElement(ZODIAC_DATA[selectedZodiac].icon as React.ReactElement, { size: 20, strokeWidth: 1.5, className: "text-[var(--text)]" })}
          </button>
        )}
      </header>

      {/* Main Content Area */}
      <main className="flex-1 overflow-y-auto no-scrollbar relative z-10">
        <div className="max-w-lg mx-auto w-full px-6 pt-6 pb-24">
          {children}
        </div>
        
        {/* Background Decorative Blurs */}
        <div className="absolute top-0 left-0 w-full h-full pointer-events-none overflow-hidden -z-10">
          <div className="absolute top-0 -left-24 w-96 h-96 bg-[#7B1FA2]/5 blur-[120px] rounded-full" />
          <div className="absolute bottom-0 -right-24 w-96 h-96 bg-[#4FC3F7]/5 blur-[120px] rounded-full" />
        </div>
      </main>

      {/* Bottom Navigation Area */}
      <footer className="shrink-0 border-t border-[var(--border)] pb-[env(safe-area-inset-bottom,16px)] pt-3 px-6 z-[120] bg-[var(--header-bg)] transition-colors shadow-2xl">
        <nav className="max-w-md mx-auto rounded-[24px] p-1 flex justify-around items-center border border-[var(--border)] bg-[var(--card)]">
          <NavItem 
            icon={<Sparkles size={18} />} 
            label="Günlük" 
            active={activeView === AppView.DAILY} 
            onClick={() => setView(AppView.DAILY)} 
          />
          <NavItem 
            icon={<Target size={18} />} 
            label="Analiz" 
            active={activeView === AppView.ANALYSIS} 
            onClick={() => setView(AppView.ANALYSIS)} 
          />
          <NavItem 
            icon={<Zap size={18} />} 
            label="Uyum" 
            active={activeView === AppView.MATCH} 
            onClick={() => setView(AppView.MATCH)} 
          />
          <NavItem 
            icon={<User size={18} />} 
            label="Profil" 
            active={activeView === AppView.SETTINGS} 
            onClick={() => setView(AppView.SETTINGS)} 
          />
        </nav>
      </footer>
    </div>
  );
};

const NavItem = ({ icon, label, active, onClick }: { icon: any, label: string, active: boolean, onClick: () => void }) => (
  <button 
    onClick={onClick}
    className={`flex-1 flex flex-col items-center gap-1 py-2 rounded-xl transition-all duration-300 relative active-scale ${active ? 'text-[var(--secondary)]' : 'text-[var(--text-muted)]'}`}
  >
    {active && (
      <div className="absolute -top-1 w-4 h-[2px] bg-[var(--secondary)] rounded-full shadow-[0_0_8px_var(--secondary)]" />
    )}
    <div className={`${active ? 'scale-110' : ''} transition-transform`}>
        {icon}
    </div>
    <span className={`text-[9px] font-bold uppercase tracking-widest leading-none ${active ? 'opacity-100' : 'opacity-60'}`}>{label}</span>
  </button>
);

export default Layout;
