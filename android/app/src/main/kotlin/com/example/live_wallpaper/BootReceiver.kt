package com.example.live_wallpaper

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import androidx.work.ExistingPeriodicWorkPolicy
import androidx.work.PeriodicWorkRequestBuilder
import androidx.work.WorkManager
import java.util.concurrent.TimeUnit

/**
 * This receiver runs when the device finishes booting.
 * It re-schedules the daily wallpaper update worker.
 *
 * Without this, after phone restart the automatic daily redraw would stop working
 * until the app is opened again.
 */
class BootReceiver : BroadcastReceiver() {

    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED) {
            // Re-schedule the daily worker (same as in MainActivity)
            val request = PeriodicWorkRequestBuilder<DailyUpdateWorker>(24, TimeUnit.HOURS)
                .build()

            WorkManager.getInstance(context).enqueueUniquePeriodicWork(
                "daily_wallpaper_update",
                ExistingPeriodicWorkPolicy.KEEP,  // KEEP = don't replace if already scheduled
                request
            )

            android.util.Log.d("BootReceiver", "Daily wallpaper worker re-scheduled after boot")
        }
    }
}