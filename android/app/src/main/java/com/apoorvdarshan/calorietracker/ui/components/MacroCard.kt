package com.apoorvdarshan.calorietracker.ui.components

import androidx.compose.animation.core.animateFloatAsState
import androidx.compose.animation.core.spring
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxWithConstraints
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.text.withStyle
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.apoorvdarshan.calorietracker.models.MacroValueFormatter
import com.apoorvdarshan.calorietracker.ui.theme.AppColors

/**
 * Verbatim port of struct MacroCard in
 * ios/calorietracker/Views/HomeComponents.swift.
 *
 * SwiftUI:
 *   VStack(spacing: 8) {
 *     HStack(alignment: .lastTextBaseline, spacing: 2) {
 *       Text("\(current)")    .font(.system(.title, design: .rounded, weight: .bold))
 *                             .foregroundStyle(gradientColors.first ?? .primary)
 *       Text("/\(goal)g")     .font(.system(.subheadline, design: .rounded, weight: .medium))
 *                             .foregroundStyle(.secondary)
 *     }
 *     GeometryReader { geo in
 *       ZStack(alignment: .leading) {
 *         Capsule().fill(first.opacity(0.12))
 *         Capsule().fill(LinearGradient(colors, .leading, .trailing))
 *                  .frame(width: max(6, geo.size.width * progress))
 *                  .shadow(color: first.opacity(0.3), radius: 4, y: 2)
 *                  .animation(.spring(response: 0.8, dampingFraction: 0.75), value: current)
 *       }
 *     }.frame(height: 6)
 *     Text(label)              .font(.system(.caption,  design: .rounded, weight: .medium))
 *                              .foregroundStyle(.secondary)
 *     Text("\(left)g left")    .font(.system(.caption2, design: .rounded))
 *                              .foregroundStyle(.tertiary)
 *   }.frame(maxWidth: .infinity)
 *
 * iOS font sizes mapped exactly: .title = 28sp bold, .subheadline = 15sp medium,
 * .caption = 12sp medium, .caption2 = 11sp regular. Spring uses dampingRatio=0.75
 * with stiffness ≈ 60 (response 0.8 ≈ stiffness 60 in Compose spec).
 */
@Composable
fun MacroCard(
    label: String,
    current: Double,
    goal: Int,
    unit: String = "g",
    modifier: Modifier = Modifier,
    gradientColors: List<Color> = listOf(AppColors.CalorieStart, AppColors.CalorieEnd)
) {
    val progress = if (goal > 0) (current.toFloat() / goal).coerceIn(0f, 1f) else 0f
    val animated by animateFloatAsState(
        targetValue = progress,
        animationSpec = spring(dampingRatio = 0.75f, stiffness = 60f),
        label = "macroProgress"
    )
    val firstColor = gradientColors.firstOrNull() ?: AppColors.Calorie
    val left = maxOf(0.0, goal.toDouble() - current)
    val currentText = MacroValueFormatter.string(current)
    val goalText = "/$goal$unit"
    val lineLength = currentText.length + goalText.length
    val currentFontSize = when {
        lineLength >= 14 -> 18.sp
        lineLength >= 12 -> 20.sp
        lineLength >= 10 -> 22.sp
        lineLength >= 8 -> 24.sp
        else -> 28.sp
    }
    val goalFontSize = when {
        lineLength >= 14 -> 10.sp
        lineLength >= 12 -> 11.sp
        else -> 12.sp
    }

    Column(
        modifier = modifier.fillMaxWidth(),
        horizontalAlignment = Alignment.CenterHorizontally,
        verticalArrangement = Arrangement.spacedBy(8.dp)
    ) {
        Text(
            text = buildAnnotatedString {
                withStyle(
                    SpanStyle(
                        color = firstColor,
                        fontSize = currentFontSize,
                        fontWeight = FontWeight.Bold
                    )
                ) {
                    append(currentText)
                }
                withStyle(
                    SpanStyle(
                        color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f),
                        fontSize = goalFontSize,
                        fontWeight = FontWeight.Medium
                    )
                ) {
                    append(goalText)
                }
            },
            modifier = Modifier.fillMaxWidth(),
            textAlign = TextAlign.Center,
            maxLines = 1,
            overflow = TextOverflow.Clip,
            softWrap = false
        )

        // GeometryReader { ZStack(alignment: .leading) { ... } }.frame(height: 6)
        BoxWithConstraints(
            modifier = Modifier
                .fillMaxWidth()
                .height(6.dp)
        ) {
            val w = maxWidth
            // Capsule().fill(first.opacity(0.12))
            Box(
                Modifier
                    .fillMaxWidth()
                    .height(6.dp)
                    .clip(CircleShape)
                    .background(firstColor.copy(alpha = 0.12f))
            )
            // Capsule().fill(LinearGradient).frame(width: max(6, geo.size.width * progress))
            //         .shadow(color: first.opacity(0.3), radius: 4, y: 2)
            val barWidth = (w * animated).coerceAtLeast(6.dp)
            Box(
                Modifier
                    .width(barWidth)
                    .height(6.dp)
                    .shadow(
                        elevation = 4.dp,
                        shape = CircleShape,
                        ambientColor = firstColor.copy(alpha = 0.3f),
                        spotColor = firstColor.copy(alpha = 0.3f)
                    )
                    .clip(CircleShape)
                    .background(Brush.horizontalGradient(gradientColors))
            )
        }

        // Text(label) .font(.system(.caption, design: .rounded, weight: .medium)) .foregroundStyle(.secondary)
        Text(
            label,
            fontSize = 12.sp,
            fontWeight = FontWeight.Medium,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.6f)
        )

        // Text("\(left)g left") .font(.system(.caption2, design: .rounded)) .foregroundStyle(.tertiary)
        Text(
            "${MacroValueFormatter.string(left)}$unit left",
            fontSize = 11.sp,
            color = MaterialTheme.colorScheme.onSurface.copy(alpha = 0.4f)
        )
    }
}
