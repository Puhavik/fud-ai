import SwiftUI

struct WatchNutritionView: View {
    @EnvironmentObject private var receiver: WatchSnapshotReceiver

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                CalorieSummary(snapshot: receiver.snapshot)

                VStack(spacing: 8) {
                    NutrientProgressRow(
                        title: "Protein",
                        value: receiver.snapshot.protein,
                        goal: receiver.snapshot.proteinGoal,
                        unit: "g",
                        progress: receiver.snapshot.proteinProgress,
                        color: .blue
                    )
                    NutrientProgressRow(
                        title: "Carbs",
                        value: receiver.snapshot.carbs,
                        goal: receiver.snapshot.carbsGoal,
                        unit: "g",
                        progress: receiver.snapshot.carbsProgress,
                        color: .green
                    )
                    NutrientProgressRow(
                        title: "Fat",
                        value: receiver.snapshot.fat,
                        goal: receiver.snapshot.fatGoal,
                        unit: "g",
                        progress: receiver.snapshot.fatProgress,
                        color: .orange
                    )
                }

                Text("Updated \(receiver.snapshot.date, style: .time)")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 6)
        }
        .navigationTitle("Fud AI")
        .onAppear {
            receiver.refreshFromDisk()
        }
    }
}

private struct CalorieSummary: View {
    let snapshot: WidgetSnapshot

    var body: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 10) {
                ProgressRing(
                    progress: snapshot.calorieProgress,
                    color: .red,
                    lineWidth: 8
                ) {
                    Image(systemName: "flame.fill")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundStyle(.red)
                }
                .frame(width: 58, height: 58)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text("\(snapshot.calories)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .lineLimit(1)
                        .minimumScaleFactor(0.65)
                    Text("of \(snapshot.calorieGoal) kcal")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
                Spacer(minLength: 0)
            }

            HStack {
                Text("\(snapshot.caloriesRemaining) kcal left")
                    .font(.caption.weight(.semibold))
                Spacer()
            }
        }
    }
}

private struct NutrientProgressRow: View {
    let title: String
    let value: Int
    let goal: Int
    let unit: String
    let progress: Double
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Text(title)
                    .font(.caption.weight(.semibold))
                Spacer(minLength: 4)
                Text("\(value)\(unit) / \(goal)\(unit)")
                    .font(.caption2.monospacedDigit())
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(color.opacity(0.18))
                    Capsule()
                        .fill(color)
                        .frame(width: max(4, geometry.size.width * progress))
                }
            }
            .frame(height: 6)
        }
        .padding(8)
        .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 8, style: .continuous))
    }
}

private struct ProgressRing<Content: View>: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat
    private let content: () -> Content

    init(
        progress: Double,
        color: Color,
        lineWidth: CGFloat,
        @ViewBuilder content: @escaping () -> Content
    ) {
        self.progress = progress
        self.color = color
        self.lineWidth = lineWidth
        self.content = content
    }

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
            content()
        }
    }
}
