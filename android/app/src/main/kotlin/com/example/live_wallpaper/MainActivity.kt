package com.example.live_wallpaper

import android.app.WallpaperManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Calendar
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {

    private val CHANNEL = "com.example.live_wallpaper/wallpaper"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "updateSettings" -> {
                    val args = call.arguments as? Map<*, *> ?: run {
                        result.error("INVALID_ARGS", "Invalid arguments", null)
                        return@setMethodCallHandler
                    }

                    val prefs = getSharedPreferences("wallpaper_settings", Context.MODE_PRIVATE)
                    prefs.edit().apply {
                        putInt("dot_color", (args["dotColor"] as? Number)?.toInt() ?: 0xFFFFC107.toInt())
                        putInt("background_color", (args["backgroundColor"] as? Number)?.toInt() ?: 0xFF000000.toInt())
                        putBoolean("show_percentage", args["showPercentage"] as? Boolean ?: true)
                        putBoolean("is_circle", args["isCircle"] as? Boolean ?: true)
                        putInt("grid_density", (args["gridDensity"] as? Number)?.toInt() ?: 10)
                        apply()
                    }

                    // Optional: force redraw immediately
                    val intent = Intent(MyWallpaperService.ACTION_UPDATE)
                    sendBroadcast(intent)

                    result.success(null)
                }

                "setWallpaper" -> {
                    val intent = Intent(WallpaperManager.ACTION_CHANGE_LIVE_WALLPAPER)
                    intent.putExtra(
                        WallpaperManager.EXTRA_LIVE_WALLPAPER_COMPONENT,
                        ComponentName(this@MainActivity, MyWallpaperService::class.java)
                    )
                    startActivity(intent)
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onCreate(savedInstanceState: android.os.Bundle?) {
        super.onCreate(savedInstanceState)
        scheduleDailyWorker()
    }

    private fun scheduleDailyWorker() {
        val request = PeriodicWorkRequestBuilder<DailyUpdateWorker>(24, TimeUnit.HOURS)
            .setInitialDelay(calculateDelayToMidnight(), TimeUnit.MILLISECONDS)
            .build()

        WorkManager.getInstance(this).enqueueUniquePeriodicWork(
            "daily_wallpaper_update",
            ExistingPeriodicWorkPolicy.KEEP,  // or .REPLACE if you want to reset
            request
        )
    }

    private fun calculateDelayToMidnight(): Long {
        val calendar = Calendar.getInstance().apply {
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 5)   // small offset to avoid exact midnight race
            set(Calendar.MILLISECOND, 0)
            if (before(Calendar.getInstance())) {
                add(Calendar.DAY_OF_YEAR, 1)
            }
        }
        return calendar.timeInMillis - System.currentTimeMillis()
    }
}