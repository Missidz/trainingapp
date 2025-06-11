//
//  ProgressViews.swift - Système de Progression et Quêtes
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//
//  Ce fichier contient:
//  - Dashboard de progression avec niveau et XP
//  - Système de quêtes quotidiennes et hebdomadaires
//  - Statistiques détaillées et graphiques
//  - Gestion des récompenses et achievements
//  - Interface de progression utilisateur
//

import SwiftUI
import SwiftData
import Charts

/// Dashboard principal de progression avec niveau, statistiques et graphiques
/// Interface centralisée pour visualiser l'évolution du joueur
struct ProgressDashboard: View {
    @State private var selectedTimeframe = "Week"          // Période sélectionnée pour les graphiques
    let timeframes = ["Week", "Month", "Year"]             // Options de période
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Level Progress Card
                        LevelProgressCard()
                        
                        // Time Selector
                        TimeframeSelector(
                            selectedTimeframe: $selectedTimeframe,
                            timeframes: timeframes
                        )
                        
                        // Stats Grid
                        StatsGrid()
                        
                        // Workout Frequency Chart
                        WorkoutFrequencyChart(timeframe: selectedTimeframe)
                        
                        // Achievements Preview
                        AchievementsPreview()
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Level Progress Card
struct LevelProgressCard: View {
    @Query private var workouts: [Workout]
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var totalXP: Int {
        let workoutXP = workouts.reduce(0) { $0 + $1.experienceGained }
        let userXP = currentUser?.experience ?? 0
        return workoutXP + userXP
    }
    
    private var currentLevel: Int {
        if let user = currentUser {
            return user.level
        } else {
            return max(1, totalXP / 100 + 1)
        }
    }
    
    private var currentXPInLevel: Int {
        if let user = currentUser {
            return user.experience
        } else {
            return totalXP % 100
        }
    }
    
    private var maxXP: Int {
        if let user = currentUser {
            return user.experienceToNextLevel
        } else {
            return 100
        }
    }
    
    private var totalWorkouts: Int {
        workouts.count
    }
    
    private var levelTitle: String {
        if let user = currentUser {
            return user.currentTitle
        } else {
            switch currentLevel {
            case 1...5:
                return "Newbie Hunter"
            case 6...15:
                return "Fighter"
            case 16...30:
                return "Warrior"
            case 31...50:
                return "Elite Hunter"
            case 51...80:
                return "Shadow Warrior"
            case 81...:
                return "Shadow Monarch"
            default:
                return "Hunter"
            }
        }
    }
    
    private var nextLevelTitle: String {
        switch currentLevel + 1 {
        case 6:
            return "Fighter"
        case 16:
            return "Warrior"
        case 31:
            return "Elite Hunter"
        case 51:
            return "Shadow Warrior"
        case 81:
            return "Shadow Monarch"
        default:
            return "Next Level"
        }
    }
    
    private var xpToNextLevel: Int {
        if let user = currentUser {
            return user.experienceToNextLevel - user.experience
        } else {
            let nextLevelThreshold = currentLevel * 100
            return nextLevelThreshold - totalXP
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hunter Level")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text(levelTitle)
                        .font(.subheadline)
                        .foregroundColor(.purple.opacity(0.8))
                    
                    Text("Level \(currentLevel)")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                        .shadow(color: .blue.opacity(0.5), radius: 5)
                }
                
                Spacer()
                
                VStack {
                    ZStack {
                        Circle()
                            .stroke(Color.white.opacity(0.3), lineWidth: 8)
                            .frame(width: 80, height: 80)
                        
                        Circle()
                            .trim(from: 0, to: CGFloat(currentXPInLevel) / CGFloat(maxXP))
                            .stroke(
                                LinearGradient(
                                    colors: [.blue, .purple],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(), value: currentXPInLevel)
                        
                        Text("\(Int((Double(currentXPInLevel) / Double(maxXP)) * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(currentXPInLevel)/\(maxXP) XP")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Next Level Preview
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Next: \(nextLevelTitle) (Level \(currentLevel + 1))")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(xpToNextLevel) XP to go")
                    .font(.caption)
                    .foregroundColor(.blue.opacity(0.8))
            }
            .padding(12)
            .background(Color.white.opacity(0.05))
            .cornerRadius(8)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
    }
}

// MARK: - Timeframe Selector
struct TimeframeSelector: View {
    @Binding var selectedTimeframe: String
    let timeframes: [String]
    
    var body: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(timeframes, id: \.self) { timeframe in
                Text(timeframe).tag(timeframe)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .padding()
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Stats Grid
struct StatsGrid: View {
    @Query private var workouts: [Workout]
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var totalXP: Int {
        let workoutXP = workouts.reduce(0) { $0 + $1.experienceGained }
        let userXP = currentUser?.experience ?? 0
        return workoutXP + userXP
    }
    
    private var currentStreak: Int {
        let calendar = Calendar.current
        let sortedWorkouts = workouts.sorted { $0.date > $1.date }
        
        var streak = 0
        var currentDate = Date()
        
        for workout in sortedWorkouts {
            let workoutDay = calendar.startOfDay(for: workout.date)
            let currentDay = calendar.startOfDay(for: currentDate)
            
            if calendar.dateInterval(of: .day, for: workoutDay)?.contains(currentDay) == true ||
               calendar.dateInterval(of: .day, for: calendar.date(byAdding: .day, value: -1, to: currentDay) ?? currentDate)?.contains(workoutDay) == true {
                streak += 1
                currentDate = workout.date
            } else {
                break
            }
        }
        
        return streak
    }
    
    private var bestWeek: Int {
        let calendar = Calendar.current
        var weeklyWorkouts: [Date: Int] = [:]
        
        for workout in workouts {
            let weekStart = calendar.dateInterval(of: .weekOfYear, for: workout.date)?.start ?? workout.date
            weeklyWorkouts[weekStart, default: 0] += 1
        }
        
        return weeklyWorkouts.values.max() ?? 0
    }
    
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            EnhancedStatCard(
                title: "Total Workouts",
                value: "\(workouts.count)",
                icon: "dumbbell.fill",
                color: .blue
            )
            
            EnhancedStatCard(
                title: "Total XP",
                value: "\(totalXP)",
                icon: "star.fill",
                color: .purple
            )
            
            EnhancedStatCard(
                title: "Streak",
                value: "\(currentStreak) days",
                icon: "flame.fill",
                color: .orange
            )
            
            EnhancedStatCard(
                title: "Best Week",
                value: "\(bestWeek) workouts",
                icon: "trophy.fill",
                color: .yellow
            )
        }
    }
}

// MARK: - Enhanced Stat Card
struct EnhancedStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.2))
                .cornerRadius(8)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
                .multilineTextAlignment(.center)
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Workout Frequency Chart
struct WorkoutFrequencyChart: View {
    let timeframe: String
    
    // Mock data
    let weeklyData = [
        WorkoutData(day: "Mon", count: 0),
        WorkoutData(day: "Tue", count: 0),
        WorkoutData(day: "Wed", count: 0),
        WorkoutData(day: "Thu", count: 0),
        WorkoutData(day: "Fri", count: 0),
        WorkoutData(day: "Sat", count: 0),
        WorkoutData(day: "Sun", count: 0)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Workout Frequency")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Simple bar chart representation
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(weeklyData, id: \.day) { data in
                    VStack(spacing: 5) {
                        Rectangle()
                            .fill(data.count > 0 ? .blue : Color.white.opacity(0.3))
                            .frame(width: 30, height: max(CGFloat(data.count * 40), 8))
                            .cornerRadius(4)
                        
                        Text(data.day)
                            .font(.caption2)
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
            }
            .frame(height: 100)
            .frame(maxWidth: .infinity)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

struct WorkoutData {
    let day: String
    let count: Int
}

// MARK: - Achievements Preview
struct AchievementsPreview: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Recent Achievements")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button("View All") {
                    // Navigate to achievements
                }
                .font(.caption)
                .foregroundColor(.blue)
            }
            
            VStack(spacing: 10) {
                Text("No achievements yet")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                
                Text("Complete your first workout to start earning rewards!")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Quests Dashboard
/// Interface principale du système de quêtes avec onglets Daily/Weekly/Achievements
/// Gère la création automatique des quêtes, le tracking de progression et les récompenses
struct QuestsDashboard: View {
    @Environment(\.modelContext) private var modelContext  // Contexte SwiftData
    @Query private var quests: [Quest]                     // Toutes les quêtes
    @Query private var workouts: [Workout]                 // Workouts pour calculer progression
    @State private var selectedTab = 0                     // Onglet sélectionné (Daily/Weekly/Achievements)
    @State private var showResetConfirmation = false       // Confirmation de reset (debug)
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
                    // Debug Reset Button
                    HStack {
                        Spacer()
                        Button(action: {
                            showResetConfirmation = true
                        }) {
                            HStack(spacing: 6) {
                                Image(systemName: "arrow.clockwise")
                                Text("Reset Debug")
                            }
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.red.opacity(0.2))
                            .cornerRadius(8)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Quest Tabs
                    Picker("Quest Type", selection: $selectedTab) {
                        Text("Daily").tag(0)
                        Text("Weekly").tag(1)
                        Text("Achievements").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        DailyQuestsView(quests: quests, workouts: workouts, modelContext: modelContext)
                            .tag(0)
                        
                        WeeklyQuestsView(quests: quests, workouts: workouts, modelContext: modelContext)
                            .tag(1)
                        
                        AchievementsView(quests: quests)
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Quests & Goals")
        }
        .preferredColorScheme(.dark)
        .onAppear {
            initializeQuestsIfNeeded()
            updateQuestProgress()
        }
        .alert("Reset Debug", isPresented: $showResetConfirmation) {
            Button("Cancel", role: .cancel) { }
            Button("Reset", role: .destructive) {
                resetAllData()
            }
        } message: {
            Text("Cela va supprimer toutes les données (utilisateurs, quêtes, workouts) et recréer les quêtes par défaut. Cette action est irréversible.")
        }
    }
    
    /// Initialise les quêtes par défaut si aucune n'existe
    /// Appelée automatiquement au premier lancement
    private func initializeQuestsIfNeeded() {
        if quests.isEmpty {
            createDefaultQuests()
        }
    }
    
    /// Crée les quêtes par défaut (daily et weekly)
    /// Système avec 3 quêtes quotidiennes et 3 hebdomadaires
    private func createDefaultQuests() {
        // Quêtes journalières (se renouvellent chaque jour)
        let dailyQuests = [
            Quest(title: "Premier Entraînement", description: "Complétez votre première séance", targetValue: 1, experienceReward: 50, questType: .daily),
            Quest(title: "Volume Builder", description: "Complétez 50 répétitions au total", targetValue: 50, experienceReward: 75, questType: .daily),
            Quest(title: "Endurance", description: "Entraînez-vous pendant 30 minutes", targetValue: 30, experienceReward: 60, questType: .daily)
        ]
        
        // Quêtes hebdomadaires (plus difficiles, plus de récompenses)
        let weeklyQuests = [
            Quest(title: "Guerrier Hebdomadaire", description: "Complétez 5 entraînements cette semaine", targetValue: 5, experienceReward: 250, questType: .weekly),
            Quest(title: "Constructeur de Force", description: "Soulevez un total de 1000kg cette semaine", targetValue: 1000, experienceReward: 300, questType: .weekly),
            Quest(title: "Consistance", description: "Entraînez-vous 3 jours différents", targetValue: 3, experienceReward: 200, questType: .weekly)
        ]
        
        // Insérer les quêtes
        for quest in dailyQuests + weeklyQuests {
            modelContext.insert(quest)
        }
        
        try? modelContext.save()
    }
    
    private func updateQuestProgress() {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        let startOfWeek = calendar.dateInterval(of: .weekOfYear, for: today)?.start ?? today
        
        // Workouts d'aujourd'hui
        let todayWorkouts = workouts.filter { $0.date >= startOfDay && $0.date < endOfDay }
        
        // Workouts de cette semaine
        let weekWorkouts = workouts.filter { $0.date >= startOfWeek }
        
        for quest in quests {
            if quest.isCompleted { continue }
            
            var newProgress = 0
            
            switch quest.questType {
            case .daily:
                switch quest.title {
                case "Premier Entraînement":
                    newProgress = todayWorkouts.count
                case "Volume Builder":
                    newProgress = todayWorkouts.reduce(0) { total, workout in
                        total + workout.exercises.reduce(0) { $0 + ($1.sets * $1.reps) }
                    }
                case "Endurance":
                    newProgress = Int(todayWorkouts.reduce(0) { $0 + $1.duration } / 60)
                default:
                    break
                }
                
            case .weekly:
                switch quest.title {
                case "Guerrier Hebdomadaire":
                    newProgress = weekWorkouts.count
                case "Constructeur de Force":
                    newProgress = Int(weekWorkouts.reduce(0) { total, workout in
                        total + workout.exercises.reduce(0) { $0 + Double($1.sets * $1.reps) * $1.weight }
                    })
                case "Consistance":
                    let uniqueDays = Set(weekWorkouts.map { calendar.startOfDay(for: $0.date) })
                    newProgress = uniqueDays.count
                default:
                    break
                }
                
            default:
                break
            }
            
            // Mettre à jour le progrès
            quest.updateProgress(newProgress)
            
            // Vérifier si la quête est complétée et donner XP
            if quest.isCompleted && quest.currentProgress >= quest.targetValue {
                completeQuest(quest)
            }
        }
        
        try? modelContext.save()
    }
    
    private func completeQuest(_ quest: Quest) {
        // Logic pour donner l'XP sera gérée par le système principal
        // Pour l'instant, juste marquer comme complétée
        print("Quête complétée: \(quest.title) - +\(quest.experienceReward) XP")
    }
    
    private func resetAllData() {
        print("🔄 [RESET] Début du reset de toutes les données...")
        
        do {
            // Supprimer tous les utilisateurs
            let users = try modelContext.fetch(FetchDescriptor<User>())
            for user in users {
                modelContext.delete(user)
            }
            print("🗑️ [RESET] \(users.count) utilisateurs supprimés")
            
            // Supprimer toutes les quêtes
            let allQuests = try modelContext.fetch(FetchDescriptor<Quest>())
            for quest in allQuests {
                modelContext.delete(quest)
            }
            print("🗑️ [RESET] \(allQuests.count) quêtes supprimées")
            
            // Supprimer tous les workouts
            let allWorkouts = try modelContext.fetch(FetchDescriptor<Workout>())
            for workout in allWorkouts {
                modelContext.delete(workout)
            }
            print("🗑️ [RESET] \(allWorkouts.count) workouts supprimés")
            
            // Sauvegarder les suppressions
            try modelContext.save()
            print("💾 [RESET] Suppressions sauvegardées")
            
            // Recréer les quêtes par défaut
            createDefaultQuests()
            print("✅ [RESET] Nouvelles quêtes créées")
            
            print("🎉 [RESET] Reset complet terminé avec succès!")
            
        } catch {
            print("❌ [RESET] Erreur lors du reset: \(error)")
        }
    }
}

// MARK: - Daily Quests
struct DailyQuestsView: View {
    let quests: [Quest]
    let workouts: [Workout]
    let modelContext: ModelContext
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var dailyQuests: [Quest] {
        quests.filter { $0.questType == .daily && !$0.isClaimed }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if dailyQuests.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "target")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Aucune quête journalière")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Les quêtes apparaîtront bientôt !")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(40)
                } else {
                    ForEach(dailyQuests, id: \.id) { quest in
                        InteractiveQuestCard(
                            quest: quest,
                            onClaim: {
                                claimQuestReward(quest)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private func claimQuestReward(_ quest: Quest) {
        print("🔍 [DAILY] TENTATIVE RÉCLAMATION: '\(quest.title)'")
        print("🔍 [DAILY] État: isCompleted=\(quest.isCompleted), isClaimed=\(quest.isClaimed)")
        print("🔍 [DAILY] Progrès: \(quest.currentProgress)/\(quest.targetValue)")
        print("🔍 [DAILY] ID de la quête: \(quest.id)")
        print("🔍 [DAILY] Récompense XP: \(quest.experienceReward)")
        
        // Debugging spécial pour "Premier Entraînement"
        if quest.title == "Premier Entraînement" {
            print("🎯 [SPECIAL] Cette quête est 'Premier Entraînement'")
            print("🎯 [SPECIAL] Nombre d'utilisateurs existants: \(users.count)")
            if let user = currentUser {
                print("🎯 [SPECIAL] Utilisateur actuel trouvé: niveau \(user.level), XP \(user.experience)")
            }
        }
        
        if quest.isCompleted && !quest.isClaimed {
            print("✅ [DAILY] Conditions remplies, réclamation en cours...")
            
            // Capturer l'XP avant pour comparaison
            let xpBefore = currentUser?.experience ?? 0
            
            // Marquer la quête comme réclamée
            quest.claimReward()
            print("✅ [DAILY] Quête marquée comme réclamée")
            
            // Ajouter l'XP au système global
            if let user = currentUser {
                print("📝 [DAILY] Utilisateur trouvé, ajout de \(quest.experienceReward) XP...")
                print("📊 [DAILY] Niveau avant: \(user.level), XP avant: \(user.experience)/\(user.experienceToNextLevel)")
                user.gainExperience(quest.experienceReward)
                print("📊 [DAILY] Niveau après: \(user.level), XP après: \(user.experience)/\(user.experienceToNextLevel)")
            } else {
                print("⚠️ [DAILY] Aucun utilisateur trouvé, création d'un nouveau...")
                // Créer un utilisateur si aucun n'existe
                let newUser = User(name: "Hunter", level: 1, experience: 0)
                newUser.gainExperience(quest.experienceReward)
                modelContext.insert(newUser)
                print("✅ [DAILY] Nouvel utilisateur créé avec niveau \(newUser.level), XP \(newUser.experience)")
            }
            
            // Sauvegarder les changements
            do {
                try modelContext.save()
                print("💾 [DAILY] Sauvegarde réussie")
            } catch {
                print("❌ [DAILY] Erreur de sauvegarde: \(error)")
            }
            
            print("✅ [DAILY] QUÊTE RÉCLAMÉE: +\(quest.experienceReward) XP pour '\(quest.title)'")
        } else {
            print("❌ [DAILY] Conditions non remplies:")
            print("   - isCompleted: \(quest.isCompleted)")
            print("   - isClaimed: \(quest.isClaimed)")
            print("   - Peut être réclamée: \(quest.isCompleted && !quest.isClaimed)")
        }
    }
}

// MARK: - Weekly Quests
struct WeeklyQuestsView: View {
    let quests: [Quest]
    let workouts: [Workout]
    let modelContext: ModelContext
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var weeklyQuests: [Quest] {
        quests.filter { $0.questType == .weekly && !$0.isClaimed }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if weeklyQuests.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "calendar")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Aucune quête hebdomadaire")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.7))
                        
                        Text("Les quêtes apparaîtront bientôt !")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                    }
                    .padding(40)
                } else {
                    ForEach(weeklyQuests, id: \.id) { quest in
                        InteractiveQuestCard(
                            quest: quest,
                            onClaim: {
                                claimQuestReward(quest)
                            }
                        )
                    }
                }
            }
            .padding()
        }
    }
    
    private func claimQuestReward(_ quest: Quest) {
        print("🔍 [WEEKLY] TENTATIVE RÉCLAMATION: '\(quest.title)'")
        print("🔍 [WEEKLY] État: isCompleted=\(quest.isCompleted), isClaimed=\(quest.isClaimed)")
        
        if quest.isCompleted && !quest.isClaimed {
            print("✅ [WEEKLY] Conditions remplies, réclamation en cours...")
            
            // Capturer l'XP avant pour comparaison
            let xpBefore = currentUser?.experience ?? 0
            
            // Marquer la quête comme réclamée
            quest.claimReward()
            print("✅ [WEEKLY] Quête marquée comme réclamée")
            
            // Ajouter l'XP au système global
            if let user = currentUser {
                print("📝 [WEEKLY] Utilisateur trouvé, ajout de \(quest.experienceReward) XP...")
                print("📊 [WEEKLY] Niveau avant: \(user.level), XP avant: \(user.experience)/\(user.experienceToNextLevel)")
                user.gainExperience(quest.experienceReward)
                print("📊 [WEEKLY] Niveau après: \(user.level), XP après: \(user.experience)/\(user.experienceToNextLevel)")
            } else {
                print("⚠️ [WEEKLY] Aucun utilisateur trouvé, création d'un nouveau...")
                // Créer un utilisateur si aucun n'existe
                let newUser = User(name: "Hunter", level: 1, experience: 0)
                newUser.gainExperience(quest.experienceReward)
                modelContext.insert(newUser)
                print("✅ [WEEKLY] Nouvel utilisateur créé avec niveau \(newUser.level), XP \(newUser.experience)")
            }
            
            // Sauvegarder les changements
            do {
                try modelContext.save()
                print("💾 [WEEKLY] Sauvegarde réussie")
            } catch {
                print("❌ [WEEKLY] Erreur de sauvegarde: \(error)")
            }
            
            print("✅ [WEEKLY] QUÊTE RÉCLAMÉE: +\(quest.experienceReward) XP pour '\(quest.title)'")
        } else {
            print("❌ [WEEKLY] Conditions non remplies:")
            print("   - isCompleted: \(quest.isCompleted)")
            print("   - isClaimed: \(quest.isClaimed)")
            print("   - Peut être réclamée: \(quest.isCompleted && !quest.isClaimed)")
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    let quests: [Quest]
    
    private var completedQuests: [Quest] {
        quests.filter { $0.isCompleted }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                if completedQuests.isEmpty {
                    VStack(spacing: 10) {
                        Image(systemName: "trophy")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        Text("Aucun succès débloqué")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.6))
                            .padding()
                        
                        Text("Commencez à vous entraîner pour débloquer des récompenses !")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.5))
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    ForEach(completedQuests, id: \.id) { quest in
                        AchievementCard(quest: quest)
                    }
                }
            }
            .padding()
        }
    }
}

// MARK: - Quest Card
struct QuestCard: View {
    let title: String
    let description: String
    let progress: Int
    let target: Int
    let reward: Int
    let isCompleted: Bool
    
    var progressPercentage: Double {
        Double(progress) / Double(target)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                VStack {
                    Text("\(reward) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.blue)
                    
                    if isCompleted {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
            }
            
            // Progress Bar
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Progress")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    Text("\(progress)/\(target)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 6)
                            .foregroundColor(.white.opacity(0.3))
                        
                        Rectangle()
                            .frame(width: min(progressPercentage * geometry.size.width, geometry.size.width), height: 6)
                            .foregroundColor(.blue)
                    }
                    .cornerRadius(3)
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
        .shadow(color: isCompleted ? .green.opacity(0.3) : .blue.opacity(0.2), radius: 5)
    }
}

// MARK: - Interactive Quest Card
struct InteractiveQuestCard: View {
    let quest: Quest
    let onClaim: () -> Void
    
    var progressPercentage: Double {
        Double(quest.currentProgress) / Double(quest.targetValue)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text(quest.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(quest.questDescription)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .lineLimit(2)
                }
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("+\(quest.experienceReward)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.purple)
                    
                    Text("XP")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                    
                    if quest.isCompleted && !quest.isClaimed {
                        Button(action: onClaim) {
                            HStack(spacing: 4) {
                                Image(systemName: "gift.fill")
                                Text("Claim")
                            }
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.white)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.green)
                            .cornerRadius(8)
                        }
                    } else if quest.isClaimed {
                        HStack(spacing: 4) {
                            Image(systemName: "checkmark.circle.fill")
                            Text("Réclamé")
                        }
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundColor(.green)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(Color.green.opacity(0.2))
                        .cornerRadius(8)
                    }
                }
            }
            
            // Progress Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Progression")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    Text("\(quest.currentProgress)/\(quest.targetValue)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                }
                
                // Enhanced Progress Bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: geometry.size.width, height: 12)
                            .foregroundColor(.white.opacity(0.2))
                        
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: min(progressPercentage * geometry.size.width, geometry.size.width), height: 12)
                            .foregroundColor(
                                quest.isCompleted ? .green :
                                progressPercentage > 0.7 ? .orange : .blue
                            )
                            .animation(.spring(), value: progressPercentage)
                        
                        // Percentage Text Overlay
                        if progressPercentage > 0.1 {
                            HStack {
                                Spacer()
                                Text("\(Int(progressPercentage * 100))%")
                                    .font(.caption2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                }
                .frame(height: 12)
            }
            
            // Quest Type Badge
            HStack {
                QuestTypeBadge(questType: quest.questType)
                
                Spacer()
                
                if quest.isClaimed {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(.yellow)
                        Text("Réclamée")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.yellow)
                    }
                } else if quest.isCompleted {
                    HStack(spacing: 4) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundColor(.green)
                        Text("Prête à réclamer")
                            .font(.caption)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                    }
                } else if progressPercentage > 0 {
                    Text("En cours...")
                        .font(.caption)
                        .foregroundColor(.blue.opacity(0.8))
                }
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: quest.isClaimed ? 
                [Color.yellow.opacity(0.2), Color.yellow.opacity(0.1)] :
                quest.isCompleted ? 
                [Color.green.opacity(0.2), Color.green.opacity(0.1)] :
                [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(
                    quest.isClaimed ? Color.yellow.opacity(0.5) :
                    quest.isCompleted ? Color.green.opacity(0.5) : Color.blue.opacity(0.3),
                    lineWidth: quest.isCompleted ? 2 : 1
                )
        )
        .shadow(
            color: quest.isClaimed ? .yellow.opacity(0.3) :
            quest.isCompleted ? .green.opacity(0.3) : .blue.opacity(0.2),
            radius: quest.isCompleted ? 8 : 5
        )
    }
}

// MARK: - Quest Type Badge
struct QuestTypeBadge: View {
    let questType: QuestType
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: questType == .daily ? "sun.max.fill" : "calendar")
                .font(.caption)
                .foregroundColor(questType == .daily ? .orange : .purple)
            
            Text(questType.rawValue)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(questType == .daily ? .orange : .purple)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(
            (questType == .daily ? Color.orange : Color.purple).opacity(0.2)
        )
        .cornerRadius(6)
    }
}

// MARK: - Achievement Card
struct AchievementCard: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "trophy.fill")
                    .font(.title2)
                    .foregroundColor(.yellow)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(quest.title)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text("Succès débloqué")
                        .font(.caption)
                        .foregroundColor(.yellow.opacity(0.8))
                }
                
                Spacer()
                
                VStack {
                    Text("+\(quest.experienceReward)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    
                    Text("XP")
                        .font(.caption2)
                        .foregroundColor(.yellow.opacity(0.8))
                }
            }
            
            Text(quest.questDescription)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            if let completedDate = quest.completedDate {
                Text("Complété le \(completedDate, style: .date)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.yellow.opacity(0.2), Color.yellow.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.yellow.opacity(0.5), lineWidth: 2)
        )
        .shadow(color: .yellow.opacity(0.3), radius: 8)
    }
}

#Preview {
    ProgressDashboard()
} 