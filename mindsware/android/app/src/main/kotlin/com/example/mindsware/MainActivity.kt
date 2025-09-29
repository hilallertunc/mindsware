package com.example.mindsware

import android.app.AppOpsManager
import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.drawable.BitmapDrawable
import android.os.Binder
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.Result
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.*


class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.usage_stats"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "requestUsagePermission" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(null)
                }
                "getUsageStats" -> {
                    getUsageStats(call, result)
                }
                "getAppIcon" -> {
                    getAppIcon(call, result)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun getUsageStats(call: MethodCall, result: Result) {
        if (!hasUsageStatsPermission()) {
            result.error("PERMISSION_REQUIRED", "Kullanım erişimi izni gerekli", null)
            return
        }
    
        val dateMillis = call.argument<Long>("date") ?: System.currentTimeMillis()
        val calendar = Calendar.getInstance().apply {
            timeInMillis = dateMillis
            set(Calendar.HOUR_OF_DAY, 0)
            set(Calendar.MINUTE, 0)
            set(Calendar.SECOND, 0)
            set(Calendar.MILLISECOND, 0)
        }
        val startTime = calendar.timeInMillis
        val endTime = startTime + 1000 * 60 * 60 * 24
    
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val usageStatsList = usageStatsManager.queryUsageStats(
            UsageStatsManager.INTERVAL_DAILY,
            startTime,
            endTime
        )
    
        val appList = mutableListOf<Map<String, Any>>()
        val packageManager = packageManager
    
        for (usageStats in usageStatsList) {
            val totalTime = usageStats.totalTimeInForeground
            if (totalTime > 0) {
                try {
                    val appName = packageManager.getApplicationLabel(
                        packageManager.getApplicationInfo(usageStats.packageName, 0)
                    ).toString()
    
                    appList.add(
                        mapOf(
                            "name" to appName,
                            "packageName" to usageStats.packageName,
                            "timeInForeground" to totalTime
                        )
                    )
                } catch (e: Exception) {
                    continue
                }
            }
        }
    
        result.success(mapOf("apps" to appList))
    }
    

    private fun hasUsageStatsPermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(
                AppOpsManager.OPSTR_GET_USAGE_STATS,
                applicationInfo.uid,
                packageName
            )
        } else {
            appOps.checkOpNoThrow(
                "android:get_usage_stats",
                Binder.getCallingUid(),
                packageName
            )
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }
    private fun getAppIcon(call: MethodCall, result: Result) {
        val packageName = call.argument<String>("packageName")
        try {
            val pm = applicationContext.packageManager
            val drawable = pm.getApplicationIcon(packageName!!)
    
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val width = drawable.intrinsicWidth.takeIf { it > 0 } ?: 96
                    val height = drawable.intrinsicHeight.takeIf { it > 0 } ?: 96
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = android.graphics.Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }
    
            val stream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
            val byteArray = stream.toByteArray()
            result.success(byteArray)
        } catch (e: Exception) {
            result.error("ICON_ERROR", "İkon alınamadı: ${e.message}", null)
        }
    }
    
    
    
}
