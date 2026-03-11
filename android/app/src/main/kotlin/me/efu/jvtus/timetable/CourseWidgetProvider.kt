package me.efu.jvtus.timetable

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews
import android.app.PendingIntent
import android.view.View
import org.json.JSONObject
import org.json.JSONArray

class CourseWidgetProvider : AppWidgetProvider() {

    companion object {
        const val PREFS_NAME = "course_widget_prefs"
        const val KEY_DATA = "widget_data_json"
        const val ACTION_UPDATE = "me.efu.jvtus.timetable.ACTION_UPDATE_WIDGET"
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    override fun onReceive(context: Context, intent: Intent) {
        super.onReceive(context, intent)
        if (intent.action == ACTION_UPDATE) {
            val manager = AppWidgetManager.getInstance(context)
            val ids = manager.getAppWidgetIds(
                android.content.ComponentName(context, CourseWidgetProvider::class.java)
            )
            for (id in ids) {
                updateWidget(context, manager, id)
            }
        }
    }

    private fun updateWidget(
        context: Context,
        manager: AppWidgetManager,
        widgetId: Int
    ) {
        val views = RemoteViews(context.packageName, R.layout.widget_course)

        // 点击打开 App
        val launchIntent = context.packageManager.getLaunchIntentForPackage(context.packageName)
        if (launchIntent != null) {
            val pending = PendingIntent.getActivity(
                context, 0, launchIntent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(R.id.widget_root, pending)
        }

        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val json = prefs.getString(KEY_DATA, null)

        if (json != null) {
            try {
                val obj = JSONObject(json)
                renderCourse(views, obj)
                renderTasks(views, obj)
            } catch (_: Exception) {
                showCourseEmpty(views)
                showTasksEmpty(views)
            }
        } else {
            showCourseEmpty(views)
            showTasksEmpty(views)
        }

        manager.updateAppWidget(widgetId, views)
    }

    // ─── 课程区域 ───

    private fun renderCourse(views: RemoteViews, obj: JSONObject) {
        val status = obj.optString("statusLabel", "")
        val name = obj.optString("courseName", "")
        val classroom = obj.optString("classroom", "")
        val timeRange = obj.optString("timeRange", "")

        views.setTextViewText(R.id.tv_status, status)

        if (name.isNotEmpty()) {
            views.setTextViewText(R.id.tv_course_name, name)
            views.setTextViewText(R.id.tv_time, timeRange)
            views.setTextViewText(R.id.tv_classroom, classroom)
            views.setViewVisibility(R.id.tv_course_name, View.VISIBLE)
            views.setViewVisibility(R.id.layout_course_detail, View.VISIBLE)
        } else {
            views.setTextViewText(R.id.tv_course_name, status)
            views.setViewVisibility(R.id.layout_course_detail, View.GONE)
        }
    }

    private fun showCourseEmpty(views: RemoteViews) {
        views.setTextViewText(R.id.tv_status, "课表")
        views.setTextViewText(R.id.tv_course_name, "暂无数据")
        views.setViewVisibility(R.id.layout_course_detail, View.GONE)
    }

    // ─── 待办区域 ───

    private fun renderTasks(views: RemoteViews, obj: JSONObject) {
        val tasks = obj.optJSONArray("tasks") ?: JSONArray()
        val total = obj.optInt("taskTotal", 0)
        val taskViews = intArrayOf(R.id.tv_task_1, R.id.tv_task_2)

        if (total == 0) {
            showTasksEmpty(views)
            return
        }

        views.setViewVisibility(R.id.tv_task_empty, View.GONE)

        for (i in taskViews.indices) {
            if (i < tasks.length()) {
                val taskObj = tasks.getJSONObject(i)
                val title = taskObj.optString("title", "")
                val priority = taskObj.optString("priority", "medium")
                val prefix = when (priority) {
                    "high" -> "\u25CF "
                    "medium" -> "\u25CB "
                    else -> "  "
                }
                views.setTextViewText(taskViews[i], "$prefix$title")
                views.setViewVisibility(taskViews[i], View.VISIBLE)
            } else {
                views.setViewVisibility(taskViews[i], View.GONE)
            }
        }

        if (total > 2) {
            views.setTextViewText(R.id.tv_task_count, "还有 ${total - 2} 项待办...")
            views.setViewVisibility(R.id.tv_task_count, View.VISIBLE)
        } else {
            views.setTextViewText(R.id.tv_task_count, "共 $total 项待办")
            views.setViewVisibility(R.id.tv_task_count, View.VISIBLE)
        }
    }

    private fun showTasksEmpty(views: RemoteViews) {
        views.setTextViewText(R.id.tv_task_empty, "暂无待办事项")
        views.setViewVisibility(R.id.tv_task_empty, View.VISIBLE)
        views.setViewVisibility(R.id.tv_task_1, View.GONE)
        views.setViewVisibility(R.id.tv_task_2, View.GONE)
        views.setViewVisibility(R.id.tv_task_count, View.GONE)
    }
}
