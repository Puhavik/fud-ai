package com.apoorvdarshan.calorietracker.widget

import android.content.Context
import android.content.res.Resources
import androidx.compose.runtime.Composable
import androidx.compose.ui.unit.DpSize
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.glance.GlanceId
import androidx.glance.GlanceModifier
import androidx.glance.GlanceTheme
import androidx.glance.Image
import androidx.glance.ImageProvider
import androidx.glance.LocalSize
import androidx.glance.action.actionStartActivity
import androidx.glance.action.clickable
import androidx.glance.appwidget.GlanceAppWidget
import androidx.glance.appwidget.GlanceAppWidgetReceiver
import androidx.glance.appwidget.SizeMode
import androidx.glance.appwidget.cornerRadius
import androidx.glance.appwidget.provideContent
import androidx.glance.background
import androidx.glance.layout.Alignment
import androidx.glance.layout.Box
import androidx.glance.layout.Column
import androidx.glance.layout.Row
import androidx.glance.layout.Spacer
import androidx.glance.layout.fillMaxHeight
import androidx.glance.layout.fillMaxSize
import androidx.glance.layout.fillMaxWidth
import androidx.glance.layout.height
import androidx.glance.layout.padding
import androidx.glance.layout.size
import androidx.glance.layout.width
import androidx.glance.text.FontWeight
import androidx.glance.text.Text
import androidx.glance.text.TextStyle
import com.apoorvdarshan.calorietracker.MainActivity
import com.apoorvdarshan.calorietracker.R
import com.apoorvdarshan.calorietracker.data.PreferencesStore
import com.apoorvdarshan.calorietracker.models.MacroValueFormatter
import com.apoorvdarshan.calorietracker.models.WidgetSnapshot
import kotlinx.coroutines.flow.first

class CalorieAppWidget : GlanceAppWidget() {

    override val sizeMode: SizeMode = SizeMode.Responsive(
        setOf(SMALL_SIZE, MEDIUM_SIZE)
    )

    override suspend fun provideGlance(context: Context, id: GlanceId) {
        val prefs = PreferencesStore(context)
        val snapshot = prefs.widgetSnapshot.first()
            ?.takeUnless { it.isStale }
            ?: WidgetSnapshot.empty()

        provideContent {
            GlanceTheme {
                CalorieWidgetContent(snapshot)
            }
        }
    }

    companion object {
        val SMALL_SIZE = DpSize(140.dp, 140.dp)
        val MEDIUM_SIZE = DpSize(280.dp, 140.dp)
    }
}

class CalorieWidgetReceiver : GlanceAppWidgetReceiver() {
    override val glanceAppWidget: GlanceAppWidget = CalorieAppWidget()
}

@Composable
private fun CalorieWidgetContent(snapshot: WidgetSnapshot) {
    val size = LocalSize.current
    Box(
        modifier = GlanceModifier
            .fillMaxSize()
            .background(WidgetTheme.backgroundProvider)
            .cornerRadius(22.dp)
            .padding(14.dp)
            .clickable(actionStartActivity<MainActivity>())
    ) {
        if (size.width < CalorieAppWidget.MEDIUM_SIZE.width) {
            CalorieSmall(snapshot)
        } else {
            CalorieMedium(snapshot)
        }
    }
}

@Composable
private fun CalorieSmall(snapshot: WidgetSnapshot) {
    Column(modifier = GlanceModifier.fillMaxSize()) {
        WidgetHeader(iconRes = R.drawable.ic_widget_flame, label = "Today")
        Spacer(modifier = GlanceModifier.height(4.dp))
        Box(
            modifier = GlanceModifier.fillMaxWidth().defaultWeight(),
            contentAlignment = Alignment.Center
        ) {
            RingWithCenter(
                progress = snapshot.calorieProgress.toFloat(),
                ringSizeDp = 92,
                strokeDp = 9,
                centerLarge = snapshot.calories.toString(),
                centerSmall = "/ ${snapshot.calorieGoal}"
            )
        }
        Spacer(modifier = GlanceModifier.height(4.dp))
        Text(
            text = "${snapshot.caloriesRemaining} kcal left",
            style = TextStyle(
                color = WidgetTheme.secondaryTextProvider,
                fontWeight = FontWeight.Medium,
                fontSize = 11.sp
            )
        )
    }
}

@Composable
private fun CalorieMedium(snapshot: WidgetSnapshot) {
    Row(
        modifier = GlanceModifier.fillMaxSize(),
        verticalAlignment = Alignment.CenterVertically
    ) {
        RingWithCenter(
            progress = snapshot.calorieProgress.toFloat(),
            ringSizeDp = 100,
            strokeDp = 9,
            centerLarge = snapshot.calories.toString(),
            centerSmall = "/ ${snapshot.calorieGoal}",
            centerCaption = "kcal"
        )
        Spacer(modifier = GlanceModifier.width(14.dp))
        Column(
            modifier = GlanceModifier.fillMaxHeight().defaultWeight(),
            verticalAlignment = Alignment.CenterVertically
        ) {
            CapsuleMacroRow("Protein", snapshot.protein, snapshot.proteinGoal, snapshot.proteinProgress.toFloat(), unit = "g")
            Spacer(modifier = GlanceModifier.height(8.dp))
            CapsuleMacroRow("Carbs", snapshot.carbs, snapshot.carbsGoal, snapshot.carbsProgress.toFloat(), unit = "g")
            Spacer(modifier = GlanceModifier.height(8.dp))
            CapsuleMacroRow("Fat", snapshot.fat, snapshot.fatGoal, snapshot.fatProgress.toFloat(), unit = "g")
        }
    }
}

// ─── Shared building blocks ────────────────────────────────────────────────

@Composable
internal fun WidgetHeader(iconRes: Int, label: String) {
    Row(verticalAlignment = Alignment.CenterVertically) {
        Image(
            provider = ImageProvider(iconRes),
            contentDescription = null,
            modifier = GlanceModifier.size(12.dp)
        )
        Spacer(modifier = GlanceModifier.width(4.dp))
        Text(
            text = label,
            style = TextStyle(
                color = WidgetTheme.secondaryTextProvider,
                fontWeight = FontWeight.Medium,
                fontSize = 12.sp
            )
        )
    }
}

@Composable
internal fun RingWithCenter(
    progress: Float,
    ringSizeDp: Int,
    strokeDp: Int,
    centerLarge: String,
    centerSmall: String,
    centerCaption: String? = null
) {
    val density = Resources.getSystem().displayMetrics.density
    val sizePx = (ringSizeDp * density).toInt().coerceAtLeast(1)
    val strokePx = strokeDp * density
    val bitmap = ringBitmap(sizePx = sizePx, progress = progress, strokeWidthPx = strokePx)
    val centerLargeFontSize = if (centerLarge.length > 5) 17.sp else 20.sp

    Box(
        modifier = GlanceModifier.size(ringSizeDp.dp),
        contentAlignment = Alignment.Center
    ) {
        Image(
            provider = ImageProvider(bitmap),
            contentDescription = null,
            modifier = GlanceModifier.fillMaxSize()
        )
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Text(
                text = centerLarge,
                style = TextStyle(
                    color = WidgetTheme.primaryTextProvider,
                    fontWeight = FontWeight.Bold,
                    fontSize = centerLargeFontSize
                )
            )
            Text(
                text = centerSmall,
                style = TextStyle(
                    color = WidgetTheme.secondaryTextProvider,
                    fontSize = 10.sp
                )
            )
            if (centerCaption != null) {
                Text(
                    text = centerCaption,
                    style = TextStyle(
                        color = WidgetTheme.secondaryTextProvider,
                        fontWeight = FontWeight.Medium,
                        fontSize = 10.sp
                    )
                )
            }
        }
    }
}

@Composable
internal fun CapsuleMacroRow(label: String, value: Double, goal: Int, progress: Float, unit: String) {
    val valueText = "${MacroValueFormatter.string(value)}${unit} / ${goal}${unit}"
    val valueFontSize = if (valueText.length > 12) 10.sp else 11.sp

    Column(modifier = GlanceModifier.fillMaxWidth()) {
        Row(modifier = GlanceModifier.fillMaxWidth(), verticalAlignment = Alignment.CenterVertically) {
            Text(
                text = label,
                style = TextStyle(
                    color = WidgetTheme.secondaryTextProvider,
                    fontWeight = FontWeight.Medium,
                    fontSize = 11.sp
                ),
                modifier = GlanceModifier.defaultWeight()
            )
            Text(
                text = valueText,
                style = TextStyle(
                    color = WidgetTheme.primaryTextProvider,
                    fontWeight = FontWeight.Medium,
                    fontSize = valueFontSize
                )
            )
        }
        Spacer(modifier = GlanceModifier.height(3.dp))
        CapsuleBar(progress = progress)
    }
}

@Composable
internal fun CapsuleBar(progress: Float, widthDp: Int = 130, heightDp: Int = 6) {
    val density = Resources.getSystem().displayMetrics.density
    val widthPx = (widthDp * density).toInt().coerceAtLeast(2)
    val heightPx = (heightDp * density).toInt().coerceAtLeast(2)
    val bitmap = capsuleBitmap(widthPx, heightPx, progress)
    Image(
        provider = ImageProvider(bitmap),
        contentDescription = null,
        modifier = GlanceModifier.fillMaxWidth().height(heightDp.dp)
    )
}
