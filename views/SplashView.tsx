
import React, { useEffect, useState } from 'react';
import { Sparkles, Star } from 'lucide-react';

const SplashView: React.FC = () => {
  const [show, setShow] = useState(false);

  useEffect(() => {
    setShow(true);
  }, []);

  return (
    <div className="fixed inset-0 bg-[#070310] flex flex-col items-center justify-center z-[200]">
      {/* Dynamic Stars */}
      <div className="absolute inset-0 overflow-hidden">
        {[...Array(30)].map((_, i) => (
          <div
            key={i}
            className="absolute bg-white rounded-full opacity-10 animate-pulse"
            style={{
              top: `${Math.random() * 100}%`,
              left: `${Math.random() * 100}%`,
              width: `${Math.random() * 2}px`,
              height: `${Math.random() * 2}px`,
              animationDelay: `${Math.random() * 2}s`
            }}
          />
        ))}
      </div>

      <div className={`transition-all duration-1000 ease-out transform flex flex-col items-center gap-8 ${show ? 'scale-100 opacity-100' : 'scale-90 opacity-0'}`}>
        <div className="relative">
          {/* Pulsing Aura */}
          <div className="absolute inset-[-20px] bg-gradient-to-tr from-[#7B1FA2] to-[#4FC3F7] rounded-full blur-[40px] opacity-20 animate-pulse" />
          
          <div className="relative w-24 h-24 glass rounded-[40px] flex items-center justify-center text-white border-white/10 shadow-2xl">
            <Sparkles size={48} className="animate-bounce" />
          </div>
        </div>

        <div className="text-center space-y-4">
          <h1 className="text-5xl font-bold font-montserrat tracking-[12px] text-white">ZODI</h1>
          <div className="flex items-center gap-3 justify-center text-[#4FC3F7]/50">
            <div className="h-[1px] w-8 bg-current" />
            <span className="text-[10px] font-bold uppercase tracking-[4px]">Hizalanıyor</span>
            <div className="h-[1px] w-8 bg-current" />
          </div>
        </div>
      </div>

      <div className="absolute bottom-12 flex items-center gap-2 text-[#C5CAE9]/20 font-bold uppercase tracking-[2px] text-[10px]">
        <Star size={10} fill="currentColor" />
        <span>Astra Engine</span>
      </div>
    </div>
  );
};

export default SplashView;
