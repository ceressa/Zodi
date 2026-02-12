
import React, { useState, useEffect } from 'react';
import { AppView, ZodiacSign, DailyHoroscope } from './types';
import Layout from './components/Layout';
import DailyView from './views/DailyView';
import SelectionView from './views/SelectionView';
import AnalysisView from './views/AnalysisView';
import MatchView from './views/MatchView';
import SettingsView from './views/SettingsView';
import PremiumView from './views/PremiumView';
import SplashView from './views/SplashView';
import AuthView from './views/AuthView';
import { fetchDailyHoroscope } from './geminiService';

const App: React.FC = () => {
  const [isSplashActive, setIsSplashActive] = useState(true);
  const [userName, setUserName] = useState<string | null>(() => localStorage.getItem('userName'));
  const [userEmail, setUserEmail] = useState<string | null>(() => localStorage.getItem('userEmail'));
  const [theme, setTheme] = useState<'dark' | 'light'>(() => (localStorage.getItem('theme') as 'dark' | 'light') || 'dark');
  const [activeView, setActiveView] = useState<AppView>(AppView.DAILY);
  const [isPremium, setIsPremium] = useState<boolean>(() => localStorage.getItem('isPremium') === 'true');
  const [selectedZodiac, setSelectedZodiac] = useState<ZodiacSign | null>(() => {
    const saved = localStorage.getItem('selectedZodiac');
    return (saved as ZodiacSign) || null;
  });
  const [dailyData, setDailyData] = useState<DailyHoroscope | null>(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    const timer = setTimeout(() => setIsSplashActive(false), 3000);
    return () => clearTimeout(timer);
  }, []);

  useEffect(() => {
    document.documentElement.className = theme;
    localStorage.setItem('theme', theme);
  }, [theme]);

  useEffect(() => {
    if (selectedZodiac) {
      localStorage.setItem('selectedZodiac', selectedZodiac);
      loadDailyHoroscope(selectedZodiac);
    }
  }, [selectedZodiac]);

  const loadDailyHoroscope = async (sign: ZodiacSign) => {
    try {
      setLoading(true);
      const data = await fetchDailyHoroscope(sign);
      setDailyData(data);
    } catch (error) {
      console.error("Horoscope error:", error);
    } finally {
      setLoading(false);
    }
  };

  const handleLogin = (name: string, email: string) => {
    setUserName(name);
    setUserEmail(email);
    localStorage.setItem('userName', name);
    localStorage.setItem('userEmail', email);
  };

  const handleUpgrade = () => {
    setIsPremium(true);
    localStorage.setItem('isPremium', 'true');
    setActiveView(AppView.DAILY);
  };

  const toggleTheme = () => {
    setTheme(prev => prev === 'dark' ? 'light' : 'dark');
  };

  if (isSplashActive) return <SplashView />;
  if (!userName || !userEmail) return <AuthView onLogin={handleLogin} />;
  if (!selectedZodiac) return <SelectionView onSelect={setSelectedZodiac} />;

  const renderView = () => {
    switch (activeView) {
      case AppView.DAILY:
        return <DailyView zodiac={selectedZodiac} data={dailyData} loading={loading} onRefresh={() => loadDailyHoroscope(selectedZodiac)} isPremium={isPremium} />;
      case AppView.ANALYSIS:
        return <AnalysisView zodiac={selectedZodiac} isPremium={isPremium} />;
      case AppView.MATCH:
        return <MatchView userZodiac={selectedZodiac} isPremium={isPremium} />;
      case AppView.PREMIUM:
        return <PremiumView onPurchase={handleUpgrade} onBack={() => setActiveView(AppView.SETTINGS)} />;
      case AppView.SETTINGS:
        return (
          <SettingsView 
            isPremium={isPremium}
            theme={theme}
            onToggleTheme={toggleTheme}
            onGoPremium={() => setActiveView(AppView.PREMIUM)}
            onSignReset={() => {
              setSelectedZodiac(null);
              localStorage.removeItem('selectedZodiac');
            }} 
          />
        );
      default:
        return <DailyView zodiac={selectedZodiac} data={dailyData} loading={loading} onRefresh={() => {}} isPremium={isPremium} />;
    }
  };

  return (
    <Layout activeView={activeView} setView={setActiveView} selectedZodiac={selectedZodiac}>
      {renderView()}
    </Layout>
  );
};

export default App;
