
import React from 'react';
import { ZodiacSign } from './types';

// Astrolojik Semboller için Gelişmiş SVG Bileşenleri
const ZodiacIcon = ({ children, size = 24 }: { children: React.ReactNode; size?: number }) => (
  <svg
    width={size}
    height={size}
    viewBox="0 0 24 24"
    fill="none"
    stroke="currentColor"
    strokeWidth="1.5"
    strokeLinecap="round"
    strokeLinejoin="round"
    className="lucide-icon transition-all duration-500"
  >
    {children}
  </svg>
);

const AriesIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M12 13c-1.5-3-3-5-6-5s-4 2-4 4 2 4 4 4" />
    <path d="M12 13c1.5-3 3-5 6-5s4 2 4 4-2 4-4 4" />
    <path d="M12 13v8" />
  </ZodiacIcon>
);

const TaurusIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <circle cx="12" cy="15" r="5" />
    <path d="M6 4c0 4 3 6 6 6s6-2 6-6" />
  </ZodiacIcon>
);

const GeminiIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M9 5h6" />
    <path d="M9 19h6" />
    <path d="M10 5v14" />
    <path d="M14 5v14" />
    <path d="M7 5c0-1.1.9-2 2-2h6a2 2 0 0 1 2 2" />
    <path d="M7 19c0 1.1.9 2 2 2h6a2 2 0 0 0 2-2" />
  </ZodiacIcon>
);

const CancerIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <circle cx="17" cy="9" r="3" />
    <path d="M14 9c0-3.3-2.7-6-6-6S2 5.7 2 9" />
    <circle cx="7" cy="15" r="3" />
    <path d="M10 15c0 3.3 2.7 6 6 6s6-2.7 6-6" />
  </ZodiacIcon>
);

const LeoIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <circle cx="6" cy="14" r="3" />
    <path d="M6 11c0-4 4-7 8-7s7 3 7 7-3 7-7 7" />
    <circle cx="14" cy="11" r="3" />
    <path d="M17 18c1.5 0 3-1.5 3-3" />
  </ZodiacIcon>
);

const VirgoIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M4 4v10a4 4 0 0 0 4 4" />
    <path d="M8 4v10a4 4 0 0 0 4 4" />
    <path d="M12 4v10a4 4 0 0 0 4 4" />
    <path d="M16 14c0-2.2 1.8-4 4-4v8a2 2 0 0 1-2 2" />
    <path d="M20 18l-2 2" />
  </ZodiacIcon>
);

const LibraIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M5 20h14" />
    <path d="M5 17h14" />
    <path d="M12 4a4 4 0 0 0-4 4h8a4 4 0 0 0-4-4Z" />
    <path d="M8 17c0-2.2 1.8-4 4-4s4 1.8 4 4" />
  </ZodiacIcon>
);

const ScorpioIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M4 4v10a4 4 0 0 0 4 4" />
    <path d="M8 4v10a4 4 0 0 0 4 4" />
    <path d="M12 4v10a4 4 0 0 0 4 4" />
    <path d="M16 18c0 2 2 2 2 2s2-1 2-3" />
    <path d="M17 15l3 2-2 2" />
  </ZodiacIcon>
);

const SagittariusIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M20 4l-9 9" />
    <path d="M4 20l9-9" />
    <path d="M15 4h5v5" />
    <path d="M8 12l4 4" />
  </ZodiacIcon>
);

const CapricornIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M4 12a3 3 0 0 1 6 0v6" />
    <path d="M10 12a3 3 0 0 1 6 0v1a3 3 0 0 0 3 3 3 3 0 0 1 0 6" />
    <circle cx="19" cy="19" r="1" />
  </ZodiacIcon>
);

const AquariusIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M4 10l3-3 4 4 3-3 4 4" />
    <path d="M4 17l3-3 4 4 3-3 4 4" />
  </ZodiacIcon>
);

const PiscesIcon = (props: any) => (
  <ZodiacIcon {...props}>
    <path d="M12 4v16" />
    <path d="M4 12h16" />
    <path d="M5 5c3 3 3 11 0 14" />
    <path d="M19 5c-3 3-3 11 0 14" />
  </ZodiacIcon>
);

export const COLORS = {
  bg: '#070310',
  card: '#190C2D',
  accentPurple: '#7B1FA2',
  accentBlue: '#4FC3F7',
  text: '#C5CAE9',
  positive: '#4CAF50',
  negative: '#F44336',
  warning: '#FFC107'
};

export const ZODIAC_DATA: Record<ZodiacSign, { icon: React.ReactNode; dates: string }> = {
  'Koç': { icon: <AriesIcon />, dates: '21 Mart - 19 Nisan' },
  'Boğa': { icon: <TaurusIcon />, dates: '20 Nisan - 20 Mayıs' },
  'İkizler': { icon: <GeminiIcon />, dates: '21 Mayıs - 20 Haziran' },
  'Yengeç': { icon: <CancerIcon />, dates: '21 Haziran - 22 Temmuz' },
  'Aslan': { icon: <LeoIcon />, dates: '23 Temmuz - 22 Ağustos' },
  'Başak': { icon: <VirgoIcon />, dates: '23 Ağustos - 22 Eylül' },
  'Terazi': { icon: <LibraIcon />, dates: '23 Eylül - 22 Ekim' },
  'Akrep': { icon: <ScorpioIcon />, dates: '23 Ekim - 21 Kasım' },
  'Yay': { icon: <SagittariusIcon />, dates: '22 Kasım - 21 Aralık' },
  'Oğlak': { icon: <CapricornIcon />, dates: '22 Aralık - 19 Ocak' },
  'Kova': { icon: <AquariusIcon />, dates: '20 Ocak - 18 Şubat' },
  'Balık': { icon: <PiscesIcon />, dates: '19 Şubat - 20 Mart' }
};

export const ALL_ZODIAC_SIGNS: ZodiacSign[] = [
  'Koç', 'Boğa', 'İkizler', 'Yengeç', 
  'Aslan', 'Başak', 'Terazi', 'Akrep', 
  'Yay', 'Oğlak', 'Kova', 'Balık'
];
