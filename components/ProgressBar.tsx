
import React from 'react';

interface ProgressBarProps {
  label: string;
  value: number;
}

const ProgressBar: React.FC<ProgressBarProps> = ({ label, value }) => {
  const getProgressColor = (v: number) => {
    if (v >= 70) return '#4CAF50';
    if (v >= 40) return '#D4AF37';
    return '#F44336';
  };

  const color = getProgressColor(value);

  return (
    <div className="glass-card p-4 rounded-[28px] flex flex-col gap-3 relative overflow-hidden group border-[var(--border)]">
      <div className="flex justify-between items-center relative z-10">
        <span className="text-[8px] font-black uppercase text-[var(--text-muted)] tracking-widest">{label}</span>
        <span className="text-[10px] font-black font-montserrat" style={{ color }}>
          %{value}
        </span>
      </div>
      <div className="w-full bg-[var(--text-muted)]/10 h-1.5 rounded-full overflow-hidden relative z-10">
        <div 
          className="h-full transition-all duration-1000 ease-out rounded-full" 
          style={{ 
            width: `${value}%`, 
            backgroundColor: color, 
            boxShadow: `0 0 8px ${color}` 
          }}
        />
      </div>
      <div 
        className="absolute bottom-0 right-0 w-12 h-12 rounded-full blur-3xl opacity-[0.03] transition-transform duration-700 group-hover:scale-150" 
        style={{ backgroundColor: color }} 
      />
    </div>
  );
};

export default ProgressBar;
