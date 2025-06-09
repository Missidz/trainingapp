//
//  Models.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import Foundation
import SwiftData

// MARK: - User Profile (Système de niveaux)
@Model
final class User {
    var name: String
    var level: Int
    var experience: Int
    var experienceToNextLevel: Int
    var currentTitle: String
    var totalWorkouts: Int
    var createdAt: Date
    var avatar: String? // Pour l'avatar/personnage
    
    init(name: String = "Hunter", level: Int = 1, experience: Int = 0) {
        self.name = name
        self.level = level
        self.experience = experience
        self.experienceToNextLevel = level * 100 // Formule de progression
        self.currentTitle = "Newbie Hunter"
        self.totalWorkouts = 0
        self.createdAt = Date()
        self.avatar = nil
    }
    
    func gainExperience(_ amount: Int) {
        experience += amount
        checkLevelUp()
    }
    
    private func checkLevelUp() {
        while experience >= experienceToNextLevel {
            level += 1
            experience -= experienceToNextLevel
            experienceToNextLevel = level * 100
            updateTitle()
        }
    }
    
    private func updateTitle() {
        switch level {
        case 1...5:
            currentTitle = "Newbie Hunter"
        case 6...15:
            currentTitle = "Fighter"
        case 16...30:
            currentTitle = "Warrior"
        case 31...50:
            currentTitle = "Elite Hunter"
        case 51...80:
            currentTitle = "Shadow Warrior"
        case 81...:
            currentTitle = "Shadow Monarch"
        default:
            currentTitle = "Hunter"
        }
    }
}

// MARK: - Workout (Séance d'entraînement)
@Model
final class Workout {
    var name: String
    var date: Date
    var duration: TimeInterval // en secondes
    var notes: String
    var isAwakening: Bool // Séance "Éveil" pour bonus XP
    var experienceGained: Int
    var exercises: [Exercise]
    var difficulty: WorkoutDifficulty
    
    init(name: String = "Training Session", date: Date = Date(), duration: TimeInterval = 0, notes: String = "", isAwakening: Bool = false) {
        self.name = name
        self.date = date
        self.duration = duration
        self.notes = notes
        self.isAwakening = isAwakening
        self.experienceGained = 0
        self.exercises = []
        self.difficulty = .normal
    }
    
    func calculateExperience() -> Int {
        let baseXP = exercises.reduce(0) { $0 + $1.calculateExperience() }
        let durationBonus = Int(duration / 60) * 2 // 2 XP par minute
        let difficultyMultiplier = difficulty.experienceMultiplier
        let awakeningBonus = isAwakening ? 1.5 : 1.0
        
        return Int(Double(baseXP + durationBonus) * difficultyMultiplier * awakeningBonus)
    }
}

// MARK: - Exercise (Exercice individuel)
@Model
final class Exercise {
    var name: String
    var sets: Int
    var reps: Int
    var weight: Double // en kg
    var restTime: TimeInterval // en secondes
    var exerciseType: ExerciseType
    var notes: String
    
    init(name: String, sets: Int = 1, reps: Int = 1, weight: Double = 0, restTime: TimeInterval = 60, exerciseType: ExerciseType = .strength) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.exerciseType = exerciseType
        self.notes = ""
    }
    
    func calculateExperience() -> Int {
        let baseXP = sets * reps
        let weightBonus = Int(weight / 5) // 1 XP tous les 5kg
        let typeMultiplier = exerciseType.experienceMultiplier
        
        return Int(Double(baseXP + weightBonus) * typeMultiplier)
    }
    
    var totalVolume: Double {
        return Double(sets * reps) * weight
    }
}

// MARK: - Achievement (Récompenses/Objets)
@Model
final class Achievement {
    var name: String
    var achievementDescription: String
    var icon: String
    var isUnlocked: Bool
    var unlockedDate: Date?
    var category: AchievementCategory
    var rarity: AchievementRarity
    
    init(name: String, description: String, icon: String, category: AchievementCategory = .general, rarity: AchievementRarity = .common) {
        self.name = name
        self.achievementDescription = description
        self.icon = icon
        self.isUnlocked = false
        self.unlockedDate = nil
        self.category = category
        self.rarity = rarity
    }
    
    func unlock() {
        isUnlocked = true
        unlockedDate = Date()
    }
}

// MARK: - Quest (Objectifs/Quêtes)
@Model
final class Quest {
    var title: String
    var questDescription: String
    var targetValue: Int
    var currentProgress: Int
    var isCompleted: Bool
    var experienceReward: Int
    var questType: QuestType
    var deadline: Date?
    var createdAt: Date
    
    init(title: String, description: String, targetValue: Int, experienceReward: Int, questType: QuestType = .daily, deadline: Date? = nil) {
        self.title = title
        self.questDescription = description
        self.targetValue = targetValue
        self.currentProgress = 0
        self.isCompleted = false
        self.experienceReward = experienceReward
        self.questType = questType
        self.deadline = deadline
        self.createdAt = Date()
    }
    
    func updateProgress(_ progress: Int) {
        currentProgress = min(currentProgress + progress, targetValue)
        if currentProgress >= targetValue {
            isCompleted = true
        }
    }
    
    var progressPercentage: Double {
        return Double(currentProgress) / Double(targetValue)
    }
}

// MARK: - Meal (Nutrition Tracking)
@Model
final class Meal {
    var name: String
    var date: Date
    var mealType: MealType
    var foodItems: [FoodItem]
    var totalCalories: Int
    var totalProtein: Double
    var totalCarbs: Double
    var totalFat: Double
    var notes: String
    
    init(name: String = "Meal", date: Date = Date(), mealType: MealType = .breakfast) {
        self.name = name
        self.date = date
        self.mealType = mealType
        self.foodItems = []
        self.totalCalories = 0
        self.totalProtein = 0.0
        self.totalCarbs = 0.0
        self.totalFat = 0.0
        self.notes = ""
    }
    
    func calculateTotals() {
        totalCalories = foodItems.reduce(0) { $0 + $1.totalCalories }
        totalProtein = foodItems.reduce(0) { $0 + $1.totalProtein }
        totalCarbs = foodItems.reduce(0) { $0 + $1.totalCarbs }
        totalFat = foodItems.reduce(0) { $0 + $1.totalFat }
    }
}

// MARK: - Food Item (Individual food/product)
@Model
final class FoodItem {
    var name: String
    var brand: String?
    var barcode: String?
    var servingSize: Double // in grams
    var quantity: Double // multiplier for serving size
    var caloriesPerServing: Int
    var proteinPerServing: Double
    var carbsPerServing: Double
    var fatPerServing: Double
    var isManualEntry: Bool
    var dateAdded: Date
    
    init(name: String, brand: String? = nil, barcode: String? = nil, servingSize: Double = 100.0, quantity: Double = 1.0, caloriesPerServing: Int = 0, proteinPerServing: Double = 0.0, carbsPerServing: Double = 0.0, fatPerServing: Double = 0.0, isManualEntry: Bool = true) {
        self.name = name
        self.brand = brand
        self.barcode = barcode
        self.servingSize = servingSize
        self.quantity = quantity
        self.caloriesPerServing = caloriesPerServing
        self.proteinPerServing = proteinPerServing
        self.carbsPerServing = carbsPerServing
        self.fatPerServing = fatPerServing
        self.isManualEntry = isManualEntry
        self.dateAdded = Date()
    }
    
    var totalCalories: Int {
        return Int(Double(caloriesPerServing) * quantity)
    }
    
    var totalProtein: Double {
        return proteinPerServing * quantity
    }
    
    var totalCarbs: Double {
        return carbsPerServing * quantity
    }
    
    var totalFat: Double {
        return fatPerServing * quantity
    }
    
    var displayName: String {
        if let brand = brand {
            return "\(brand) - \(name)"
        }
        return name
    }
}

// MARK: - Nutrition Goals (Daily targets)
@Model
final class NutritionGoals {
    var dailyCaloriesGoal: Int
    var dailyProteinGoal: Double
    var dailyCarbsGoal: Double
    var dailyFatGoal: Double
    var waterGoal: Double // in liters
    var createdAt: Date
    var updatedAt: Date
    
    init(dailyCaloriesGoal: Int = 2000, dailyProteinGoal: Double = 150.0, dailyCarbsGoal: Double = 200.0, dailyFatGoal: Double = 65.0, waterGoal: Double = 2.5) {
        self.dailyCaloriesGoal = dailyCaloriesGoal
        self.dailyProteinGoal = dailyProteinGoal
        self.dailyCarbsGoal = dailyCarbsGoal
        self.dailyFatGoal = dailyFatGoal
        self.waterGoal = waterGoal
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    func updateGoals(calories: Int, protein: Double, carbs: Double, fat: Double, water: Double) {
        self.dailyCaloriesGoal = calories
        self.dailyProteinGoal = protein
        self.dailyCarbsGoal = carbs
        self.dailyFatGoal = fat
        self.waterGoal = water
        self.updatedAt = Date()
    }
}

// MARK: - Enums
enum HistoryPeriod: String, CaseIterable, Codable {
    case week = "Week"
    case month = "Month"
    case year = "Year"
}
enum WorkoutDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"
    case normal = "Normal"
    case hard = "Hard"
    case nightmare = "Nightmare"
    
    var experienceMultiplier: Double {
        switch self {
        case .easy: return 0.8
        case .normal: return 1.0
        case .hard: return 1.3
        case .nightmare: return 1.7
        }
    }
    
    var color: String {
        switch self {
        case .easy: return "#10B981"
        case .normal: return "#4F46E5"
        case .hard: return "#F59E0B"
        case .nightmare: return "#EF4444"
        }
    }
}

enum ExerciseType: String, CaseIterable, Codable {
    case strength = "Strength"
    case cardio = "Cardio"
    case flexibility = "Flexibility"
    case endurance = "Endurance"
    
    var experienceMultiplier: Double {
        switch self {
        case .strength: return 1.2
        case .cardio: return 1.0
        case .flexibility: return 0.8
        case .endurance: return 1.1
        }
    }
}

enum AchievementCategory: String, CaseIterable, Codable {
    case general = "General"
    case strength = "Strength"
    case endurance = "Endurance"
    case consistency = "Consistency"
    case milestone = "Milestone"
}

enum AchievementRarity: String, CaseIterable, Codable {
    case common = "Common"
    case rare = "Rare"
    case epic = "Epic"
    case legendary = "Legendary"
    
    var color: String {
        switch self {
        case .common: return "#9CA3AF"
        case .rare: return "#4F46E5"
        case .epic: return "#9333EA"
        case .legendary: return "#F59E0B"
        }
    }
}

enum QuestType: String, CaseIterable, Codable {
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case special = "Special"
}

enum MealType: String, CaseIterable, Codable {
    case breakfast = "Breakfast"
    case lunch = "Lunch"
    case dinner = "Dinner"
    case snack = "Snack"
    
    var icon: String {
        switch self {
        case .breakfast: return "sunrise.fill"
        case .lunch: return "sun.max.fill"
        case .dinner: return "moon.fill"
        case .snack: return "leaf.fill"
        }
    }
    
    var color: String {
        switch self {
        case .breakfast: return "#F59E0B"
        case .lunch: return "#10B981"
        case .dinner: return "#6366F1"
        case .snack: return "#8B5CF6"
        }
    }
}
