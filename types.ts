
export type ZodiacSign = 
  | 'Koç' | 'Boğa' | 'İkizler' | 'Yengeç' 
  | 'Aslan' | 'Başak' | 'Terazi' | 'Akrep' 
  | 'Yay' | 'Oğlak' | 'Kova' | 'Balık';

export interface DailyHoroscope {
  motto: string;
  commentary: string;
  love: number;
  money: number;
  health: number;
  career: number;
  luckyColor: string;
  luckyNumber: number;
  date: string;
}

export interface DetailedAnalysis {
  title: string;
  content: string;
  percentage: number;
}

export interface CompatibilityResult {
  score: number;
  summary: string;
  aspects: {
    love: number;
    communication: number;
    trust: number;
  };
}

export enum AppView {
  DAILY = 'daily',
  MATCH = 'match',
  ANALYSIS = 'analysis',
  SETTINGS = 'settings',
  PREMIUM = 'premium'
}
