
import React, { useState } from 'react';
import { Sparkles, Moon, ChevronRight, User, Mail, Star } from 'lucide-react';

interface AuthViewProps {
  onLogin: (name: string, email: string) => void;
}

const AuthView: React.FC<AuthViewProps> = ({ onLogin }) => {
  const [name, setName] = useState('');
  const [email, setEmail] = useState('');

  const handleGoogleLogin = () => {
    // Simulate google login
    onLogin("Deniz Yıldız", "deniz.yildiz@gmail.com");
  };

  const handleManualLogin = (e: React.FormEvent) => {
    e.preventDefault();
    if (name.trim() && email.trim()) {
      onLogin(name, email);
    }
  };

  return (
    <div className="fixed inset-0 bg-[#050209] z-[150] flex flex-col items-center justify-center p-8 overflow-hidden">
      {/* Background Decor */}
      <div className="absolute inset-0 pointer-events-none">
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[600px] h-[600px] bg-[#7B1FA2]/10 blur-[150px] rounded-full" />
        <div className="absolute top-[10%] right-[10%] w-40 h-40 bg-[#4FC3F7]/10 blur-[80px] rounded-full animate-pulse" />
      </div>

      <div className="relative z-10 w-full max-w-sm flex flex-col gap-8">
        <div className="text-center space-y-2">
          <div className="relative w-20 h-20 mx-auto mb-6">
            <div className="absolute inset-0 bg-gradient-to-tr from-[#7B1FA2] to-[#4FC3F7] rounded-[24px] rotate-12 opacity-20 animate-pulse"></div>
            <div className="w-full h-full bg-white/5 rounded-[24px] flex items-center justify-center border border-white/10 shadow-2xl relative z-10">
              <Star size={32} className="text-[#D4AF37]" fill="currentColor" />
            </div>
          </div>
          <h1 className="text-4xl font-black logo-font gold-text tracking-tighter">KOZMİK KAYIT</h1>
          <p className="text-white/40 text-sm font-medium">Kaderini keşfetmek için ilk adımı at.</p>
        </div>

        <form onSubmit={handleManualLogin} className="space-y-4">
          <div className="relative group">
            <div className="absolute left-6 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#4FC3F7] transition-colors">
              <User size={18} />
            </div>
            <input 
              type="text" 
              placeholder="Adın Soyadın" 
              value={name}
              required
              onChange={(e) => setName(e.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-[24px] py-5 pl-14 pr-6 text-white font-bold placeholder:text-white/10 focus:outline-none focus:border-[#4FC3F7]/50 focus:bg-white/10 transition-all"
            />
          </div>

          <div className="relative group">
            <div className="absolute left-6 top-1/2 -translate-y-1/2 text-white/20 group-focus-within:text-[#4FC3F7] transition-colors">
              <Mail size={18} />
            </div>
            <input 
              type="email" 
              placeholder="E-posta Adresin" 
              value={email}
              required
              onChange={(e) => setEmail(e.target.value)}
              className="w-full bg-white/5 border border-white/10 rounded-[24px] py-5 pl-14 pr-6 text-white font-bold placeholder:text-white/10 focus:outline-none focus:border-[#4FC3F7]/50 focus:bg-white/10 transition-all"
            />
          </div>

          <button 
            type="submit"
            disabled={!name.trim() || !email.trim()}
            className="w-full bg-[#7B1FA2] text-white py-5 rounded-[24px] font-black uppercase text-xs tracking-[4px] shadow-[0_15px_30px_rgba(123,31,162,0.3)] active-scale disabled:opacity-30 flex items-center justify-center gap-3"
          >
            Yıldızlara Bağlan
            <ChevronRight size={18} />
          </button>
        </form>

        <div className="relative flex items-center gap-4 py-2">
           <div className="flex-1 h-[1px] bg-white/5"></div>
           <span className="text-[10px] font-bold text-white/10 uppercase tracking-widest">VEYA</span>
           <div className="flex-1 h-[1px] bg-white/5"></div>
        </div>

        <button 
          onClick={handleGoogleLogin}
          className="w-full bg-white text-black py-5 rounded-[24px] font-black uppercase text-xs tracking-[4px] active-scale flex items-center justify-center gap-4 border border-white/10 shadow-xl"
        >
          <svg className="w-5 h-5" viewBox="0 0 24 24">
            <path fill="#4285F4" d="M22.56 12.25c0-.78-.07-1.53-.2-2.25H12v4.26h5.92c-.26 1.37-1.04 2.53-2.21 3.31v2.77h3.57c2.08-1.92 3.28-4.74 3.28-8.09z"/>
            <path fill="#34A853" d="M12 23c2.97 0 5.46-.98 7.28-2.66l-3.57-2.77c-.98.66-2.23 1.06-3.71 1.06-2.86 0-5.29-1.93-6.16-4.53H2.18v2.84C3.99 20.53 7.7 23 12 23z"/>
            <path fill="#FBBC05" d="M5.84 14.09c-.22-.66-.35-1.36-.35-2.09s.13-1.43.35-2.09V7.07H2.18C1.43 8.55 1 10.22 1 12s.43 3.45 1.18 4.93l3.66-2.84z"/>
            <path fill="#EA4335" d="M12 5.38c1.62 0 3.06.56 4.21 1.64l3.15-3.15C17.45 2.09 14.97 1 12 1 7.7 1 3.99 3.47 2.18 7.07l3.66 2.84c.87-2.6 3.3-4.53 6.16-4.53z"/>
          </svg>
          Google ile Giriş
        </button>

        <p className="text-center text-[9px] text-white/10 font-bold uppercase tracking-[2px] mt-8 max-w-[200px] mx-auto leading-relaxed">
          Kayıt olarak Yıldızların Hükümlerini ve Gizlilik Şartlarını kabul etmiş sayılırsın.
        </p>
      </div>
    </div>
  );
};

export default AuthView;
