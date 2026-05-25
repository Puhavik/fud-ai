package com.apoorvdarshan.calorietracker.services.update

import android.content.Context
import com.apoorvdarshan.calorietracker.services.ai.FoodAnalysisService
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import okhttp3.OkHttpClient
import okhttp3.Request
import org.json.JSONObject

sealed class AndroidUpdateState {
    object Idle : AndroidUpdateState()
    object Checking : AndroidUpdateState()
    data class UpToDate(val current: String, val latest: String?) : AndroidUpdateState()
    data class Available(val current: String, val latest: String) : AndroidUpdateState()
    data class Failed(val current: String) : AndroidUpdateState()
}

object AndroidUpdateChecker {
    const val RELEASE_PACKAGE_NAME = "com.apoorvdarshan.calorietracker"
    private const val ANDROID_VERSION_MANIFEST_URL = "https://fud-ai.app/android-version.json"
    const val PLAY_STORE_WEB_URL =
        "https://play.google.com/store/apps/details?id=$RELEASE_PACKAGE_NAME"
    const val PLAY_STORE_MARKET_URL = "market://details?id=$RELEASE_PACKAGE_NAME"

    fun currentVersion(context: Context): String =
        context.packageManager.getPackageInfo(context.packageName, 0)
            .versionName
            ?.substringBefore("-")
            ?.ifBlank { null }
            ?: "Unknown"

    suspend fun check(
        current: String,
        client: OkHttpClient = FoodAnalysisService.defaultClient
    ): AndroidUpdateState {
        val req = Request.Builder()
            .url(ANDROID_VERSION_MANIFEST_URL)
            .addHeader("Accept", "application/json")
            .addHeader("User-Agent", "Fud-AI-Android")
            .build()

        return try {
            val raw = withContext(Dispatchers.IO) {
                client.newCall(req).execute().use { response ->
                    if (!response.isSuccessful) error("HTTP ${response.code}")
                    response.body?.string().orEmpty()
                }
            }
            val latest = latestPublishedAndroidVersion(raw)
            when {
                latest == null -> AndroidUpdateState.UpToDate(current = current, latest = null)
                isVersion(latest, current) ->
                    AndroidUpdateState.Available(current = current, latest = latest)
                else -> AndroidUpdateState.UpToDate(current = current, latest = latest)
            }
        } catch (_: Throwable) {
            AndroidUpdateState.Failed(current)
        }
    }

    private fun latestPublishedAndroidVersion(raw: String): String? {
        val root = JSONObject(raw)
        val android = root.optJSONObject("android")
        return android?.optString("latest_published_version")
            ?.takeIf { it.isNotBlank() }
            ?: root.optString("android_latest_published_version")
                .takeIf { it.isNotBlank() }
    }

    private fun isVersion(latest: String, current: String): Boolean {
        val latestParts = latest.split(".").map { it.toIntOrNull() ?: 0 }
        val currentParts = current.split(".").map { it.toIntOrNull() ?: 0 }
        val count = maxOf(latestParts.size, currentParts.size)
        for (index in 0 until count) {
            val latestValue = latestParts.getOrElse(index) { 0 }
            val currentValue = currentParts.getOrElse(index) { 0 }
            if (latestValue > currentValue) return true
            if (latestValue < currentValue) return false
        }
        return false
    }
}
