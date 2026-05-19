package com.apoorvdarshan.calorietracker.ui.components

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.BoxScope
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ColumnScope
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.Icon
import androidx.compose.material3.MaterialTheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.luminance
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.unit.Dp
import androidx.compose.ui.unit.dp
import com.apoorvdarshan.calorietracker.ui.theme.AppColors

@Composable
fun FudGlassSurface(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 24.dp,
    padding: Dp = 16.dp,
    contentAlignment: Alignment = Alignment.TopStart,
    content: @Composable BoxScope.() -> Unit
) {
    val isDark = MaterialTheme.colorScheme.background.luminance() < 0.5f
    val shape = RoundedCornerShape(cornerRadius)
    val baseColor = if (isDark) Color(0xFF17171B).copy(alpha = 0.84f)
                    else Color.White.copy(alpha = 0.94f)
    val shadowColor = if (isDark) Color.Black.copy(alpha = 0.28f)
                      else Color.Black.copy(alpha = 0.08f)
    val sheen = Brush.verticalGradient(
        listOf(
            Color.White.copy(alpha = if (isDark) 0.070f else 0.48f),
            Color.White.copy(alpha = if (isDark) 0.018f else 0.16f),
            AppColors.Calorie.copy(alpha = if (isDark) 0.026f else 0.035f)
        )
    )
    val border = Brush.linearGradient(
        listOf(
            Color.White.copy(alpha = if (isDark) 0.18f else 0.70f),
            Color.White.copy(alpha = if (isDark) 0.045f else 0.22f),
            AppColors.Calorie.copy(alpha = if (isDark) 0.075f else 0.10f)
        )
    )

    Box(
        modifier = modifier
            .shadow(
                elevation = if (isDark) 14.dp else 10.dp,
                shape = shape,
                ambientColor = shadowColor,
                spotColor = shadowColor
            )
            .clip(shape)
            .background(baseColor)
            .background(sheen)
            .border(0.8.dp, border, shape)
            .padding(padding),
        contentAlignment = contentAlignment,
        content = content
    )
}

@Composable
fun FudGlassColumn(
    modifier: Modifier = Modifier,
    cornerRadius: Dp = 24.dp,
    padding: Dp = 16.dp,
    content: @Composable ColumnScope.() -> Unit
) {
    FudGlassSurface(
        modifier = modifier,
        cornerRadius = cornerRadius,
        padding = 0.dp
    ) {
        Column(Modifier.padding(padding), content = content)
    }
}

@Composable
fun FudIconBubble(
    icon: ImageVector,
    modifier: Modifier = Modifier,
    size: Dp = 34.dp,
    iconSize: Dp = 19.dp,
    tint: Color = AppColors.Calorie
) {
    Box(
        modifier = modifier
            .size(size)
            .clip(CircleShape)
            .background(tint.copy(alpha = 0.13f))
            .border(0.7.dp, tint.copy(alpha = 0.22f), CircleShape),
        contentAlignment = Alignment.Center
    ) {
        Icon(
            icon,
            contentDescription = null,
            tint = tint,
            modifier = Modifier.size(iconSize)
        )
    }
}
