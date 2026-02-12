
import React, { useState, useEffect } from 'react';
import { DetailedAnalysis, ZodiacSign } from '../types';
import { fetchDetailedAnalysis } from '../geminiService';
import { Heart, DollarSign, Activity, Briefcase, RefreshCw, Lock, Sparkles, Eye } from 'lucide-react';
import AdBanner from '../components/AdBanner';

interface AnalysisViewProps {
  zodiac: ZodiacSign;
  isPremium: boolean;
}

const CATEGORIES = [
  { id: 'love', label: 'Aşk', icon: <Heart size={18} />, color: '#E91E63' },
  { id: 'money', label: 'Para', icon: <DollarSign size={18} />, color: '#4CAF50' },
  { id: 'health', label: 'Sağlık', icon: <Activity size={18} />, color: '#00BCD4' },
  { id: 'career', label: 'İş', icon: <Briefcase size={18} />, color: '#673AB7' },
];

const AnalysisView: React.FC<AnalysisViewProps> = ({ zodiac, isPremium }) => {
  const [activeTab, setActiveTab] = useState('love');
  const [isUnlocked, setIsUnlocked] = useState(false);
  const [analysis, setAnalysis] = useState<DetailedAnalysis | null>(null);
  const [loading, setLoading] = useState(false);
  const [adWatching, setAdWatching] = useState(false);

  useEffect(() => {
    if (isUnlocked || activeTab === 'love' || isPremium) {
        loadAnalysis();
    }
  }, [activeTab, zodiac, isUnlocked, isPremium]);

  const loadAnalysis = async () => {
    setLoading(true);
    try {
      const data = await fetchDetailedAnalysis(zodiac, activeTab);
      setAnalysis(data);
    } catch (error) {
      console.error(error);
    } finally {
      setLoading(false);
    }
  };

  const handleUnlock = () => {
    if (isPremium) return;
    setAdWatching(true);
    setTimeout(() => {
        setAdWatching(false);
        setIsUnlocked(true);
    }, 4000);
  };

  const activeCategory = CATEGORIES.find(c => c.id === activeTab);

  if (adWatching) {
    return (
      <div className="fixed inset-0 z-[300] bg-black flex flex-col items-center justify-center p-8 animate-fadeIn">
        <div className="absolute top-12 right-8 flex items-center gap-2 text-white/40">
           <span className="text-[10px] font-bold uppercase tracking-widest">Reklam Bitimine Kalan...</span>
           <div className="w-8 h-8 rounded-full border-2 border-white/10 flex items-center justify-center text-xs font-bold animate-pulse">4s</div>
        </div>
        <div className="w-full aspect-video bg-white/5 rounded-3xl flex items-center justify-center border border-white/10 relative overflow-hidden group">
           <div className="absolute inset-0 bg-gradient-to-tr from-[#7B1FA2]/20 to-[#4FC3F7]/20" />
           <div className="relative flex flex-col items-center gap-4">
              <div className="w-16 h-16 rounded-full bg-white/10 flex items-center justify-center animate-spin">
                <RefreshCw className="text-white/40" />
              </div>
              <p className="text-white/40 text-[10px] font-bold uppercase tracking-[4px]">Video Oynatılıyor</p>
           </div>
        </div>
        <div className="mt-12 text-center space-y-4">
           <p className="text-xl font-black text-white font-montserrat uppercase tracking-tight">Kozmik Sırlar Hazırlanıyor</p>
           <p className="text-white/40 text-xs">Video bitiminde analizin otomatik olarak açılacak.</p>
        </div>
      </div>
    );
  }

  return (
    <div className="flex flex-col gap-8 animate-fadeIn">
      <div className="text-center pt-2">
        <h2 className="text-3xl font-black gold-text font-montserrat tracking-tight leading-none uppercase">
          Derin Analiz
        </h2>
        <p className="text-[var(--text-muted)] text-[11px] font-bold tracking-[5px] uppercase mt-4">Yıldızların Gizli Ajandası</p>
      </div>

      {/* Categories Bar */}
      <div className="flex glass-card p-1.5 rounded-[28px] border border-[var(--border)] shadow-xl bg-[var(--tab-bg)]">
        {CATEGORIES.map((cat) => (
          <button
            key={cat.id}
            onClick={() => {
                setActiveTab(cat.id);
                if (cat.id !== 'love') setIsUnlocked(false);
            }}
            className={`flex-1 py-4 rounded-2xl flex flex-col items-center justify-center gap-1.5 transition-all duration-300 relative ${
              activeTab === cat.id 
                ? 'text-white shadow-xl scale-105 z-10' 
                : 'text-[var(--text-muted)] hover:text-[var(--text)]'
            }`}
            style={{ backgroundColor: activeTab === cat.id ? cat.color : 'transparent' }}
          >
            {cat.icon}
            <span className="text-[9px] font-black uppercase tracking-widest">{cat.label}</span>
          </button>
        ))}
      </div>

      {!isUnlocked && activeTab !== 'love' && !isPremium ? (
        <div className="glass-card rounded-[48px] p-10 flex flex-col items-center text-center gap-10 border border-[var(--gold)]/20 shadow-2xl mt-4 relative overflow-hidden">
            <div className="absolute top-0 right-0 p-8 opacity-10">
              <Sparkles size={120} className="text-[var(--gold)]" />
            </div>
            <div className="relative">
                <div className="absolute inset-0 bg-[var(--gold)] blur-3xl opacity-20 animate-pulse" />
                <div className="w-20 h-20 bg-[var(--bg)] rounded-[32px] flex items-center justify-center text-[var(--gold)] border border-[var(--gold)]/30 shadow-2xl">
                    <Lock size={40} strokeWidth={1.5} />
                </div>
            </div>
            <div className="space-y-4 relative z-10">
                <h3 className="text-2xl font-black text-[var(--text)] font-montserrat uppercase leading-tight tracking-tight">
                  {activeCategory?.label} ANALİZİ KİLİTLİ
                </h3>
                <p className="text-sm text-[var(--text-muted)] px-2 leading-relaxed font-medium">Bu özel kozmik dosya sadece derin bir odaklanma (ve kısa bir video) ile erişilebilir.</p>
            </div>
            <button 
                onClick={handleUnlock}
                className="w-full bg-[var(--text)] text-[var(--bg)] py-6 rounded-[32px] font-black uppercase text-xs tracking-[3px] active-scale flex items-center justify-center gap-4 shadow-2xl"
            >
                <Eye size={20} />
                Videoyu İzle & Aç
            </button>
        </div>
      ) : (
        <div className="space-y-8">
            {loading ? (
                <div className="flex flex-col items-center justify-center py-24 gap-6">
                    <div className="relative">
                       <RefreshCw className="animate-spin text-[var(--secondary)]" size={48} />
                       <div className="absolute inset-0 bg-[var(--secondary)]/20 blur-xl rounded-full" />
                    </div>
                    <p className="text-[11px] font-black tracking-[5px] uppercase gold-text animate-pulse">Arşivler Açılıyor...</p>
                </div>
            ) : analysis ? (
                <div className="space-y-8 animate-slideUp">
                    {/* Gauge */}
                    <div className="flex flex-col items-center justify-center py-6 relative">
                        <div className="absolute inset-0 bg-radial-gradient from-[var(--secondary)]/10 to-transparent pointer-events-none" />
                        <div className="relative w-44 h-44">
                            <svg className="w-full h-full transform -rotate-90 filter drop-shadow-[0_0_20px_rgba(79,195,247,0.3)]">
                                <circle cx="88" cy="88" r="75" stroke="rgba(0,0,0,0.05)" strokeWidth="14" fill="transparent" />
                                <circle
                                    cx="88"
                                    cy="88"
                                    r="75"
                                    stroke={activeCategory?.color || '#4FC3F7'}
                                    strokeWidth="14"
                                    fill="transparent"
                                    strokeDasharray={471}
                                    strokeDashoffset={471 - (471 * analysis.percentage) / 100}
                                    strokeLinecap="round"
                                    className="transition-all duration-1500 ease-out"
                                />
                            </svg>
                            <div className="absolute inset-0 flex flex-col items-center justify-center">
                                <span className="text-5xl font-black text-[var(--text)] font-montserrat tracking-tighter">%{analysis.percentage}</span>
                                <span className="text-[9px] text-[var(--text-muted)] font-bold uppercase tracking-[4px] mt-1">Yoğunluk</span>
                            </div>
                        </div>
                    </div>

                    {!isPremium && <AdBanner type="native" />}

                    <div className="glass-card rounded-[40px] p-8 border border-[var(--border)] shadow-xl relative overflow-hidden">
                        <div className="absolute top-0 right-0 p-8 opacity-[0.05]" style={{ color: activeCategory?.color }}>
                            {activeCategory?.icon}
                        </div>
                        <h3 className="text-2xl font-black mb-6 font-montserrat uppercase tracking-tight leading-tight" style={{ color: activeCategory?.color }}>{analysis.title}</h3>
                        <div className="text-lg leading-relaxed text-[var(--text)] whitespace-pre-wrap font-lato italic font-light opacity-90">
                            "{analysis.content}"
                        </div>
                    </div>
                    
                    {!isPremium && <AdBanner type="mini" />}
                </div>
            ) : null}
        </div>
      )}
    </div>
  );
};

export default AnalysisView;
