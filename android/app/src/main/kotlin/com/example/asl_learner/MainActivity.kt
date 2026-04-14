package com.example.asl_learner

import android.graphics.Bitmap
import android.os.Bundle
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    private val CHANNEL = "hand_detector"
    private lateinit var channel: MethodChannel
    private lateinit var handDetector: HandDetector

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
    super.configureFlutterEngine(flutterEngine)

    handDetector = HandDetector(this)

    // Create a single MethodChannel
    channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)

    // Handle Flutter calls
    channel.setMethodCallHandler { call, result ->

        if (call.method == "sendFrame") {
            try {
                val map = call.arguments as Map<*, *>
                val width = map["width"] as Int
                val height = map["height"] as Int
                val bytes = map["bytes"] as ByteArray

                // Convert RGB → ARGB
                val pixels = IntArray(width * height)
                var i = 0
                var p = 0

                while (i < bytes.size) {
                    val r = bytes[i].toInt() and 0xFF
                    val g = bytes[i + 1].toInt() and 0xFF
                    val b = bytes[i + 2].toInt() and 0xFF

                    pixels[p++] = (0xFF shl 24) or (r shl 16) or (g shl 8) or b
                    i += 3
                }

                val bitmap = Bitmap.createBitmap(
                    pixels,
                    width,
                    height,
                    Bitmap.Config.ARGB_8888
                )

                val landmarks = handDetector.detect(bitmap)

                // Send landmarks to Flutter
                channel.invokeMethod("onHandLandmarks", landmarks)

                result.success(true)
            } catch (e: Exception) {
                Log.e("MainActivity", "Frame processing failed", e)
                result.error("BITMAP_ERROR", e.message, null)
            }
        } else {
            result.notImplemented()
        }
    }
}

}
