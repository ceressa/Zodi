
import { GoogleGenAI, Type } from "@google/genai";
import { DailyHoroscope, DetailedAnalysis, ZodiacSign, CompatibilityResult } from "./types";

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY || '' });

const SYSTEM_PROMPT = `Sen Zodi'sin. Astroloji dünyasının en dürüst, en "cool" ve bazen en huysuz rehberisin. 
Kullanıcıya ASLA 'siz' diye hitap etme, her zaman 'sen' dilini kullan. 
Üslubun: Samimi ama mesafeli bir "cool"lukta ol, bazen iltifat et, bazen yerin dibine sok. 
Mistik terimleri modern hayatın dertleriyle harmanla.`;

export async function fetchDailyHoroscope(sign: ZodiacSign): Promise<DailyHoroscope> {
  const dateStr = new Date().toLocaleDateString('tr-TR');
  
  const response = await ai.models.generateContent({
    model: 'gemini-3-flash-preview',
    contents: `Burç: ${sign}, Bugünün tarihi: ${dateStr}. Zodi olarak bugünün gerçeklerini anlat.`,
    config: {
      systemInstruction: SYSTEM_PROMPT + " Yanıtları JSON formatında ver.",
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          motto: { type: Type.STRING },
          commentary: { type: Type.STRING },
          love: { type: Type.NUMBER },
          money: { type: Type.NUMBER },
          health: { type: Type.NUMBER },
          career: { type: Type.NUMBER },
          luckyColor: { type: Type.STRING },
          luckyNumber: { type: Type.NUMBER }
        },
        required: ["motto", "commentary", "love", "money", "health", "career", "luckyColor", "luckyNumber"]
      }
    }
  });

  return { ...JSON.parse(response.text || '{}'), date: dateStr };
}

export async function fetchDetailedAnalysis(sign: ZodiacSign, category: string): Promise<DetailedAnalysis> {
  const response = await ai.models.generateContent({
    model: 'gemini-3-flash-preview',
    contents: `Burç: ${sign}, Konu: ${category}. Zodi gibi dürüst bir analiz yap.`,
    config: {
      systemInstruction: SYSTEM_PROMPT + " JSON döndür.",
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          title: { type: Type.STRING },
          content: { type: Type.STRING },
          percentage: { type: Type.NUMBER }
        },
        required: ["title", "content", "percentage"]
      }
    }
  });
  return JSON.parse(response.text || '{}');
}

export async function fetchCompatibility(sign1: ZodiacSign, sign2: ZodiacSign): Promise<CompatibilityResult> {
  const response = await ai.models.generateContent({
    model: 'gemini-3-flash-preview',
    contents: `${sign1} ve ${sign2} burçları arasındaki uyumu Zodi tarzında analiz et.`,
    config: {
      systemInstruction: SYSTEM_PROMPT + " Yanıtı JSON formatında ver. 'summary' alanı 2 paragraf dürüst yorum içermeli.",
      responseMimeType: "application/json",
      responseSchema: {
        type: Type.OBJECT,
        properties: {
          score: { type: Type.NUMBER, description: "Genel uyum puanı 0-100" },
          summary: { type: Type.STRING, description: "Zodi tarzı dürüst uyum yorumu" },
          aspects: {
            type: Type.OBJECT,
            properties: {
              love: { type: Type.NUMBER },
              communication: { type: Type.NUMBER },
              trust: { type: Type.NUMBER }
            }
          }
        },
        required: ["score", "summary", "aspects"]
      }
    }
  });
  return JSON.parse(response.text || '{}');
}
