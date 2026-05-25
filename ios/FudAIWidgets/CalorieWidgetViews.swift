import SwiftUI
import WidgetKit

/// Match the main app's pink/red theme without importing Theme.swift
/// (which lives in the main app target).
enum WidgetPalette {
    static let calorie = Color(red: 0xFF / 255, green: 0x37 / 255, blue: 0x5F / 255)
    static let calorieLight = Color(red: 0xFF / 255, green: 0x6B / 255, blue: 0x8A / 255)
    static var calorieGradient: LinearGradient {
        LinearGradient(colors: [calorie, calorieLight], startPoint: .topLeading, endPoint: .bottomTrailing)
    }
    static var background: some ShapeStyle {
        Color(.systemBackground)
    }
}

/// Top-level dispatcher — WidgetKit gives us an `Environment(\.widgetFamily)`.
struct CalorieWidgetView: View {
    let entry: CalorieEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        switch family {
        case .systemSmall:       SmallCalorieView(snapshot: entry.snapshot)
        case .systemMedium:      MediumCalorieView(snapshot: entry.snapshot)
        case .accessoryCircular: CircularCalorieView(snapshot: entry.snapshot)
        case .accessoryRectangular: RectangularCalorieView(snapshot: entry.snapshot)
        case .accessoryInline:   InlineCalorieView(snapshot: entry.snapshot)
        default:                 SmallCalorieView(snapshot: entry.snapshot)
        }
    }
}

// MARK: - Home Screen

private struct SmallCalorieView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 6) {
                Image(systemName: "leaf.fill")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundStyle(WidgetPalette.calorieGradient)
                Text("Today")
                    .font(.system(.caption, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
            }

            ZStack {
                Circle()
                    .stroke(WidgetPalette.calorie.opacity(0.15), lineWidth: 10)
                Circle()
                    .trim(from: 0, to: snapshot.calorieProgress)
                    .stroke(WidgetPalette.calorieGradient, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(snapshot.calories)")
                        .font(.system(.title3, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.7)
                        .lineLimit(1)
                    Text("/ \(snapshot.calorieGoal)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            Text("\(snapshot.caloriesRemaining) kcal left")
                .font(.system(.caption2, design: .rounded, weight: .medium))
                .foregroundStyle(.secondary)
        }
    }
}

private struct MediumCalorieView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .stroke(WidgetPalette.calorie.opacity(0.15), lineWidth: 9)
                Circle()
                    .trim(from: 0, to: snapshot.calorieProgress)
                    .stroke(WidgetPalette.calorieGradient, style: StrokeStyle(lineWidth: 9, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                VStack(spacing: 0) {
                    Text("\(snapshot.calories)")
                        .font(.system(.title2, design: .rounded, weight: .bold))
                        .minimumScaleFactor(0.6)
                        .lineLimit(1)
                    Text("/ \(snapshot.calorieGoal)")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text("kcal")
                        .font(.system(.caption2, design: .rounded, weight: .medium))
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 92, height: 92)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(snapshot.displayedHomeNutrients) { nutrient in
                    MacroBar(nutrient: nutrient)
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

private struct MacroBar: View {
    let nutrient: WidgetNutrientValue

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            HStack {
                Text(nutrient.label)
                    .font(.system(.caption2, design: .rounded, weight: .semibold))
                    .foregroundStyle(.secondary)
                Spacer()
                Text(nutrient.displayPair)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.75)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(WidgetPalette.calorie.opacity(0.15))
                    Capsule()
                        .fill(WidgetPalette.calorieGradient)
                        .frame(width: max(4, geo.size.width * nutrient.progress))
                }
            }
            .frame(height: 6)
        }
    }
}

// MARK: - Lock Screen

/// Above-the-clock circular — ring showing today's calorie progress.
private struct CircularCalorieView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            Circle()
                .trim(from: 0, to: snapshot.calorieProgress)
                .stroke(style: StrokeStyle(lineWidth: 3.5, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .padding(3)
            VStack(spacing: 0) {
                Text("\(snapshot.calories)")
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .minimumScaleFactor(0.6)
                    .lineLimit(1)
                Text("kcal")
                    .font(.system(size: 8, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
        .widgetAccentable()
    }
}

private struct RectangularCalorieView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            ZStack {
                Circle()
                    .stroke(.secondary.opacity(0.3), lineWidth: 3)
                Circle()
                    .trim(from: 0, to: snapshot.calorieProgress)
                    .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                Image(systemName: "leaf.fill")
                    .font(.system(size: 13, weight: .bold))
            }
            .frame(width: 42, height: 42)
            .widgetAccentable()

            VStack(alignment: .leading, spacing: 2) {
                Text("\(snapshot.calories)")
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .widgetAccentable()
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text("of \(snapshot.calorieGoal) kcal")
                    .font(.system(.caption2, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Text(snapshot.homeNutrientsSummary)
                    .font(.system(.caption2, design: .rounded, weight: .medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            Spacer(minLength: 0)
        }
    }
}

private struct InlineCalorieView: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        // Inline widgets get exactly one line of text; iOS ignores colors.
        Text("\(snapshot.calories) / \(snapshot.calorieGoal) kcal · \(snapshot.caloriesRemaining) left")
    }
}
