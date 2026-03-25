package com.example.live_wallpaper   // ← change to your actual package if different

import android.content.Context
import android.content.Intent
import androidx.work.Worker
import androidx.work.WorkerParameters

/**
 * This worker runs approximately once per day (scheduled as periodic work).
 * Its only purpose is to notify the live wallpaper engine to redraw itself.
 * 
 * Why? Because the day-of-year changes → more dots should be filled.
 * We don't do heavy work here — just send a broadcast that the WallpaperService listens to.
 */
class DailyUpdateWorker(
    context: Context,
    params: WorkerParameters
) : Worker(context, params) {

    override fun doWork(): Result {
        // Create an intent with our custom action
        val updateIntent = Intent(MyWallpaperService.ACTION_UPDATE)
        
        // Send broadcast → MyWallpaperService's receiver will catch it and redraw
        applicationContext.sendBroadcast(updateIntent)

        // Log for debugging (visible in Logcat)
        android.util.Log.d("DailyUpdateWorker", "Daily wallpaper update triggered")

        // Tell WorkManager the task finished successfully
        return Result.success()
    }
}