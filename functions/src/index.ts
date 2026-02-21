import * as admin from "firebase-admin";
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {onRequest} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import * as crypto from "crypto";

admin.initializeApp();

const db = admin.firestore();

// Secrets - stored in Google Secret Manager
const GEMINI_API_KEY = defineSecret("GEMINI_API_KEY");
const PADDLE_WEBHOOK_SECRET = defineSecret("PADDLE_WEBHOOK_SECRET");

// EU Region (same as Dozi)
const REGION = "europe-west3";

// ═══════════════════════════════════════════════════════════════
// Paddle Price → Plan/Coin mapping
// ═══════════════════════════════════════════════════════════════

interface SubscriptionPlan {
  type: "subscription";
  tier: string;
  tierName: string;
  dailyBonus: number;
  adReward: number;
}

interface CoinPack {
  type: "coins";
  amount: number;
  label: string;
}

type PaddleProduct = SubscriptionPlan | CoinPack;

const PADDLE_PRICES: Record<string, PaddleProduct> = {
  // Subscriptions
  "pri_01kj0d4fffjy7q1r8zkaxrtt1k": {
    type: "subscription",
    tier: "gold",
    tierName: "Altın",
    dailyBonus: 15,
    adReward: 8,
  },
  "pri_01kj0da2y4y3g9dbxrk4d8xa67": {
    type: "subscription",
    tier: "diamond",
    tierName: "Elmas",
    dailyBonus: 30,
    adReward: 15,
  },
  "pri_01kj0d97vgv5xrt8pqcpbekt7b": {
    type: "subscription",
    tier: "platinum",
    tierName: "Platinyum",
    dailyBonus: 50,
    adReward: 25,
  },
  // Coin packs (one-time)
  "pri_01kj0dh56rf8q77v9f74sy4bm6": {
    type: "coins",
    amount: 50,
    label: "50 Yıldız Tozu",
  },
  "pri_01kj0dktnrt70d3kfpc6mby8wt": {
    type: "coins",
    amount: 600,
    label: "600 Yıldız Tozu",
  },
  "pri_01kj0dn6zrpx05bqxezznkds7n": {
    type: "coins",
    amount: 2000,
    label: "2000 Yıldız Tozu",
  },
};

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

// ═══════════════════════════════════════════════════════════════
// 💳 Paddle Webhook - Handles payment events
// ═══════════════════════════════════════════════════════════════

/**
 * Verify Paddle webhook signature (ts=...;h1=...)
 */
function verifyPaddleSignature(
  rawBody: string,
  signature: string,
  secretKey: string
): boolean {
  // Parse signature: ts=TIMESTAMP;h1=HASH
  const parts: Record<string, string> = {};
  for (const part of signature.split(";")) {
    const [key, val] = part.split("=");
    if (key && val) parts[key] = val;
  }

  const ts = parts["ts"];
  const h1 = parts["h1"];
  if (!ts || !h1) return false;

  // Check timestamp not too old (5 minute window)
  const now = Math.floor(Date.now() / 1000);
  const timestamp = parseInt(ts, 10);
  if (Math.abs(now - timestamp) > 300) return false;

  // Build signed payload: ts:rawBody
  const signedPayload = `${ts}:${rawBody}`;
  const expectedSignature = crypto
    .createHmac("sha256", secretKey)
    .update(signedPayload)
    .digest("hex");

  return crypto.timingSafeEqual(
    Buffer.from(h1),
    Buffer.from(expectedSignature)
  );
}

export const paddleWebhook = onRequest(
  {
    region: REGION,
    secrets: [PADDLE_WEBHOOK_SECRET],
    memory: "256MiB",
    timeoutSeconds: 30,
  },
  async (req, res) => {
    // Only accept POST
    if (req.method !== "POST") {
      res.status(405).send("Method Not Allowed");
      return;
    }

    // Get raw body for signature verification
    const rawBody = typeof req.body === "string"
      ? req.body
      : JSON.stringify(req.body);

    // Verify signature
    const signature = req.headers["paddle-signature"] as string;
    if (!signature) {
      console.error("Missing Paddle-Signature header");
      res.status(401).send("Missing signature");
      return;
    }

    const secret = PADDLE_WEBHOOK_SECRET.value();
    if (!verifyPaddleSignature(rawBody, signature, secret)) {
      console.error("Invalid Paddle webhook signature");
      res.status(401).send("Invalid signature");
      return;
    }

    // Parse event
    const event = typeof req.body === "string"
      ? JSON.parse(req.body)
      : req.body;

    const eventType = event.event_type as string;
    const data = event.data;

    console.log(
      `[Paddle] Event: ${eventType}, ID: ${data?.id || "unknown"}`
    );

    try {
      switch (eventType) {
      // ── Subscription Created ──
      case "subscription.created": {
        const customData = data.custom_data;
        const firebaseUid = customData?.firebase_uid;

        if (!firebaseUid) {
          console.error("[Paddle] No firebase_uid in custom_data");
          res.status(200).send("OK (no uid)");
          return;
        }

        const priceId = data.items?.[0]?.price?.id;
        const product = priceId ? PADDLE_PRICES[priceId] : null;

        if (!product || product.type !== "subscription") {
          console.error(
            `[Paddle] Unknown subscription price: ${priceId}`
          );
          res.status(200).send("OK (unknown price)");
          return;
        }

        // Update user document
        await db.collection("users").doc(firebaseUid).set(
          {
            isPremium: true,
            membershipTier: product.tier,
            membershipTierName: product.tierName,
            dailyBonus: product.dailyBonus,
            adReward: product.adReward,
            paddleSubscriptionId: data.id,
            paddleCustomerId: data.customer_id,
            paddleStatus: data.status,
            paddlePriceId: priceId,
            subscriptionSource: "paddle_web",
            subscriptionUpdatedAt:
                admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

        // Log
        await db.collection("paddle_events").add({
          eventType,
          subscriptionId: data.id,
          firebaseUid,
          priceId,
          tier: product.tier,
          status: data.status,
          createdAt:
              admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(
          `[Paddle] Subscription created: ${product.tierName} for ${firebaseUid}`
        );
        break;
      }

      // ── Subscription Updated ──
      case "subscription.updated": {
        const customData = data.custom_data;
        const firebaseUid = customData?.firebase_uid;

        if (!firebaseUid) {
          console.error("[Paddle] No firebase_uid in custom_data");
          res.status(200).send("OK (no uid)");
          return;
        }

        const priceId = data.items?.[0]?.price?.id;
        const product = priceId ? PADDLE_PRICES[priceId] : null;

        const updateData: Record<string, unknown> = {
          paddleStatus: data.status,
          subscriptionUpdatedAt:
              admin.firestore.FieldValue.serverTimestamp(),
        };

        if (data.status === "active" &&
            product?.type === "subscription") {
          updateData.isPremium = true;
          updateData.membershipTier = product.tier;
          updateData.membershipTierName = product.tierName;
          updateData.dailyBonus = product.dailyBonus;
          updateData.adReward = product.adReward;
          updateData.paddlePriceId = priceId;
        } else if (
          data.status === "canceled" ||
            data.status === "paused" ||
            data.status === "past_due"
        ) {
          // Keep premium until end of billing period
          // Paddle sends scheduled_change when it expires
          if (data.scheduled_change?.action === "cancel") {
            updateData.subscriptionCancelAt =
                data.scheduled_change.effective_at;
          }
        }

        await db.collection("users").doc(firebaseUid).set(
          updateData,
          {merge: true}
        );

        // Log
        await db.collection("paddle_events").add({
          eventType,
          subscriptionId: data.id,
          firebaseUid,
          status: data.status,
          createdAt:
              admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(
          `[Paddle] Subscription updated: ${data.status} for ${firebaseUid}`
        );
        break;
      }

      // ── Subscription Canceled ──
      case "subscription.canceled": {
        const customData = data.custom_data;
        const firebaseUid = customData?.firebase_uid;

        if (!firebaseUid) {
          res.status(200).send("OK (no uid)");
          return;
        }

        await db.collection("users").doc(firebaseUid).set(
          {
            isPremium: false,
            membershipTier: "standard",
            membershipTierName: "Standart",
            dailyBonus: 5,
            adReward: 5,
            paddleStatus: "canceled",
            subscriptionUpdatedAt:
                admin.firestore.FieldValue.serverTimestamp(),
          },
          {merge: true}
        );

        await db.collection("paddle_events").add({
          eventType,
          subscriptionId: data.id,
          firebaseUid,
          status: "canceled",
          createdAt:
              admin.firestore.FieldValue.serverTimestamp(),
        });

        console.log(
          `[Paddle] Subscription canceled for ${firebaseUid}`
        );
        break;
      }

      // ── Transaction Completed (coin packs + subscription payments) ──
      case "transaction.completed": {
        const customData = data.custom_data;
        const firebaseUid = customData?.firebase_uid;

        if (!firebaseUid) {
          console.error("[Paddle] No firebase_uid in custom_data");
          res.status(200).send("OK (no uid)");
          return;
        }

        // Check if this is a coin pack purchase
        const priceId = data.items?.[0]?.price?.id;
        const product = priceId ? PADDLE_PRICES[priceId] : null;

        if (product?.type === "coins") {
          // Check idempotency — don't credit twice
          const txnId = data.id;
          const existing = await db
            .collection("paddle_events")
            .where("transactionId", "==", txnId)
            .where("coinsAwarded", "==", true)
            .limit(1)
            .get();

          if (!existing.empty) {
            console.log(
              `[Paddle] Coins already awarded for txn ${txnId}`
            );
            res.status(200).send("OK (already processed)");
            return;
          }

          // Credit coins
          await db.collection("users").doc(firebaseUid).set(
            {
              coinBalance: admin.firestore.FieldValue.increment(
                product.amount
              ),
            },
            {merge: true}
          );

          // Log
          await db.collection("paddle_events").add({
            eventType,
            transactionId: txnId,
            firebaseUid,
            priceId,
            coinsAwarded: true,
            coinAmount: product.amount,
            label: product.label,
            createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
          });

          console.log(
            `[Paddle] ${product.amount} coins credited to ${firebaseUid}`
          );
        } else {
          // Subscription payment — just log it
          await db.collection("paddle_events").add({
            eventType,
            transactionId: data.id,
            firebaseUid,
            priceId,
            createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
          });
        }
        break;
      }

      // ── Transaction Payment Failed ──
      case "transaction.payment_failed": {
        const customData = data.custom_data;
        const firebaseUid = customData?.firebase_uid;

        if (firebaseUid) {
          await db.collection("paddle_events").add({
            eventType,
            transactionId: data.id,
            firebaseUid,
            error: data.payments?.[0]?.error_code || "unknown",
            createdAt:
                admin.firestore.FieldValue.serverTimestamp(),
          });
          console.log(
            `[Paddle] Payment failed for ${firebaseUid}`
          );
        }
        break;
      }

      default:
        console.log(`[Paddle] Unhandled event: ${eventType}`);
      }

      res.status(200).send("OK");
    } catch (err) {
      console.error("[Paddle] Webhook processing error:", err);
      res.status(500).send("Internal error");
    }
  }
);
