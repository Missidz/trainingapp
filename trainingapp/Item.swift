//
//  Item.swift - Modèles de Données SwiftData
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//
//  Ce fichier contient tous les modèles de données de l'application :
//  - User : Profil utilisateur avec système de niveaux et XP
//  - Workout : Séances d'entraînement avec exercices
//  - Exercise : Exercices individuels avec séries/répétitions
//  - Quest : Système de quêtes avec récompenses XP
//  - Achievement : Succès débloqués
//  - Meal/FoodItem : Tracking nutritionnel
//  - NutritionGoals : Objectifs caloriques quotidiens
//

import Foundation
import SwiftData

// MARK: - User Profile (Système de niveaux et progression)
/// Modèle principal pour le profil utilisateur avec système RPG
/// Gère les niveaux, l'expérience, et la progression du joueur
@Model
final class User {
    var name: String                    // Nom du joueur (par défaut "Hunter")
    var level: Int                      // Niveau actuel (commence à 1)
    var experience: Int                 // XP actuel dans le niveau courant
    var experienceToNextLevel: Int      // XP requis pour atteindre le niveau suivant
    var currentTitle: String            // Titre basé sur le niveau (Newbie Hunter → Shadow Monarch)
    var totalWorkouts: Int              // Nombre total d'entraînements effectués
    var createdAt: Date                 // Date de création du profil
    var avatar: String?                 // Chemin vers l'avatar (future fonctionnalité)
    
    /// Initialise un nouveau profil utilisateur
    /// - Parameters:
    ///   - name: Nom du joueur
    ///   - level: Niveau de départ (défaut: 1)
    ///   - experience: XP de départ (défaut: 0)
    init(name: String = "Hunter", level: Int = 1, experience: Int = 0) {
        self.name = name
        self.level = level
        self.experience = experience
        self.experienceToNextLevel = level * 100    // Formule: niveau × 100 XP pour le prochain niveau
        self.currentTitle = "Newbie Hunter"          // Titre de départ
        self.totalWorkouts = 0
        self.createdAt = Date()
        self.avatar = nil
    }
    
    /// Ajoute de l'expérience au joueur et vérifie s'il y a un level up
    /// Utilisée quand le joueur complète des workouts ou réclame des quêtes
    /// - Parameter amount: Quantité d'XP à ajouter
    func gainExperience(_ amount: Int) {
        experience += amount                              // Ajouter l'XP
        checkLevelUp()                                   // Vérifier si level up nécessaire
    }
    
    /// Vérifie et gère les montées de niveau
    /// Système RPG: l'XP excédentaire est reportée au niveau suivant
    private func checkLevelUp() {
        while experience >= experienceToNextLevel {
            level += 1                                    // Monter d'un niveau
            experience -= experienceToNextLevel          // Retirer l'XP utilisée pour le level up
            experienceToNextLevel = level * 100          // Calculer l'XP requise pour le prochain niveau
            updateTitle()                                 // Mettre à jour le titre basé sur le nouveau niveau
        }
    }
    
    /// Met à jour le titre du joueur basé sur son niveau
    /// Système de progression: Newbie → Fighter → Warrior → Elite → Shadow Warrior → Shadow Monarch
    private func updateTitle() {
        switch level {
        case 1...5:
            currentTitle = "Newbie Hunter"      // Débutant (niveaux 1-5)
        case 6...15:
            currentTitle = "Fighter"           // Combattant (niveaux 6-15)
        case 16...30:
            currentTitle = "Warrior"           // Guerrier (niveaux 16-30)
        case 31...50:
            currentTitle = "Elite Hunter"      // Chasseur Elite (niveaux 31-50)
        case 51...80:
            currentTitle = "Shadow Warrior"    // Guerrier de l'Ombre (niveaux 51-80)
        case 81...:
            currentTitle = "Shadow Monarch"    // Monarque de l'Ombre (niveau 81+)
        default:
            currentTitle = "Hunter"            // Titre par défaut
        }
    }
}

// MARK: - Workout (Séance d'entraînement)
/// Modèle pour les séances d'entraînement avec calcul d'XP adaptatif
/// Contient tous les exercices d'une session avec bonus de difficulté et d'éveil
@Model
final class Workout {
    var name: String                        // Nom de la séance
    var date: Date                          // Date de l'entraînement
    var duration: TimeInterval              // Durée en secondes
    var notes: String                       // Notes personnelles
    var isAwakening: Bool                   // Séance "Éveil" pour bonus XP (+50%)
    var experienceGained: Int               // XP total gagné pour cette séance
    var exercises: [Exercise]               // Liste des exercices effectués
    var difficulty: WorkoutDifficulty       // Difficulté (Easy/Normal/Hard/Nightmare)
    
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
    
    /// Calcule l'XP total de la séance avec tous les bonus
    /// Formule complexe incluant: volume + durée + difficulté + éveil
    func calculateExperience() -> Int {
        let baseXP = exercises.reduce(0) { $0 + $1.calculateExperience() }  // XP de tous les exercices
        let durationBonus = Int(duration / 60) * 2                         // 2 XP par minute d'entraînement
        let difficultyMultiplier = difficulty.experienceMultiplier          // Multiplicateur de difficulté
        let awakeningBonus = isAwakening ? 1.5 : 1.0                       // Bonus d'éveil +50%
        
        return Int(Double(baseXP + durationBonus) * difficultyMultiplier * awakeningBonus)
    }
}

// MARK: - Exercise (Exercice individuel)
/// Modèle pour un exercice individuel avec calcul d'XP basé sur le volume
/// Chaque exercice contribue à l'XP total de la séance
@Model
final class Exercise {
    var name: String                        // Nom de l'exercice (ex: "Squat", "Bench Press")
    var sets: Int                           // Nombre de séries
    var reps: Int                           // Répétitions par série
    var weight: Double                      // Poids utilisé en kg
    var restTime: TimeInterval              // Temps de repos en secondes
    var exerciseType: ExerciseType          // Type d'exercice (force, cardio, etc.)
    var notes: String                       // Notes spécifiques à l'exercice
    
    init(name: String, sets: Int = 1, reps: Int = 1, weight: Double = 0, restTime: TimeInterval = 60, exerciseType: ExerciseType = .strength) {
        self.name = name
        self.sets = sets
        self.reps = reps
        self.weight = weight
        self.restTime = restTime
        self.exerciseType = exerciseType
        self.notes = ""
    }
    
    /// Calcule l'XP de cet exercice spécifique
    /// Formule: (séries × reps + bonus poids) × multiplicateur de type
    func calculateExperience() -> Int {
        let baseXP = sets * reps                          // XP de base = volume de travail
        let weightBonus = Int(weight / 5)                 // 1 XP tous les 5kg
        let typeMultiplier = exerciseType.experienceMultiplier  // Multiplicateur selon le type
        
        return Int(Double(baseXP + weightBonus) * typeMultiplier)
    }
    
    /// Calcule le volume total de l'exercice (séries × reps × poids)
    /// Utilisé pour les statistiques et l'analyse de progression
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
/// Système de quêtes quotidiennes et hebdomadaires avec récompenses XP
/// Les quêtes se génèrent automatiquement et se réinitialisent périodiquement
@Model
final class Quest {
    var title: String                       // Titre de la quête (ex: "First Training")
    var questDescription: String            // Description détaillée
    var targetValue: Int                    // Valeur cible à atteindre
    var currentProgress: Int                // Progression actuelle
    var isCompleted: Bool                   // Quête terminée mais pas réclamée
    var isClaimed: Bool                     // Récompense réclamée
    var experienceReward: Int               // XP accordé en récompense
    var questType: QuestType                // Type: daily ou weekly
    var deadline: Date?                     // Date limite (optionnelle)
    var createdAt: Date                     // Date de création
    var completedDate: Date?                // Date de completion
    
    init(title: String, description: String, targetValue: Int, experienceReward: Int, questType: QuestType = .daily, deadline: Date? = nil) {
        self.title = title
        self.questDescription = description
        self.targetValue = targetValue
        self.currentProgress = 0
        self.isCompleted = false
        self.isClaimed = false
        self.experienceReward = experienceReward
        self.questType = questType
        self.deadline = deadline
        self.createdAt = Date()
        self.completedDate = nil
    }
    
    /// Met à jour la progression de la quête
    /// Complète automatiquement la quête quand l'objectif est atteint
    func updateProgress(_ progress: Int) {
        currentProgress = min(currentProgress + progress, targetValue)  // Éviter de dépasser l'objectif
        if currentProgress >= targetValue && !isCompleted {
            isCompleted = true
            completedDate = Date()
        }
    }
    
    /// Calcule le pourcentage de progression (0.0 à 1.0)
    /// Utilisé pour les barres de progression visuelles
    var progressPercentage: Double {
        return Double(currentProgress) / Double(targetValue)
    }
    
    /// Réclame la récompense de la quête
    /// Ne peut être appelée que si la quête est complète et pas encore réclamée
    func claimReward() {
        if isCompleted && !isClaimed {
            isClaimed = true
        }
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

// MARK: - Enums et Types
/// Période d'historique pour les graphiques et statistiques
enum HistoryPeriod: String, CaseIterable, Codable {
    case week = "Week"          // Semaine
    case month = "Month"        // Mois
    case year = "Year"          // Année
}
/// Niveaux de difficulté des entraînements avec multiplicateurs XP
/// Affecte directement l'XP gagné: Easy (80%) → Normal (100%) → Hard (130%) → Nightmare (170%)
enum WorkoutDifficulty: String, CaseIterable, Codable {
    case easy = "Easy"              // Facile - pour débutants ou récupération
    case normal = "Normal"          // Normal - difficulté standard
    case hard = "Hard"              // Difficile - entraînement intense
    case nightmare = "Nightmare"    // Cauchemar - extrême difficulté
    
    /// Multiplicateur d'XP basé sur la difficulté
    var experienceMultiplier: Double {
        switch self {
        case .easy: return 0.8          // -20% XP
        case .normal: return 1.0        // XP normal
        case .hard: return 1.3          // +30% XP
        case .nightmare: return 1.7     // +70% XP
        }
    }
    
    /// Couleur associée à chaque difficulté
    var color: String {
        switch self {
        case .easy: return "#10B981"        // Vert (facile)
        case .normal: return "#4F46E5"      // Bleu (normal)
        case .hard: return "#F59E0B"        // Orange (difficile)
        case .nightmare: return "#EF4444"   // Rouge (nightmare)
        }
    }
}

/// Types d'exercices avec multiplicateurs d'XP spécifiques
/// Différents types d'entraînement donnent différents bonus d'XP
enum ExerciseType: String, CaseIterable, Codable {
    case strength = "Strength"          // Musculation/Force
    case cardio = "Cardio"              // Cardio-vasculaire
    case flexibility = "Flexibility"    // Flexibilité/Étirements
    case endurance = "Endurance"        // Endurance
    
    /// Multiplicateur d'XP selon le type d'exercice
    var experienceMultiplier: Double {
        switch self {
        case .strength: return 1.2      // +20% XP (plus valorisé)
        case .cardio: return 1.0        // XP normal
        case .flexibility: return 0.8   // -20% XP (moins intense)
        case .endurance: return 1.1     // +10% XP
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

/// Types de quêtes avec périodes de renouvellement
/// Différentes fréquences de renouvellement et niveaux de difficulté
enum QuestType: String, CaseIterable, Codable {
    case daily = "Daily"        // Quêtes quotidiennes (se renouvellent chaque jour)
    case weekly = "Weekly"      // Quêtes hebdomadaires (se renouvellent chaque semaine)
    case monthly = "Monthly"    // Quêtes mensuelles (future feature)
    case special = "Special"    // Quêtes événementielles (future feature)
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
