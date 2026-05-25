package com.apoorvdarshan.calorietracker.models

import kotlinx.serialization.Serializable
import java.time.Instant
import java.time.LocalDate
import java.time.ZoneId

/**
 * Small Codable snapshot of today's totals + goals that the widget reads out of DataStore.
 * The main app writes it on every FoodStore / profile change; the widget re-reads on every
 * timeline refresh and on explicit updateAll() calls.
 */
@Serializable
data class WidgetSnapshot(
    @Serializable(with = InstantSerializer::class) val date: Instant,
    @Serializable(with = InstantSerializer::class) val dayStart: Instant,
    val calories: Int,
    val calorieGoal: Int,
    val protein: Double,
    val proteinGoal: Int,
    val carbs: Double,
    val carbsGoal: Int,
    val fat: Double,
    val fatGoal: Int
) {
    val caloriesRemaining: Int get() = maxOf(0, calorieGoal - calories)
    val proteinRemaining: Double get() = maxOf(0.0, proteinGoal.toDouble() - protein)
    val carbsRemaining: Double get() = maxOf(0.0, carbsGoal.toDouble() - carbs)
    val fatRemaining: Double get() = maxOf(0.0, fatGoal.toDouble() - fat)
    val calorieProgress: Double get() = if (calorieGoal > 0) minOf(1.0, calories.toDouble() / calorieGoal) else 0.0
    val proteinProgress: Double get() = if (proteinGoal > 0) minOf(1.0, protein / proteinGoal) else 0.0
    val carbsProgress: Double get() = if (carbsGoal > 0) minOf(1.0, carbs / carbsGoal) else 0.0
    val fatProgress: Double get() = if (fatGoal > 0) minOf(1.0, fat / fatGoal) else 0.0

    val isStale: Boolean get() {
        val snapshotDay = dayStart.atZone(ZoneId.systemDefault()).toLocalDate()
        return snapshotDay != LocalDate.now()
    }

    companion object {
        fun placeholder(): WidgetSnapshot {
            val now = Instant.now()
            return WidgetSnapshot(
                date = now,
                dayStart = todayStart(),
                calories = 1247, calorieGoal = 2000,
                protein = 84.0, proteinGoal = 150,
                carbs = 132.0, carbsGoal = 220,
                fat = 42.0, fatGoal = 70
            )
        }

        fun empty(): WidgetSnapshot {
            val now = Instant.now()
            return WidgetSnapshot(
                date = now,
                dayStart = todayStart(),
                calories = 0, calorieGoal = 2000,
                protein = 0.0, proteinGoal = 150,
                carbs = 0.0, carbsGoal = 220,
                fat = 0.0, fatGoal = 70
            )
        }

        fun todayStart(): Instant =
            LocalDate.now().atStartOfDay(ZoneId.systemDefault()).toInstant()
    }
}
