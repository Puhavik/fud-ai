import SwiftUI

struct EditFoodEntryView: View {
    private enum ScrollTarget: Hashable {
        case quantity
    }

    let entry: FoodEntry
    @Environment(FoodStore.self) private var foodStore
    @Environment(\.dismiss) private var dismiss

    // Base values (the entry's nutrition at its logged serving size)
    private let baseCalories: Int
    private let baseProtein: Double
    private let baseCarbs: Double
    private let baseFat: Double
    private let baseServingSizeGrams: Double
    private let baseSugar: Double?
    private let baseAddedSugar: Double?
    private let baseFiber: Double?
    private let baseSaturatedFat: Double?
    private let baseMonounsaturatedFat: Double?
    private let basePolyunsaturatedFat: Double?
    private let baseCholesterol: Double?
    private let baseSodium: Double?
    private let basePotassium: Double?
    private let baseTransFat: Double?
    private let baseCalcium: Double?
    private let baseIron: Double?
    private let baseMagnesium: Double?
    private let baseZinc: Double?
    private let baseVitaminA: Double?
    private let baseVitaminC: Double?
    private let baseVitaminD: Double?
    private let baseVitaminB12: Double?
    private let baseVitaminE: Double?
    private let baseVitaminK: Double?
    private let baseFolate: Double?
    private let baseOmega3: Double?
    private let servingUnitOptions: [ServingUnitOption]

    @State private var name: String
    @State private var servingSizeGrams: Double
    @State private var servingSizeText: String
    @State private var selectedServingUnitID: String
    @State private var quantityFocusRequest = 0
    @State private var isQuantityEditing = false
    @State private var mealType: MealType
    @State private var loggedAt: Date

    private var scale: Double {
        guard baseServingSizeGrams > 0 else { return 1 }
        return servingSizeGrams / baseServingSizeGrams
    }

    private var scaledCalories: Int { Int(round(Double(baseCalories) * scale)) }
    private var scaledProtein: Double { baseProtein * scale }
    private var scaledCarbs: Double { baseCarbs * scale }
    private var scaledFat: Double { baseFat * scale }
    private var scaledSugar: Double? { baseSugar.map { round($0 * scale * 10) / 10 } }
    private var scaledAddedSugar: Double? { baseAddedSugar.map { round($0 * scale * 10) / 10 } }
    private var scaledFiber: Double? { baseFiber.map { round($0 * scale * 10) / 10 } }
    private var scaledSaturatedFat: Double? { baseSaturatedFat.map { round($0 * scale * 10) / 10 } }
    private var scaledMonounsaturatedFat: Double? { baseMonounsaturatedFat.map { round($0 * scale * 10) / 10 } }
    private var scaledPolyunsaturatedFat: Double? { basePolyunsaturatedFat.map { round($0 * scale * 10) / 10 } }
    private var scaledCholesterol: Double? { baseCholesterol.map { round($0 * scale * 10) / 10 } }
    private var scaledSodium: Double? { baseSodium.map { round($0 * scale * 10) / 10 } }
    private var scaledPotassium: Double? { basePotassium.map { round($0 * scale * 10) / 10 } }
    private var scaledTransFat: Double? { baseTransFat.map { round($0 * scale * 10) / 10 } }
    private var scaledCalcium: Double? { baseCalcium.map { round($0 * scale * 10) / 10 } }
    private var scaledIron: Double? { baseIron.map { round($0 * scale * 10) / 10 } }
    private var scaledMagnesium: Double? { baseMagnesium.map { round($0 * scale * 10) / 10 } }
    private var scaledZinc: Double? { baseZinc.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminA: Double? { baseVitaminA.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminC: Double? { baseVitaminC.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminD: Double? { baseVitaminD.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminB12: Double? { baseVitaminB12.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminE: Double? { baseVitaminE.map { round($0 * scale * 10) / 10 } }
    private var scaledVitaminK: Double? { baseVitaminK.map { round($0 * scale * 10) / 10 } }
    private var scaledFolate: Double? { baseFolate.map { round($0 * scale * 10) / 10 } }
    private var scaledOmega3: Double? { baseOmega3.map { round($0 * scale * 10) / 10 } }
    private var selectedServingOption: ServingUnitOption {
        ServingUnitOption.option(matching: selectedServingUnitID, in: servingUnitOptions)
    }
    private var selectedServingQuantity: Double? {
        ServingUnitEditor.parseDecimal(servingSizeText)
    }

    init(entry: FoodEntry) {
        self.entry = entry
        let serving = entry.servingSizeGrams ?? 100
        let normalizedServingUnitOptions = ServingUnitOption.normalizedOptions(entry.servingUnitOptions, totalGrams: serving)
        let initialServingUnitID = ServingUnitOption.initialUnitID(
            preferredUnit: entry.selectedServingUnit,
            options: normalizedServingUnitOptions,
            defaultToGrams: FoodMeasurementSettings.preferGramsByDefault
        )
        self.baseCalories = entry.calories
        self.baseProtein = entry.protein
        self.baseCarbs = entry.carbs
        self.baseFat = entry.fat
        self.baseServingSizeGrams = serving
        self.baseSugar = entry.sugar
        self.baseAddedSugar = entry.addedSugar
        self.baseFiber = entry.fiber
        self.baseSaturatedFat = entry.saturatedFat
        self.baseMonounsaturatedFat = entry.monounsaturatedFat
        self.basePolyunsaturatedFat = entry.polyunsaturatedFat
        self.baseCholesterol = entry.cholesterol
        self.baseSodium = entry.sodium
        self.basePotassium = entry.potassium
        self.baseTransFat = entry.transFat
        self.baseCalcium = entry.calcium
        self.baseIron = entry.iron
        self.baseMagnesium = entry.magnesium
        self.baseZinc = entry.zinc
        self.baseVitaminA = entry.vitaminA
        self.baseVitaminC = entry.vitaminC
        self.baseVitaminD = entry.vitaminD
        self.baseVitaminB12 = entry.vitaminB12
        self.baseVitaminE = entry.vitaminE
        self.baseVitaminK = entry.vitaminK
        self.baseFolate = entry.folate
        self.baseOmega3 = entry.omega3
        self.servingUnitOptions = normalizedServingUnitOptions
        self._name = State(initialValue: entry.name)
        self._servingSizeGrams = State(initialValue: serving)
        self._servingSizeText = State(initialValue: ServingUnitOption.initialQuantityText(
            totalGrams: serving,
            selectedUnitID: initialServingUnitID,
            selectedQuantity: entry.selectedServingQuantity,
            options: normalizedServingUnitOptions
        ))
        self._selectedServingUnitID = State(initialValue: initialServingUnitID)
        self._mealType = State(initialValue: entry.mealType)
        self._loggedAt = State(initialValue: entry.timestamp)
    }

    private static func formatGrams(_ value: Double) -> String {
        if value == value.rounded() {
            return String(Int(value))
        }
        return String(format: "%.1f", value)
    }

    var body: some View {
        NavigationStack {
            ScrollViewReader { scrollProxy in
                List {
                    if let imageData = entry.imageData, let uiImage = UIImage(data: imageData) {
                        Section {
                            HStack {
                                Spacer()
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 200)
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                        }
                    } else if let emoji = entry.emoji {
                        Section {
                            HStack {
                                Spacer()
                                Text(emoji)
                                    .font(.system(size: 80))
                                Spacer()
                            }
                            .listRowBackground(Color.clear)
                        }
                    }

                    Section("Food Details") {
                        HStack {
                            Text("Name")
                            Spacer()
                            TextField("Food name", text: $name)
                                .multilineTextAlignment(.trailing)
                        }
                    }

                    Section("Serving") {
                        HStack {
                            Text("Quantity")
                            Spacer()
                            ServingUnitEditor(
                                quantityText: $servingSizeText,
                                servingSizeGrams: $servingSizeGrams,
                                selectedUnitID: $selectedServingUnitID,
                                unitOptions: servingUnitOptions,
                                focusRequest: quantityFocusRequest,
                                onEditingChanged: { editing in
                                    isQuantityEditing = editing
                                },
                                onClear: {
                                    servingSizeText = ""
                                    quantityFocusRequest += 1
                                }
                            )
                        }
                        .id(ScrollTarget.quantity)
                        if !selectedServingOption.isGramUnit {
                            HStack {
                                Text("Total")
                                Spacer()
                                Text("~\(Self.formatGrams(servingSizeGrams)) g")
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }

                    Section("Nutrition") {
                        NutritionDisplayRow(label: "Calories", value: "\(scaledCalories)", unit: "kcal")
                        NutritionDisplayRow(label: "Protein", value: MacroValueFormatter.string(scaledProtein), unit: "g")
                        NutritionDisplayRow(label: "Carbs", value: MacroValueFormatter.string(scaledCarbs), unit: "g")
                        NutritionDisplayRow(label: "Fat", value: MacroValueFormatter.string(scaledFat), unit: "g")
                    }

                    Section {
                        DisclosureGroup("More Nutrition") {
                            OptionalNutritionDisplayRow(label: "Sugar", value: scaledSugar, unit: "g")
                            OptionalNutritionDisplayRow(label: "Added Sugar", value: scaledAddedSugar, unit: "g")
                            OptionalNutritionDisplayRow(label: "Fiber", value: scaledFiber, unit: "g")
                            OptionalNutritionDisplayRow(label: "Saturated Fat", value: scaledSaturatedFat, unit: "g")
                            OptionalNutritionDisplayRow(label: "Mono Fat", value: scaledMonounsaturatedFat, unit: "g")
                            OptionalNutritionDisplayRow(label: "Poly Fat", value: scaledPolyunsaturatedFat, unit: "g")
                            OptionalNutritionDisplayRow(label: "Cholesterol", value: scaledCholesterol, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Sodium", value: scaledSodium, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Potassium", value: scaledPotassium, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Trans Fat", value: scaledTransFat, unit: "g")
                            OptionalNutritionDisplayRow(label: "Calcium", value: scaledCalcium, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Iron", value: scaledIron, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Magnesium", value: scaledMagnesium, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Zinc", value: scaledZinc, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Vitamin A", value: scaledVitaminA, unit: "mcg")
                            OptionalNutritionDisplayRow(label: "Vitamin C", value: scaledVitaminC, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Vitamin D", value: scaledVitaminD, unit: "mcg")
                            OptionalNutritionDisplayRow(label: "Vitamin B12", value: scaledVitaminB12, unit: "mcg")
                            OptionalNutritionDisplayRow(label: "Vitamin E", value: scaledVitaminE, unit: "mg")
                            OptionalNutritionDisplayRow(label: "Vitamin K", value: scaledVitaminK, unit: "mcg")
                            OptionalNutritionDisplayRow(label: "Folate", value: scaledFolate, unit: "mcg")
                            OptionalNutritionDisplayRow(label: "Omega-3", value: scaledOmega3, unit: "g")
                        }
                        .tint(AppColors.calorie)
                    }

                    Section("Meal") {
                        Picker("Meal Type", selection: $mealType) {
                            ForEach(MealType.allCases, id: \.self) { meal in
                                Label(meal.displayName, systemImage: meal.icon)
                                    .tag(meal)
                            }
                        }
                        .pickerStyle(.menu)
                        .tint(AppColors.calorie)
                    }

                    Section("Date & Time") {
                        DatePicker("Date", selection: $loggedAt, displayedComponents: .date)
                            .tint(AppColors.calorie)
                        DatePicker("Time", selection: $loggedAt, displayedComponents: .hourAndMinute)
                            .tint(AppColors.calorie)
                    }

                }
                .scrollContentBackground(.hidden)
                .background(AppColors.appBackground)
                .background(KeyboardDismissTapInstaller())
                .safeAreaInset(edge: .bottom) {
                    if isQuantityEditing {
                        Color.clear.frame(height: 12)
                    }
                }
                .onChange(of: isQuantityEditing) { _, editing in
                    guard editing else { return }
                    scrollQuantityIntoView(scrollProxy)
                }
                .navigationTitle("Edit Food")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save", action: saveChanges)
                            .font(.system(.body, design: .rounded, weight: .semibold))
                            .tint(AppColors.calorie)
                    }
                }
            }
        }
    }

    private func scrollQuantityIntoView(_ proxy: ScrollViewProxy) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.easeInOut(duration: 0.2)) {
                proxy.scrollTo(ScrollTarget.quantity, anchor: .bottom)
            }
        }
    }

    private func saveChanges() {
        let updated = FoodEntry(
            id: entry.id,
            name: name,
            calories: scaledCalories,
            protein: scaledProtein,
            carbs: scaledCarbs,
            fat: scaledFat,
            timestamp: loggedAt,
            imageData: entry.imageData,
            emoji: entry.emoji,
            source: entry.source,
            mealType: mealType,
            sugar: scaledSugar,
            addedSugar: scaledAddedSugar,
            fiber: scaledFiber,
            saturatedFat: scaledSaturatedFat,
            monounsaturatedFat: scaledMonounsaturatedFat,
            polyunsaturatedFat: scaledPolyunsaturatedFat,
            cholesterol: scaledCholesterol,
            sodium: scaledSodium,
            potassium: scaledPotassium,
            transFat: scaledTransFat,
            calcium: scaledCalcium,
            iron: scaledIron,
            magnesium: scaledMagnesium,
            zinc: scaledZinc,
            vitaminA: scaledVitaminA,
            vitaminC: scaledVitaminC,
            vitaminD: scaledVitaminD,
            vitaminB12: scaledVitaminB12,
            vitaminE: scaledVitaminE,
            vitaminK: scaledVitaminK,
            folate: scaledFolate,
            omega3: scaledOmega3,
            servingSizeGrams: servingSizeGrams,
            servingUnitOptions: servingUnitOptions,
            selectedServingUnit: servingUnitOptions.isEmpty ? nil : selectedServingOption.unit,
            selectedServingQuantity: servingUnitOptions.isEmpty ? nil : selectedServingQuantity
        )
        foodStore.updateEntry(updated)
        dismiss()
    }
}
