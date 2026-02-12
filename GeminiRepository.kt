
package com.zodi.app.repository

import com.google.ai.client.generativeai.GenerativeModel
import com.google.ai.client.generativeai.type.content
import com.google.ai.client.generativeai.type.generationConfig
import com.zodi.app.models.DailyHoroscope
import com.zodi.app.models.ZodiacSign
import kotlinx.serialization.json.Json

class GeminiRepository(private val apiKey: String) {

    private val json = Json { ignoreUnknownKeys = true }
    
    private val model = GenerativeModel(
        modelName = "gemini-3-flash-preview",
        apiKey = apiKey,
        generationConfig = generationConfig {
            responseMimeType = "application/json"
        },
        systemInstruction = content { 
            text("Sen profesyonel bir astrologsun. Kullanıcılara günlük burç yorumları yaparsın. " +
                 "Yanıtları kesinlikle JSON formatında ve akıcı bir Türkçe ile ver.") 
        }
    )

    suspend fun getDailyHoroscope(sign: ZodiacSign): DailyHoroscope? {
        val prompt = "Burç: ${sign.displayName}. Bu burç için günlük motto, detaylı yorum ve (0-100 arası) aşk, para, sağlık, kariyer puanlarını içeren bir analiz üret."
        
        return try {
            val response = model.generateContent(prompt)
            response.text?.let { json.decodeFromString<DailyHoroscope>(it) }
        } catch (e: Exception) {
            null
        }
    }
}
