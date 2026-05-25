package com.apoorvdarshan.calorietracker.services.health

import android.content.Context
import androidx.health.connect.client.HealthConnectClient
import androidx.health.connect.client.PermissionController
import androidx.health.connect.client.changes.DeletionChange
import androidx.health.connect.client.changes.UpsertionChange
import androidx.health.connect.client.permission.HealthPermission
import androidx.health.connect.client.records.ActiveCaloriesBurnedRecord
import androidx.health.connect.client.records.BodyFatRecord
import androidx.health.connect.client.records.MealType as HCMealType
import androidx.health.connect.client.records.NutritionRecord
import androidx.health.connect.client.records.TotalCaloriesBurnedRecord
import androidx.health.connect.client.records.WeightRecord
import androidx.health.connect.client.records.metadata.Metadata
import androidx.health.connect.client.request.AggregateRequest
import androidx.health.connect.client.request.ReadRecordsRequest
import androidx.health.connect.client.time.TimeRangeFilter
import androidx.health.connect.client.units.Energy
import androidx.health.connect.client.units.Mass
import androidx.health.connect.client.units.Percentage
import com.apoorvdarshan.calorietracker.models.BodyFatEntry
import com.apoorvdarshan.calorietracker.models.FoodEntry
import com.apoorvdarshan.calorietracker.models.WeightEntry
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId
import java.time.ZoneOffset
import java.util.UUID
import kotlin.math.roundToInt

/**
 * Single boundary for Health Connect I/O. Port of iOS HealthKitManager.
 *
 * Conventions:
 * - Each sample carries [Metadata.clientRecordId] = "fudai_<uuid>" so we can
 *   dedup in-app vs external writes and delete our own records cleanly.
 * - Nutrition records include macros plus every optional nutrient Health Connect
 *   can represent from Fud AI's food model.
 * - The "typesVersion" integer bumps when we add new record types so existing
 *   users get a re-authorization prompt.
 */
class HealthConnectManager(private val context: Context) {

    private val client: HealthConnectClient? by lazy {
        runCatching { HealthConnectClient.getOrCreate(context) }.getOrNull()
    }

    fun isAvailable(): Boolean =
        HealthConnectClient.getSdkStatus(context) == HealthConnectClient.SDK_AVAILABLE

    val permissions: Set<String> = setOf(
        HealthPermission.getReadPermission(WeightRecord::class),
        HealthPermission.getWritePermission(WeightRecord::class),
        HealthPermission.getReadPermission(NutritionRecord::class),
        HealthPermission.getWritePermission(NutritionRecord::class),
        HealthPermission.getReadPermission(BodyFatRecord::class),
        HealthPermission.getWritePermission(BodyFatRecord::class),
        HealthPermission.getReadPermission(ActiveCaloriesBurnedRecord::class),
        HealthPermission.getReadPermission(TotalCaloriesBurnedRecord::class)
    )

    suspend fun hasAllPermissions(): Boolean {
        val c = client ?: return false
        val granted = c.permissionController.getGrantedPermissions()
        return granted.containsAll(permissions)
    }

    /** Used to build the permission-request ActivityResultContract on the UI side. */
    fun permissionRequestContract() = PermissionController.createRequestPermissionResultContract()

    // -- Weight -----------------------------------------------------------

    suspend fun writeWeight(entry: WeightEntry): Boolean {
        val c = client ?: return false
        val record = WeightRecord(
            time = entry.date,
            zoneOffset = null,
            weight = Mass.kilograms(entry.weightKg),
            metadata = Metadata.manualEntry(clientRecordId = tag(entry.id))
        )
        return runCatching { c.insertRecords(listOf(record)) }.isSuccess
    }

    suspend fun deleteWeight(entryId: UUID): Boolean {
        val c = client ?: return false
        return runCatching {
            c.deleteRecords(
                recordType = WeightRecord::class,
                recordIdsList = emptyList(),
                clientRecordIdsList = listOf(tag(entryId))
            )
        }.isSuccess
    }

    suspend fun readWeights(from: Instant, to: Instant): List<ExternalWeight> {
        val c = client ?: return emptyList()
        val response = runCatching {
            c.readRecords(
                ReadRecordsRequest(
                    recordType = WeightRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(from, to)
                )
            )
        }.getOrNull() ?: return emptyList()
        return response.records.map {
            ExternalWeight(
                time = it.time,
                weightKg = it.weight.inKilograms,
                clientRecordId = it.metadata.clientRecordId
            )
        }
    }

    // -- Body fat ---------------------------------------------------------

    suspend fun writeBodyFat(entry: BodyFatEntry): Boolean {
        val c = client ?: return false
        val record = BodyFatRecord(
            time = entry.date,
            zoneOffset = null,
            // BodyFatRecord wants 0–100 percent, not a fraction.
            percentage = Percentage(entry.bodyFatFraction * 100),
            metadata = Metadata.manualEntry(clientRecordId = tag(entry.id))
        )
        return runCatching { c.insertRecords(listOf(record)) }.isSuccess
    }

    suspend fun deleteBodyFat(entryId: UUID): Boolean {
        val c = client ?: return false
        return runCatching {
            c.deleteRecords(
                recordType = BodyFatRecord::class,
                recordIdsList = emptyList(),
                clientRecordIdsList = listOf(tag(entryId))
            )
        }.isSuccess
    }

    suspend fun readBodyFats(from: Instant, to: Instant): List<ExternalBodyFat> {
        val c = client ?: return emptyList()
        val response = runCatching {
            c.readRecords(
                ReadRecordsRequest(
                    recordType = BodyFatRecord::class,
                    timeRangeFilter = TimeRangeFilter.between(from, to)
                )
            )
        }.getOrNull() ?: return emptyList()
        return response.records.map {
            ExternalBodyFat(
                time = it.time,
                // Convert HC's 0–100 back to our 0–1 fraction convention.
                bodyFatFraction = it.percentage.value / 100.0,
                clientRecordId = it.metadata.clientRecordId
            )
        }
    }

    // -- Nutrition --------------------------------------------------------

    suspend fun writeNutrition(entry: FoodEntry): Boolean {
        val c = client ?: return false
        val start = entry.timestamp
        if (start.isAfter(Instant.now())) return false
        // Nutrition records need a non-zero duration or Health Connect rejects them; use 1 minute.
        val end = start.plusSeconds(60)
        return runCatching {
            val record = NutritionRecord(
                startTime = start,
                endTime = end,
                startZoneOffset = null,
                endZoneOffset = null,
                name = entry.name,
                mealType = mealTypeFor(entry.mealType),
                energy = Energy.kilocalories(entry.calories.toDouble()),
                protein = Mass.grams(entry.protein),
                totalCarbohydrate = Mass.grams(entry.carbs),
                totalFat = Mass.grams(entry.fat),
                dietaryFiber = entry.fiber?.let { Mass.grams(it) },
                sugar = entry.sugar?.let { Mass.grams(it) },
                saturatedFat = entry.saturatedFat?.let { Mass.grams(it) },
                monounsaturatedFat = entry.monounsaturatedFat?.let { Mass.grams(it) },
                polyunsaturatedFat = entry.polyunsaturatedFat?.let { Mass.grams(it) },
                transFat = entry.transFat?.let { Mass.grams(it) },
                cholesterol = entry.cholesterol?.let { Mass.milligrams(it) },
                sodium = entry.sodium?.let { Mass.milligrams(it) },
                potassium = entry.potassium?.let { Mass.milligrams(it) },
                calcium = entry.calcium?.let { Mass.milligrams(it) },
                iron = entry.iron?.let { Mass.milligrams(it) },
                magnesium = entry.magnesium?.let { Mass.milligrams(it) },
                zinc = entry.zinc?.let { Mass.milligrams(it) },
                vitaminA = entry.vitaminA?.let { Mass.micrograms(it) },
                vitaminC = entry.vitaminC?.let { Mass.milligrams(it) },
                vitaminD = entry.vitaminD?.let { Mass.micrograms(it) },
                vitaminB12 = entry.vitaminB12?.let { Mass.micrograms(it) },
                vitaminE = entry.vitaminE?.let { Mass.milligrams(it) },
                vitaminK = entry.vitaminK?.let { Mass.micrograms(it) },
                folate = entry.folate?.let { Mass.micrograms(it) },
                metadata = Metadata.manualEntry(clientRecordId = tag(entry.id))
            )
            c.insertRecords(listOf(record))
        }.isSuccess
    }

    suspend fun updateNutrition(entry: FoodEntry): Boolean {
        // Health Connect doesn't allow true updates across clientRecordIds; delete-then-write
        // preserves the UUID linkage.
        deleteNutrition(entry.id)
        return writeNutrition(entry)
    }

    suspend fun deleteNutrition(entryId: UUID): Boolean {
        val c = client ?: return false
        return runCatching {
            c.deleteRecords(
                recordType = NutritionRecord::class,
                recordIdsList = emptyList(),
                clientRecordIdsList = listOf(tag(entryId))
            )
        }.isSuccess
    }

    // -- Energy burn summary --------------------------------------------

    suspend fun readRecentEnergySummary(days: Int = 14): HealthEnergySummary? {
        val c = client ?: return null
        val requestedDays = maxOf(3, days)
        val zone = ZoneId.systemDefault()
        val today = LocalDate.now(zone)
        val daily = mutableListOf<DailyEnergy>()

        for (offset in requestedDays downTo 1) {
            val date = today.minusDays(offset.toLong())
            val start = date.atStartOfDay(zone).toInstant()
            val end = date.plusDays(1).atStartOfDay(zone).toInstant()
            val result = runCatching {
                c.aggregate(
                    AggregateRequest(
                        metrics = setOf(
                            ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL,
                            TotalCaloriesBurnedRecord.ENERGY_TOTAL
                        ),
                        timeRangeFilter = TimeRangeFilter.between(start, end)
                    )
                )
            }.getOrNull() ?: continue

            val active = result[ActiveCaloriesBurnedRecord.ACTIVE_CALORIES_TOTAL]?.inKilocalories ?: 0.0
            val total = result[TotalCaloriesBurnedRecord.ENERGY_TOTAL]?.inKilocalories?.takeIf { it > 0.0 }
            if (active + (total ?: 0.0) <= 0.0) continue
            daily.add(DailyEnergy(active = active, total = total))
        }

        if (daily.size < 3) return null

        val activeAverage = daily.sumOf { it.active } / daily.size
        val totalValues = daily.mapNotNull { it.total }
        val totalAverage = totalValues.takeIf { it.isNotEmpty() }?.let { values -> values.sum() / values.size }
        val basalAverage = totalAverage?.let { maxOf(0.0, it - activeAverage) }
        return HealthEnergySummary(
            activeAverageCalories = activeAverage.roundToInt(),
            basalAverageCalories = basalAverage?.roundToInt(),
            totalAverageCalories = totalAverage?.roundToInt(),
            daysUsed = daily.size,
            requestedDays = requestedDays
        )
    }

    // -- Change observation (external weight imports) --------------------

    /** Opaque token used to fetch incremental changes. Call once, persist, pass back later.
     *  Now watches both Weight and BodyFat records — a single token reflects upserts of either. */
    suspend fun getChangesToken(): String? {
        val c = client ?: return null
        return runCatching {
            c.getChangesToken(
                androidx.health.connect.client.request.ChangesTokenRequest(
                    recordTypes = setOf(WeightRecord::class, BodyFatRecord::class)
                )
            )
        }.getOrNull()
    }

    /** Returns observed external weight upserts since [sinceToken] plus the next token to use. */
    suspend fun consumeWeightChanges(sinceToken: String): Pair<List<ExternalWeight>, String?>? {
        val c = client ?: return null
        val changes = runCatching { c.getChanges(sinceToken) }.getOrNull() ?: return null
        val upserts = changes.changes.filterIsInstance<UpsertionChange>()
        val results = upserts.mapNotNull { change ->
            val rec = change.record as? WeightRecord ?: return@mapNotNull null
            // Filter out samples we wrote ourselves (prefix matches our tag).
            val cid = rec.metadata.clientRecordId
            if (cid != null && cid.startsWith(CLIENT_PREFIX)) return@mapNotNull null
            ExternalWeight(
                time = rec.time,
                weightKg = rec.weight.inKilograms,
                clientRecordId = cid
            )
        }
        // Log deletions so callers can reconcile if desired.
        @Suppress("UNUSED_VARIABLE")
        val deletions = changes.changes.filterIsInstance<DeletionChange>()
        return results to changes.nextChangesToken
    }

    /** Sibling of [consumeWeightChanges] for BodyFat records. The combined
     *  changes-token watches both record types, so callers should drain both
     *  consumers using the SAME nextChangesToken returned by either call.
     *  We expose them as separate functions only to keep each result strongly typed. */
    suspend fun consumeBodyFatChanges(sinceToken: String): Pair<List<ExternalBodyFat>, String?>? {
        val c = client ?: return null
        val changes = runCatching { c.getChanges(sinceToken) }.getOrNull() ?: return null
        val upserts = changes.changes.filterIsInstance<UpsertionChange>()
        val results = upserts.mapNotNull { change ->
            val rec = change.record as? BodyFatRecord ?: return@mapNotNull null
            val cid = rec.metadata.clientRecordId
            if (cid != null && cid.startsWith(CLIENT_PREFIX)) return@mapNotNull null
            ExternalBodyFat(
                time = rec.time,
                bodyFatFraction = rec.percentage.value / 100.0,
                clientRecordId = cid
            )
        }
        return results to changes.nextChangesToken
    }

    private fun tag(id: UUID): String = "$CLIENT_PREFIX${id}"

    private fun mealTypeFor(meal: com.apoorvdarshan.calorietracker.models.MealType): Int = when (meal) {
        com.apoorvdarshan.calorietracker.models.MealType.BREAKFAST -> HCMealType.MEAL_TYPE_BREAKFAST
        com.apoorvdarshan.calorietracker.models.MealType.LUNCH -> HCMealType.MEAL_TYPE_LUNCH
        com.apoorvdarshan.calorietracker.models.MealType.DINNER -> HCMealType.MEAL_TYPE_DINNER
        com.apoorvdarshan.calorietracker.models.MealType.SNACK -> HCMealType.MEAL_TYPE_SNACK
        com.apoorvdarshan.calorietracker.models.MealType.OTHER -> HCMealType.MEAL_TYPE_UNKNOWN
    }

    companion object {
        private const val CLIENT_PREFIX = "fudai_"

        /** Bump this when we add a new record type so users re-auth.
         *  v2 = added BodyFatRecord read+write permissions.
         *  v3 = added energy burn read permissions. */
        const val CURRENT_TYPES_VERSION = 3
    }
}

private data class DailyEnergy(
    val active: Double,
    val total: Double?
)

data class ExternalWeight(
    val time: Instant,
    val weightKg: Double,
    val clientRecordId: String?
) {
    @Suppress("unused")
    val zoneOffset: ZoneOffset? get() = null
}

data class ExternalBodyFat(
    val time: Instant,
    /** 0–1 fraction, matching UserProfile.bodyFatPercentage convention. */
    val bodyFatFraction: Double,
    val clientRecordId: String?
)

data class HealthEnergySummary(
    val activeAverageCalories: Int,
    val basalAverageCalories: Int?,
    val totalAverageCalories: Int?,
    val daysUsed: Int,
    val requestedDays: Int
)
