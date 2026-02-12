
import React, { useState } from 'react';
import { ZodiacSign } from '../types';
import { ALL_ZODIAC_SIGNS, ZODIAC_DATA } from '../constants';
import { Sparkles, Stars, Moon, Sun, Star } from 'lucide-react';

interface SelectionViewProps {
  onSelect: (sign: ZodiacSign) => void;
}

const SelectionView: React.FC<SelectionViewProps> = ({ onSelect }) => {
  const [pressedSign, setPressedSign] = useState<ZodiacSign | null>(null);

  const handleSelect = (sign: ZodiacSign) => {
    setPressedSign(sign);
    setTimeout(() => {
      onSelect(sign);
    }, 400);
  };

  return (
    <div className="min-h-full flex flex-col">
      <div className="flex flex-col items-center gap-6 mb-10 pt-10">
        <div className="relative">
          <div className="absolute inset-0 bg-[var(--secondary)]/20 blur-2xl rounded-full animate-pulse" />
          <div className="relative p-4 glass-card rounded-[28px] text-[var(--secondary)]">
            <Stars size={32} />
          </div>
        </div>
        
        <div className="text-center space-y-2">
          <h1 className="text-3xl font-black font-montserrat text-[var(--text)] tracking-tight">
            Kaderini Seç
          </h1>
          <p className="text-[var(--text-muted)] text-xs font-medium max-w-[200px] mx-auto leading-relaxed">
            Yıldızların rehberliğinde özüne dönmeye hazır mısın?
          </p>
        </div>
      </div>

      <div className="grid grid-cols-2 gap-4 pb-10">
        {ALL_ZODIAC_SIGNS.map((sign, index) => {
          const data = ZODIAC_DATA[sign];
          const isPressed = pressedSign === sign;
          
          return (
            <button
              key={sign}
              onClick={() => handleSelect(sign)}
              className={`
                glass-card p-6 rounded-[32px] flex flex-col items-center gap-4 
                transition-all duration-300 relative overflow-hidden group border-[var(--border)]
                active-scale
                ${isPressed ? 'ring-2 ring-[var(--secondary)] scale-105' : 'hover:border-[var(--secondary)]/40'}
              `}
            >
              {isPressed && (
                <div className="absolute inset-0 bg-gradient-to-br from-[#7B1FA2]/20 to-[#4FC3F7]/20 animate-pulse" />
              )}
              
              <div className={`
                transition-all duration-500 transform
                ${isPressed ? 'text-[var(--text)] scale-125 rotate-[360deg]' : 'text-[#7B1FA2] group-hover:text-[var(--secondary)]'}
              `}>
                {React.cloneElement(data.icon as React.ReactElement, { 
                  size: 40, 
                  strokeWidth: isPressed ? 2 : 1.5 
                })}
              </div>
              
              <div className="text-center relative z-10">
                <span className={`
                  block text-base font-black font-montserrat tracking-wide
                  ${isPressed ? 'text-[var(--text)]' : 'text-[var(--text)]/80'}
                `}>
                  {sign}
                </span>
                <span className="block text-[8px] font-black uppercase tracking-widest mt-1 text-[var(--text-muted)] opacity-60">
                  {data.dates}
                </span>
              </div>
            </button>
          );
        })}
      </div>
    </div>
  );
};

export default SelectionView;
