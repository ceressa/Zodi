
package com.zodi.app.models

import kotlinx.serialization.Serializable

@Serializable
enum class ZodiacSign(val displayName: String, val dates: String) {
    KOC("Koç", "21 Mart - 19 Nisan"),
    BOGA("Boğa", "20 Nisan - 20 Mayıs"),
    IKIZLER("İkizler", "21 Mayıs - 20 Haziran"),
    YENGEC("Yengeç", "21 Haziran - 22 Temmuz"),
    ASLAN("Aslan", "23 Temmuz - 22 Ağustos"),
    BASAK("Başak", "23 Ağustos - 22 Eylül"),
    TERAZI("Terazi", "23 Eylül - 22 Ekim"),
    AKREP("Akrep", "23 Ekim - 21 Kasım"),
    YAY("Yay", "22 Kasım - 21 Aralık"),
    OGLAK("Oğlak", "22 Aralık - 19 Ocak"),
    KOVA("Kova", "20 Ocak - 18 Şubat"),
    BALIK("Balık", "19 Şubat - 20 Mart")
}

@Serializable
data class DailyHoroscope(
    val motto: String,
    val commentary: String,
    val love: Int,
    val money: Int,
    val health: Int,
    val career: Int,
    val luckyColor: String,
    val luckyNumber: Int
)
