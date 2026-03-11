package me.efu.jvtus.timetable

import android.content.ComponentName
import android.content.Context
import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {

    companion object {
        private const val CHANNEL = "me.efu.jvtus.timetable/widget"
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidget" -> {
                        val json = call.argument<String>("json") ?: ""
                        updateWidget(json)
                        result.success(true)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun updateWidget(json: String) {
        val prefs = applicationContext.getSharedPreferences(
            CourseWidgetProvider.PREFS_NAME, Context.MODE_PRIVATE
        )
        prefs.edit().putString(CourseWidgetProvider.KEY_DATA, json).apply()

        val intent = Intent(CourseWidgetProvider.ACTION_UPDATE)
        intent.component = ComponentName(applicationContext, CourseWidgetProvider::class.java)
        applicationContext.sendBroadcast(intent)
    }
}
