package com.example.live_wallpaper

import android.service.wallpaper.WallpaperService
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.RectF
import android.view.SurfaceHolder
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.SharedPreferences
import java.util.Calendar
import kotlin.math.min

class MyWallpaperService : WallpaperService() {

    companion object {
        // This action must match what DailyUpdateWorker sends
        const val ACTION_UPDATE = "com.example.live_wallpaper.UPDATE_WALLPAPER"

        // We keep a reference to the current visible engine
        var currentEngine: MyEngine? = null
    }

    private lateinit var prefs: SharedPreferences
    private val updateReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            currentEngine?.requestRedraw()
        }
    }

    override fun onCreate() {
        super.onCreate()
        prefs = getSharedPreferences("wallpaper_settings", MODE_PRIVATE)
        // Listen for preference changes (from Flutter)
        prefs.registerOnSharedPreferenceChangeListener { _, _ ->
            currentEngine?.requestRedraw()
        }
        // Register for daily update broadcasts
        registerReceiver(updateReceiver, IntentFilter(ACTION_UPDATE))
    }

    override fun onDestroy() {
        unregisterReceiver(updateReceiver)
        super.onDestroy()
    }

    override fun onCreateEngine(): Engine {
        return MyEngine()
    }

    inner class MyEngine : Engine() {

        private val filledPaint = Paint().apply {
            isAntiAlias = true
            style = Paint.Style.FILL
        }

        private val unfilledPaint = Paint().apply {
            isAntiAlias = true
            style = Paint.Style.FILL
        }

        private val textPaint = Paint().apply {
            color = Color.WHITE
            isAntiAlias = true
            textAlign = Paint.Align.CENTER
            setShadowLayer(8f, 2f, 2f, Color.argb(100, 0, 0, 0))
        }

        override fun onCreate(surfaceHolder: SurfaceHolder?) {
            super.onCreate(surfaceHolder)
            currentEngine = this
            requestRedraw()
        }

        override fun onVisibilityChanged(visible: Boolean) {
            super.onVisibilityChanged(visible)
            if (visible) {
                requestRedraw()
            }
        }

        override fun onSurfaceChanged(holder: SurfaceHolder?, format: Int, width: Int, height: Int) {
            super.onSurfaceChanged(holder, format, width, height)
            requestRedraw()
        }

        override fun onSurfaceDestroyed(holder: SurfaceHolder?) {
            currentEngine = null
            super.onSurfaceDestroyed(holder)
        }

        fun requestRedraw() {
            val holder = surfaceHolder ?: return
            if (!isVisible) return

            var canvas: Canvas? = null
            try {
                canvas = holder.lockCanvas()
                if (canvas != null) {
                    drawWallpaper(canvas, holder.surfaceFrame.width(), holder.surfaceFrame.height())
                }
            } finally {
                if (canvas != null) {
                    holder.unlockCanvasAndPost(canvas)
                }
            }
        }

        private fun drawWallpaper(canvas: Canvas, width: Int, height: Int) {
            // Read current settings from SharedPreferences
            val bgColor = prefs.getInt("background_color", Color.BLACK)
            val dotColor = prefs.getInt("dot_color", 0xFFFFC107.toInt()) // amber default
            val showPercent = prefs.getBoolean("show_percentage", true)
            val isCircle = prefs.getBoolean("is_circle", true)
            val columns = prefs.getInt("grid_density", 10)

            val dayOfYear = Calendar.getInstance().get(Calendar.DAY_OF_YEAR)
            val year = Calendar.getInstance().get(Calendar.YEAR)
            val totalDots = if (isLeapYear(year)) 366 else 365
            val filledDots = dayOfYear.coerceAtMost(totalDots)

            // Background
            canvas.drawColor(bgColor)

            // Grid calculation
            val rows = (totalDots + columns - 1) / columns
            val cellWidth = width.toFloat() / columns
            val cellHeight = height.toFloat() / rows
            val dotSize = min(cellWidth, cellHeight) * 0.68f   // 68% of cell → nice spacing

            filledPaint.color = dotColor
            unfilledPaint.color = dotColor
            unfilledPaint.alpha = 70   // faded for unfilled dots

            // Draw all dots
            for (i in 0 until totalDots) {
                val row = i / columns
                val col = i % columns

                val centerX = col * cellWidth + cellWidth / 2f
                val centerY = row * cellHeight + cellHeight / 2f

                val paint = if (i < filledDots) filledPaint else unfilledPaint

                if (isCircle) {
                    canvas.drawCircle(centerX, centerY, dotSize / 2f, paint)
                } else {
                    val left = centerX - dotSize / 2f
                    val top = centerY - dotSize / 2f
                    canvas.drawRoundRect(
                        RectF(left, top, left + dotSize, top + dotSize),
                        12f, 12f, paint   // slight rounding for squares
                    )
                }
            }

            // Draw percentage text in center (if enabled)
            if (showPercent) {
                val percent = (filledDots.toFloat() / totalDots * 100).toInt()
                val text = "$percent%"

                val textSize = min(width, height) * 0.14f
                textPaint.textSize = textSize

                val textY = height / 2f + (textPaint.descent() - textPaint.ascent()) / 2f - textPaint.descent()

                canvas.drawText(text, width / 2f, textY, textPaint)
            }
        }

        private fun isLeapYear(year: Int): Boolean {
            return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
        }
    }
}