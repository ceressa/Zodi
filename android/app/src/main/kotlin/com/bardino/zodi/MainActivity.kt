package com.bardino.zodi

import android.content.ContentValues
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val CHANNEL = "com.bardino.zodi/gallery"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "saveToGallery") {
                val bytes = call.argument<ByteArray>("bytes")
                val fileName = call.argument<String>("fileName") ?: "soulmate_sketch_${System.currentTimeMillis()}.png"
                if (bytes != null) {
                    try {
                        val saved = saveImageToGallery(bytes, fileName)
                        if (saved) {
                            result.success(true)
                        } else {
                            result.error("SAVE_ERROR", "Görsel kaydedilemedi", null)
                        }
                    } catch (e: Exception) {
                        result.error("SAVE_ERROR", e.message, null)
                    }
                } else {
                    result.error("INVALID_ARGS", "Görsel verisi bulunamadı", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun saveImageToGallery(bytes: ByteArray, fileName: String): Boolean {
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(MediaStore.Images.Media.RELATIVE_PATH, Environment.DIRECTORY_PICTURES + "/Astro Dozi")
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val resolver = contentResolver
        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
            ?: return false

        resolver.openOutputStream(uri)?.use { outputStream ->
            outputStream.write(bytes)
        } ?: return false

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            contentValues.clear()
            contentValues.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, contentValues, null, null)
        }

        return true
    }
}
