//
//  NutritionViews.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import SwiftData
import Foundation

// MARK: - Daily Nutrition Card
struct DailyNutritionCard: View {
    let date: Date
    let meals: [Meal]
    
    private var dailyTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let totalCalories = meals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = meals.reduce(0) { $0 + $1.totalProtein }
        let totalCarbs = meals.reduce(0) { $0 + $1.totalCarbs }
        let totalFat = meals.reduce(0) { $0 + $1.totalFat }
        return (totalCalories, totalProtein, totalCarbs, totalFat)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(date, style: .date)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("\(meals.count) meals")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(dailyTotals.calories)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("kcal")
                        .font(.caption2)
                        .foregroundColor(.orange.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", dailyTotals.protein))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                    Text("protein")
                        .font(.caption2)
                        .foregroundColor(.red.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", dailyTotals.carbs))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("carbs")
                        .font(.caption2)
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text(String(format: "%.0f", dailyTotals.fat))
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Text("fat")
                        .font(.caption2)
                        .foregroundColor(.yellow.opacity(0.8))
                }
                
                Spacer()
            }
            
            // Meal breakdown
            VStack(alignment: .leading, spacing: 6) {
                ForEach(meals, id: \.id) { meal in
                    HStack {
                        Image(systemName: meal.mealType.icon)
                            .foregroundColor(Color(hex: meal.mealType.color))
                        
                        Text(meal.mealType.rawValue)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Spacer()
                        
                        Text("\(meal.totalCalories) kcal")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// MARK: - Nutrition Goal Card
struct NutritionGoalCard: View {
    let title: String
    let current: Int
    let goal: Int
    let unit: String
    let color: Color
    let icon: String
    
    private var progress: Double {
        guard goal > 0 else { return 0 }
        return Double(current) / Double(goal)
    }
    
    private var isGoalMet: Bool {
        current >= goal
    }
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                if isGoalMet {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            
            HStack {
                Text("\(current)")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("/ \(goal) \(unit)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
                
                Text("\(Int(progress * 100))%")
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isGoalMet ? .green : color)
            }
            
            // Progress Bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .frame(width: geometry.size.width, height: 8)
                        .opacity(0.3)
                        .foregroundColor(.white)
                    
                    Rectangle()
                        .frame(width: min(CGFloat(progress) * geometry.size.width, geometry.size.width), height: 8)
                        .foregroundColor(isGoalMet ? .green : color)
                        .animation(.spring(), value: progress)
                }
                .cornerRadius(4)
            }
            .frame(height: 8)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isGoalMet ? Color.green.opacity(0.5) : Color.clear, lineWidth: 2)
        )
    }
}

// MARK: - Weekly Goals Progress
struct WeeklyGoalsProgress: View {
    let currentGoals: NutritionGoals
    @Query private var meals: [Meal]
    
    private var weeklyProgress: [Double] {
        let calendar = Calendar.current
        let today = Date()
        var progress: [Double] = []
        
        for i in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -i, to: today) else { continue }
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart) ?? dayStart
            
            let dayMeals = meals.filter { $0.date >= dayStart && $0.date < dayEnd }
            let dayCalories = dayMeals.reduce(0) { $0 + $1.totalCalories }
            let progressPercent = Double(dayCalories) / Double(currentGoals.dailyCaloriesGoal)
            progress.append(min(progressPercent, 1.0))
        }
        
        return progress.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Weekly Progress")
                .font(.headline)
                .foregroundColor(.white)
            
            HStack(spacing: 8) {
                ForEach(0..<7, id: \.self) { index in
                    VStack(spacing: 8) {
                        Rectangle()
                            .fill(Color.green.opacity(0.3))
                            .frame(width: 30, height: 60)
                            .overlay(
                                Rectangle()
                                    .fill(Color.green)
                                    .frame(width: 30, height: CGFloat(weeklyProgress[index]) * 60)
                                    .animation(.spring(), value: weeklyProgress[index]),
                                alignment: .bottom
                            )
                            .cornerRadius(4)
                        
                        Text(dayAbbreviation(for: index))
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
            }
            .frame(maxWidth: .infinity)
            
            Text("Calorie goal achievement over the last 7 days")
                .font(.caption)
                .foregroundColor(.white.opacity(0.6))
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func dayAbbreviation(for index: Int) -> String {
        let calendar = Calendar.current
        let today = Date()
        guard let date = calendar.date(byAdding: .day, value: -(6-index), to: today) else { return "" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "E"
        return String(formatter.string(from: date).prefix(1))
    }
}

// MARK: - Goals Tips Section
struct GoalsTipsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("💡 Nutrition Tips")
                .font(.headline)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                TipRow(
                    icon: "drop.fill",
                    tip: "Aim for 1g of protein per kg of body weight",
                    color: .red
                )
                
                TipRow(
                    icon: "leaf.fill",
                    tip: "Fill half your plate with vegetables",
                    color: .green
                )
                
                TipRow(
                    icon: "heart.fill",
                    tip: "Choose healthy fats like nuts and avocados",
                    color: .yellow
                )
                
                TipRow(
                    icon: "flame.fill",
                    tip: "Eat in a slight calorie surplus to build muscle",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
    }
}

// MARK: - Tip Row
struct TipRow: View {
    let icon: String
    let tip: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(tip)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
        }
    }
}

// MARK: - Edit Nutrition Goals View
struct EditNutritionGoalsView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let currentGoals: NutritionGoals
    
    @State private var calories: String
    @State private var protein: String
    @State private var carbs: String
    @State private var fat: String
    @State private var water: String
    
    init(currentGoals: NutritionGoals) {
        self.currentGoals = currentGoals
        self._calories = State(initialValue: "\(currentGoals.dailyCaloriesGoal)")
        self._protein = State(initialValue: String(format: "%.0f", currentGoals.dailyProteinGoal))
        self._carbs = State(initialValue: String(format: "%.0f", currentGoals.dailyCarbsGoal))
        self._fat = State(initialValue: String(format: "%.0f", currentGoals.dailyFatGoal))
        self._water = State(initialValue: String(format: "%.1f", currentGoals.waterGoal))
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Edit Your Goals")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(spacing: 20) {
                            GoalEditCard(
                                title: "Daily Calories",
                                value: $calories,
                                unit: "kcal",
                                color: .orange,
                                icon: "flame.fill"
                            )
                            
                            GoalEditCard(
                                title: "Daily Protein",
                                value: $protein,
                                unit: "g",
                                color: .red,
                                icon: "heart.fill"
                            )
                            
                            GoalEditCard(
                                title: "Daily Carbs",
                                value: $carbs,
                                unit: "g",
                                color: .blue,
                                icon: "drop.fill"
                            )
                            
                            GoalEditCard(
                                title: "Daily Fat",
                                value: $fat,
                                unit: "g",
                                color: .yellow,
                                icon: "circle.fill"
                            )
                            
                            GoalEditCard(
                                title: "Daily Water",
                                value: $water,
                                unit: "L",
                                color: .cyan,
                                icon: "drop"
                            )
                        }
                        
                        // Preset Goals
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Quick Presets")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 15) {
                                PresetButton(title: "Cutting", subtitle: "1800 cal") {
                                    setPreset(calories: 1800, protein: 140, carbs: 150, fat: 60)
                                }
                                
                                PresetButton(title: "Maintenance", subtitle: "2200 cal") {
                                    setPreset(calories: 2200, protein: 165, carbs: 220, fat: 75)
                                }
                                
                                PresetButton(title: "Bulking", subtitle: "2800 cal") {
                                    setPreset(calories: 2800, protein: 200, carbs: 300, fat: 95)
                                }
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Goals")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveGoals()
                        dismiss()
                    }
                    .foregroundColor(.green)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func setPreset(calories: Int, protein: Int, carbs: Int, fat: Int) {
        self.calories = "\(calories)"
        self.protein = "\(protein)"
        self.carbs = "\(carbs)"
        self.fat = "\(fat)"
    }
    
    private func saveGoals() {
        currentGoals.updateGoals(
            calories: Int(calories) ?? 2000,
            protein: Double(protein) ?? 150.0,
            carbs: Double(carbs) ?? 200.0,
            fat: Double(fat) ?? 65.0,
            water: Double(water) ?? 2.5
        )
        
        try? modelContext.save()
    }
}

// MARK: - Goal Edit Card
struct GoalEditCard: View {
    let title: String
    @Binding var value: String
    let unit: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(color)
                
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
            }
            
            HStack {
                TextField("0", text: $value)
                    .keyboardType(.decimalPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .frame(width: 100)
                
                Text(unit)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                
                Spacer()
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Preset Button
struct PresetButton: View {
    let title: String
    let subtitle: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 5) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text(subtitle)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(Color.green.opacity(0.2))
            .cornerRadius(8)
        }
    }
} 
