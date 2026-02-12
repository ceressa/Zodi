
package com.zodi.app

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.*
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.grid.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.zodi.app.models.ZodiacSign
import com.zodi.app.models.DailyHoroscope
import com.zodi.app.repository.GeminiRepository
import kotlinx.coroutines.launch

// Renk Paleti
val BgColor = Color(0xFF1A0D2E)
val CardColor = Color(0xFF2E1A4D)
val AccentPurple = Color(0xFF7B1FA2)
val AccentBlue = Color(0xFF4FC3F7)
val TextColor = Color(0xFFC5CAE9)

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // API Key sistemden alınır
        val repository = GeminiRepository(System.getenv("API_KEY") ?: "")

        setContent {
            ZodiTheme {
                MainScreen(repository)
            }
        }
    }
}

@Composable
fun MainScreen(repository: GeminiRepository) {
    var selectedSign by remember { mutableStateOf<ZodiacSign?>(null) }
    var horoscopeData by remember { mutableStateOf<DailyHoroscope?>(null) }
    var isLoading by remember { mutableStateOf(false) }
    val scope = rememberCoroutineScope()

    Surface(modifier = Modifier.fillMaxSize(), color = BgColor) {
        if (selectedSign == null) {
            ZodiacSelectionScreen { sign ->
                selectedSign = sign
                isLoading = true
                scope.launch {
                    horoscopeData = repository.getDailyHoroscope(sign)
                    isLoading = false
                }
            }
        } else {
            HoroscopeDetailScreen(
                sign = selectedSign!!,
                data = horoscopeData,
                isLoading = isLoading,
                onBack = { selectedSign = null }
            )
        }
    }
}

@Composable
fun ZodiacSelectionScreen(onSelect: (ZodiacSign) -> Unit) {
    Column(modifier = Modifier.padding(24.dp)) {
        Text(
            "Burcunu Seç",
            style = MaterialTheme.typography.headlineMedium,
            color = AccentBlue,
            fontWeight = FontWeight.Bold
        )
        Spacer(modifier = Modifier.height(16.dp))
        LazyVerticalGrid(
            columns = GridCells.Fixed(3),
            verticalArrangement = Arrangement.spacedBy(12.dp),
            horizontalArrangement = Arrangement.spacedBy(12.dp)
        ) {
            items(ZodiacSign.values()) { sign ->
                ZodiacItem(sign, onSelect)
            }
        }
    }
}

@Composable
fun ZodiacItem(sign: ZodiacSign, onSelect: (ZodiacSign) -> Unit) {
    Card(
        modifier = Modifier
            .aspectRatio(1f)
            .clickable { onSelect(sign) },
        colors = CardDefaults.cardColors(containerColor = CardColor),
        shape = RoundedCornerShape(16.dp)
    ) {
        Column(
            modifier = Modifier.fillMaxSize(),
            horizontalAlignment = Alignment.CenterHorizontally,
            verticalArrangement = Arrangement.Center
        ) {
            Text(sign.displayName, color = TextColor, fontWeight = FontWeight.Bold)
            Text(sign.dates, color = TextColor.copy(alpha = 0.5f), fontSize = 10.sp)
        }
    }
}

@Composable
fun HoroscopeDetailScreen(
    sign: ZodiacSign,
    data: DailyHoroscope?,
    isLoading: Boolean,
    onBack: () -> Unit
) {
    Column(modifier = Modifier.padding(24.dp).verticalScroll(rememberScrollState())) {
        TextButton(onClick = onBack) {
            Text("< Geri Dön", color = AccentPurple)
        }
        
        Text(
            "${sign.displayName} Burcu",
            style = MaterialTheme.typography.headlineLarge,
            color = AccentBlue,
            fontWeight = FontWeight.Bold
        )

        if (isLoading) {
            Box(modifier = Modifier.fillMaxWidth().height(200.dp), contentAlignment = Alignment.Center) {
                CircularProgressIndicator(color = AccentPurple)
            }
        } else if (data != null) {
            Text(
                "\"${data.motto}\"",
                style = MaterialTheme.typography.titleLarge,
                color = AccentBlue,
                modifier = Modifier.padding(vertical = 16.dp)
            )

            Card(
                modifier = Modifier.fillMaxWidth(),
                colors = CardDefaults.cardColors(containerColor = CardColor),
                shape = RoundedCornerShape(24.dp)
            ) {
                Text(
                    data.commentary,
                    modifier = Modifier.padding(20.dp),
                    color = TextColor,
                    lineHeight = 24.sp
                )
            }

            Spacer(modifier = Modifier.height(24.dp))

            // Metrikler (Aşk, Para vb.)
            Row(modifier = Modifier.fillMaxWidth(), horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                MetricCard("Aşk", data.love, Modifier.weight(1f))
                MetricCard("Para", data.money, Modifier.weight(1f))
                MetricCard("Sağlık", data.health, Modifier.weight(1f))
            }
        }
    }
}

@Composable
fun MetricCard(label: String, value: Int, modifier: Modifier) {
    Card(
        modifier = modifier,
        colors = CardDefaults.cardColors(containerColor = CardColor.copy(alpha = 0.5f))
    ) {
        Column(modifier = Modifier.padding(12.dp), horizontalAlignment = Alignment.CenterHorizontally) {
            Text(label, fontSize = 10.sp, color = TextColor.copy(alpha = 0.7f))
            Text("%$value", fontWeight = FontWeight.Bold, color = if(value > 70) Color.Green else AccentBlue)
        }
    }
}

@Composable
fun ZodiTheme(content: @Composable () -> Unit) {
    MaterialTheme(
        colorScheme = darkColorScheme(
            background = BgColor,
            surface = CardColor,
            primary = AccentPurple,
            secondary = AccentBlue
        ),
        content = content
    )
}
