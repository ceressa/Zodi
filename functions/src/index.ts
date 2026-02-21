import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";

admin.initializeApp();

const db = admin.firestore();

// Gemini API key - stored in Google Secret Manager
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");

// EU Region (same as Dozi)
const REGION = "europe-west3";

// ═══════════════════════════════════════════════════════════════
// Rate limiting
// ═══════════════════════════════════════════════════════════════

async function checkRateLimit(
  uid: string,
  functionName: string,
  maxRequests: number,
  windowSeconds: number
): Promise<void> {
  const now = Date.now();
  const windowStart = now - windowSeconds * 1000;
  const rateLimitRef = db
    .collection("rateLimits")
    .doc(`${functionName}_${uid}`);
  const doc = await rateLimitRef.get();

  if (doc.exists) {
    const data = doc.data()!;
    const requests: number[] = (data.requests || []).filter(
      (t: number) => t > windowStart
    );
    if (requests.length >= maxRequests) {
      throw new HttpsError(
        "resource-exhausted",
        "Cok fazla istek gonderdiniz. Lutfen biraz bekleyin."
      );
    }
    requests.push(now);
    await rateLimitRef.set({requests, updatedAt: now});
  } else {
    await rateLimitRef.set({requests: [now], updatedAt: now});
  }
}

// ═══════════════════════════════════════════════════════════════
// Zodiac signs (matches Flutter ZodiacSign enum)
// ═══════════════════════════════════════════════════════════════

const SIGNS: Record<string, string> = {
  aries: "Koc",
  taurus: "Boga",
  gemini: "Ikizler",
  cancer: "Yengec",
  leo: "Aslan",
  virgo: "Basak",
  libra: "Terazi",
  scorpio: "Akrep",
  sagittarius: "Yay",
  capricorn: "Oglak",
  aquarius: "Kova",
  pisces: "Balik",
};

// ═══════════════════════════════════════════════════════════════
// Helper: Call Gemini API
// ═══════════════════════════════════════════════════════════════

async function callGemini(
  apiKey: string,
  prompt: string
): Promise<string> {
  const url = `https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash-lite:generateContent?key=${apiKey}`;

  const response = await fetch(url, {
    method: "POST",
    headers: {"Content-Type": "application/json"},
    body: JSON.stringify({
      contents: [{parts: [{text: prompt}]}],
      generationConfig: {
        temperature: 0.9,
        maxOutputTokens: 1024,
      },
    }),
  });

  if (!response.ok) {
    const errorText = await response.text();
    console.error("Gemini API error:", response.status, errorText);
    throw new HttpsError("internal", "AI servisi su an kullanilamiyor.");
  }

  const result = await response.json();
  const text =
    result.candidates?.[0]?.content?.parts?.[0]?.text || "";

  if (!text) {
    throw new HttpsError("internal", "AI bos yanit dondu.");
  }

  return text;
}

// Helper: Parse JSON from Gemini response
function parseGeminiJson(text: string): Record<string, unknown> {
  let jsonStr = text;
  const codeBlock = text.match(/```json\s*([\s\S]*?)\s*```/);
  if (codeBlock) {
    jsonStr = codeBlock[1];
  } else {
    const jsonObj = text.match(/\{[\s\S]*\}/);
    if (jsonObj) jsonStr = jsonObj[0];
  }
  return JSON.parse(jsonStr);
}

// Helper: Today's date key
function getTodayKey(): string {
  const now = new Date();
  const y = now.getFullYear();
  const m = String(now.getMonth() + 1).padStart(2, "0");
  const d = String(now.getDate()).padStart(2, "0");
  return `${y}-${m}-${d}`;
}

function getTodayDisplay(): string {
  const now = new Date();
  const months = [
    "Ocak", "Subat", "Mart", "Nisan", "Mayis", "Haziran",
    "Temmuz", "Agustos", "Eylul", "Ekim", "Kasim", "Aralik",
  ];
  return `${now.getDate()} ${months[now.getMonth()]} ${now.getFullYear()}`;
}

// ═══════════════════════════════════════════════════════════════
// 🔮 generateHoroscope - Daily horoscope generation
// ═══════════════════════════════════════════════════════════════

export const generateHoroscope = onCall(
  {
    region: REGION,
    secrets: [GEMINI_API_KEY],
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (request) => {
    // Auth check
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Giris yapmaniz gerekiyor."
      );
    }

    const {signId} = request.data;

    // Validate sign
    if (!signId || !SIGNS[signId]) {
      throw new HttpsError(
        "invalid-argument",
        "Gecersiz burc: " + signId
      );
    }

    const uid = request.auth.uid;
    const dateKey = getTodayKey();
    const signName = SIGNS[signId];

    // Rate limit: 20 requests per minute per user
    await checkRateLimit(uid, "generateHoroscope", 20, 60);

    // 1. Check shared daily_horoscopes (maybe someone else already generated it)
    try {
      const snapshot = await db
        .collection("daily_horoscopes")
        .where("zodiacSign", "==", signName)
        .where("date", "==", dateKey)
        .limit(1)
        .get();

      if (!snapshot.empty) {
        const data = snapshot.docs[0].data();
        return {
          motto: data.motto || "",
          commentary: data.commentary || "",
          love: data.love || 0,
          money: data.money || 0,
          health: data.health || 0,
          career: data.career || 0,
          luckyColor: data.luckyColor || "",
          luckyNumber: data.luckyNumber || 0,
          source: "cache",
        };
      }
    } catch (e) {
      console.warn("daily_horoscopes query failed:", e);
    }

    // 2. Generate via Gemini
    const prompt = `Sen Astro Dozi'nin yapay zeka astrologusun. Samimi, bilge ve biraz gizemli bir tonla konusuyorsun. Turkce yaz.

Burc: ${signName}, Bugunku tarih: ${getTodayDisplay()}. Bugunun burc yorumunu yaz.

Yanitini SADECE asagidaki JSON formatinda ver, baska hicbir sey yazma:
{"motto":"Gunun mottosu","commentary":"Detayli yorum 2-3 paragraf 150-200 kelime","love":75,"money":60,"health":80,"career":70,"luckyColor":"Renk","luckyNumber":7}`;

    const apiKey = GEMINI_API_KEY.value();
    const text = await callGemini(apiKey, prompt);
    const horoscope = parseGeminiJson(text);

    // Save to daily_horoscopes for caching
    try {
      await db.collection("daily_horoscopes").add({
        zodiacSign: signName,
        date: dateKey,
        ...horoscope,
        generatedAt: admin.firestore.FieldValue.serverTimestamp(),
        generatedBy: uid,
        source: "cloud_function",
      });
    } catch (e) {
      console.warn("Could not save to daily_horoscopes:", e);
    }

    return {
      ...horoscope,
      source: "generated",
    };
  }
);

// ═══════════════════════════════════════════════════════════════
// ✨ generateFeature - Premium features (tarot, aura, etc.)
// ═══════════════════════════════════════════════════════════════

const FEATURE_PROMPTS: Record<string, {name: string; prompt: string}> = {
  tarot: {
    name: "Tarot Fali",
    prompt: `Sen Astro Dozi'nin tarot ustasisin. Turkce yaz. Kullaniciya 3 kartlik bir tarot fali ac. Yanitini SADECE JSON formatinda ver:
{"cards":[{"name":"Kart","meaning":"Anlami"},{"name":"Kart","meaning":"Anlami"},{"name":"Kart","meaning":"Anlami"}],"summary":"Genel mesaj"}`,
  },
  uyum: {
    name: "Burc Uyumu",
    prompt: `Sen Astro Dozi'nin burc uyumu uzmanisin. Turkce yaz. Secili burcun genel uyum analizini yap. Yanitini SADECE JSON formatinda ver:
{"title":"Uyum Baslik","compatibility":"Genel uyum analizi 2-3 paragraf","bestMatch":"En uyumlu burc","score":85}`,
  },
  aura: {
    name: "Aura Okuma",
    prompt: `Sen Astro Dozi'nin enerji okuyucususun. Turkce yaz. Aura rengini analiz et. Yanitini SADECE JSON formatinda ver:
{"color":"Ana renk","secondaryColor":"Ikincil renk","meaning":"Anlami","energy":"Enerji durumu","advice":"Tavsiye"}`,
  },
  gecmis: {
    name: "Gecmis Yasam",
    prompt: `Sen Astro Dozi'nin gecmis yasam okuyucususun. Turkce yaz. Gecmis yasam hikayesi anlat. Yanitini SADECE JSON formatinda ver:
{"era":"Donem","role":"Rol","story":"Hikaye 2 paragraf","karmaLesson":"Karmik ders","connection":"Simdiki yasam baglantisi"}`,
  },
  cakra: {
    name: "Cakra Analizi",
    prompt: `Sen Astro Dozi'nin cakra uzmanisin. Turkce yaz. 7 cakrayi analiz et. Yanitini SADECE JSON formatinda ver:
{"chakras":[{"name":"Kok Cakra","status":75,"note":"Not"},{"name":"Sakral Cakra","status":60,"note":"Not"},{"name":"Solar Pleksus","status":80,"note":"Not"},{"name":"Kalp Cakra","status":70,"note":"Not"},{"name":"Bogaz Cakra","status":65,"note":"Not"},{"name":"Ucuncu Goz","status":85,"note":"Not"},{"name":"Tac Cakra","status":55,"note":"Not"}],"overall":"Genel durum","advice":"Tavsiye"}`,
  },
  yasam: {
    name: "Yasam Yolu",
    prompt: `Sen Astro Dozi'nin numeroloji uzmanisin. Turkce yaz. Yasam yolu analizi yap. Yanitini SADECE JSON formatinda ver:
{"number":7,"title":"Baslik","meaning":"Anlami 1 paragraf","strengths":["Guc 1","Guc 2","Guc 3"],"challenges":["Zorluk 1","Zorluk 2","Zorluk 3"],"advice":"Tavsiye"}`,
  },
};

export const generateFeature = onCall(
  {
    region: REGION,
    secrets: [GEMINI_API_KEY],
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (request) => {
    // Auth check
    if (!request.auth) {
      throw new HttpsError(
        "unauthenticated",
        "Giris yapmaniz gerekiyor."
      );
    }

    const {feature, signId} = request.data;

    // Validate feature
    const config = FEATURE_PROMPTS[feature];
    if (!config) {
      throw new HttpsError(
        "invalid-argument",
        "Gecersiz ozellik: " + feature
      );
    }

    const uid = request.auth.uid;

    // Rate limit: 10 feature requests per minute
    await checkRateLimit(uid, "generateFeature", 10, 60);

    // Build prompt with sign context
    const signName = signId && SIGNS[signId] ? SIGNS[signId] : null;
    const signContext = signName
      ? `\nKullanicinin burcu: ${signName}`
      : "";
    const prompt = config.prompt + signContext;

    // Call Gemini
    const apiKey = GEMINI_API_KEY.value();
    const text = await callGemini(apiKey, prompt);
    const result = parseGeminiJson(text);

    return result;
  }
);
