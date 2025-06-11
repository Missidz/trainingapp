//
//  ContentView.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import SwiftData
import Foundation

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var previousTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // Onglet Home
            HomeView()
                .tabItem {
                    Image(systemName: selectedTab == 0 ? "house.fill" : "house")
                    Text("Home")
                }
                .tag(0)
            
            // Onglet Training
            TrainingTabView()
                .tabItem {
                    Image(systemName: selectedTab == 1 ? "dumbbell.fill" : "dumbbell")
                    Text("Training")
                }
                .tag(1)
            
            // Onglet Nutrition
            NutritionTabView()
                .tabItem {
                    Image(systemName: selectedTab == 2 ? "fork.knife.circle.fill" : "fork.knife.circle")
                    Text("Nutrition")
                }
                .tag(2)
            
            // Onglet Progress
            ProgressDashboard()
                .tabItem {
                    Image(systemName: selectedTab == 3 ? "chart.line.uptrend.xyaxis.circle.fill" : "chart.line.uptrend.xyaxis.circle")
                    Text("Progress")
                }
                .tag(3)
            
            // Onglet Quests
            QuestsDashboard()
                .tabItem {
                    Image(systemName: selectedTab == 4 ? "target.circle.fill" : "target.circle")
                    Text("Quests")
                }
                .tag(4)
        }
        .preferredColorScheme(.dark)
        .accentColor(.blue)
        .onChange(of: selectedTab) { oldValue, newValue in
            withAnimation(.easeInOut(duration: 0.3)) {
                previousTab = oldValue
            }
        }
    }
}

// MARK: - Home View
struct HomeView: View {
    var body: some View {
            ZStack {
                // Fond sombre inspiré Solo Leveling
                Color.black
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header principal
                    VStack(spacing: 10) {
                        Text("SHADOW GYM")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .blue.opacity(0.5), radius: 10)
                        
                        Text("Level Up Your Body")
                            .font(.title2)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                .padding(.top, 20)
                    
                    // Profil utilisateur
                    UserProfileCard()
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .move(edge: .bottom).combined(with: .opacity)
                    ))
                
                // Statistiques rapides
                QuickStatsView()
                    .transition(.asymmetric(
                        insertion: .move(edge: .bottom).combined(with: .opacity),
                        removal: .move(edge: .top).combined(with: .opacity)
                    ))
                
                Spacer()
            }
            .padding()
        }
        .animation(.easeInOut(duration: 0.5), value: UUID())
    }
}

// MARK: - Training Tab View
struct TrainingTabView: View {
    @State private var selectedTrainingTab = 0
    @State private var showWorkoutView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    VStack(spacing: 15) {
                        Text("Training Hub")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top, 20)
                        
                        Text("Entraînez-vous comme un Hunter")
                            .font(.title3)
                            .foregroundColor(.blue.opacity(0.8))
                    }
                    .padding(.bottom, 30)
                    
                    // Quick Start Button
                    Button {
                        showWorkoutView = true
                    } label: {
                        HStack {
                            Image(systemName: "play.circle.fill")
                                .font(.title2)
                                .foregroundColor(.green)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Démarrer l'entraînement")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Commencer une nouvelle session")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.green)
                        }
                        .padding(20)
                        .background(
                            LinearGradient(
                                colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: .green.opacity(0.3), radius: 10)
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                    
                    // Training Stats
                    TrainingStatsView()
                        .padding(.horizontal)
                    
                    // Recent Workouts Section
                    RecentWorkoutsView()
                        .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showWorkoutView) {
            WorkoutView()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Training Stats View
struct TrainingStatsView: View {
    @Query private var workouts: [Workout]
    @Query private var users: [User]
    
    private var currentUser: User? {
        users.first
    }
    
    private var totalSessions: Int {
        workouts.count
    }
    
    private var totalXP: Int {
        let workoutXP = workouts.reduce(0) { $0 + $1.experienceGained }
        let userXP = currentUser?.experience ?? 0
        return workoutXP + userXP
    }
    
    private var bestWeight: Double {
        workouts.flatMap { $0.exercises }.map { $0.weight }.max() ?? 0
    }
    
    private var currentStreak: Int {
        // Calculer la série de jours consécutifs d'entraînement
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Statistiques d'entraînement")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 15) {
                StatCard(
                    title: "Sessions",
                    value: "\(totalSessions)",
                    icon: "dumbbell.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Total XP",
                    value: "\(totalXP)",
                    icon: "star.fill",
                    color: .purple
                )
                
                StatCard(
                    title: "Meilleur",
                    value: "\(String(format: "%.0f", bestWeight)) kg",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Série",
                    value: "\(currentStreak) jours",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
    }
}

// MARK: - Recent Workouts View
struct RecentWorkoutsView: View {
    @Query(sort: \Workout.date, order: .reverse) private var workouts: [Workout]
    
    private var recentWorkouts: [Workout] {
        Array(workouts.prefix(5)) // Les 5 derniers workouts
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Entraînements récents")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            if recentWorkouts.isEmpty {
                VStack(spacing: 10) {
                    Image(systemName: "dumbbell")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    
                    Text("Aucun entraînement")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                    
                    Text("Commencez votre première session !")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity)
                .padding(30)
            } else {
                VStack(spacing: 12) {
                    ForEach(recentWorkouts, id: \.id) { workout in
                        WorkoutHistoryCard(workout: workout)
                    }
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
    }
}

// MARK: - Workout History Card
struct WorkoutHistoryCard: View {
    let workout: Workout
    
    private var formattedDuration: String {
        let minutes = Int(workout.duration) / 60
        let seconds = Int(workout.duration) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var body: some View {
        HStack(spacing: 15) {
            // Difficulty Indicator
            Circle()
                .fill(Color(hex: workout.difficulty.color))
                .frame(width: 12, height: 12)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(workout.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if workout.isAwakening {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(.purple)
                    }
                }
                
                HStack(spacing: 15) {
                    Text(workout.date, style: .date)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text("\(workout.exercises.count) exercices")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Text(formattedDuration)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 2) {
                Text("+\(workout.experienceGained)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.purple)
                
                Text("XP")
                    .font(.caption2)
                    .foregroundColor(.purple.opacity(0.8))
            }
        }
        .padding(15)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color(hex: workout.difficulty.color).opacity(0.3), lineWidth: 1)
        )
    }
}

// MARK: - Nutrition Tab View
struct NutritionTabView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTab = 0
    @State private var showAddMealView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Custom Tab Bar
                    HStack(spacing: 0) {
                        TabButton(title: "Today", isSelected: selectedTab == 0) {
                            selectedTab = 0
                        }
                        TabButton(title: "History", isSelected: selectedTab == 1) {
                            selectedTab = 1
                        }
                        TabButton(title: "Goals", isSelected: selectedTab == 2) {
                            selectedTab = 2
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        TodayNutritionView()
                            .tag(0)
                        NutritionHistoryView()
                            .tag(1)
                        NutritionGoalsView()
                            .tag(2)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Nutrition Hub")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddMealView = true
                    } label: {
                        Image(systemName: "plus")
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddMealView) {
            AddMealView()
        }
        .transition(.asymmetric(
            insertion: .move(edge: .trailing).combined(with: .opacity),
            removal: .move(edge: .leading).combined(with: .opacity)
        ))
    }
}

// MARK: - Quick Stats View
struct QuickStatsView: View {
    @Query private var workouts: [Workout]
    @Query private var meals: [Meal]
    
    private var todayWorkouts: [Workout] {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        return workouts.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var todayMeals: [Meal] {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        return meals.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var todayCalories: Int {
        todayMeals.reduce(0) { $0 + $1.totalCalories }
    }
    
    private var todayMinutes: Int {
        Int(todayWorkouts.reduce(0) { $0 + $1.duration } / 60)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            Text("Today's Summary")
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 15) {
                StatCard(
                    title: "Workouts",
                    value: "\(todayWorkouts.count)",
                    icon: "dumbbell.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Calories",
                    value: "\(todayCalories)",
                    icon: "flame.fill",
                    color: .orange
                )
                
                StatCard(
                    title: "Minutes",
                    value: "\(todayMinutes)",
                    icon: "clock.fill",
                    color: .purple
                )
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
    }
}

// MARK: - Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 15)
        .background(color.opacity(0.2))
        .cornerRadius(12)
    }
}

// MARK: - User Profile Card
struct UserProfileCard: View {
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
    
    private var xpToNextLevel: Int {
        if let user = currentUser {
            return user.experienceToNextLevel - user.experience
        } else {
            return 100 - currentXPInLevel
        }
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
    

    
    private var progressPercentage: Double {
        if let user = currentUser {
            return Double(user.experience) / Double(user.experienceToNextLevel)
        } else {
            return Double(currentXPInLevel) / 100.0
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // Avatar et niveau
            HStack {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                    .shadow(color: .blue.opacity(0.3), radius: 10)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("Hunter")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(levelTitle)
                        .font(.subheadline)
                        .foregroundColor(.purple.opacity(0.8))
                    
                    Text("Level \(currentLevel)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()
            }
            
            // Barre de progression XP
            VStack(alignment: .leading, spacing: 5) {
                HStack {
                    Text("Experience")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Spacer()
                    
                    if let user = currentUser {
                        Text("\(user.experience) / \(user.experienceToNextLevel) XP")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    } else {
                        Text("\(currentXPInLevel) / 100 XP")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .frame(width: min(CGFloat(progressPercentage) * geometry.size.width, geometry.size.width), height: 8)
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.5), radius: 5)
                            .animation(.spring(), value: progressPercentage)
                    }
                    .cornerRadius(4)
                }
                .frame(height: 8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
    }
}

// MARK: - Supporting Views for Nutrition

// Today Nutrition View
struct TodayNutritionView: View {
    @Query private var meals: [Meal]
    
    private var todayMeals: [Meal] {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        return meals.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Daily Summary Card
                VStack(spacing: 15) {
                    Text("Today's Summary")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 20) {
                        NutritionSummaryItem(title: "Calories", value: "\(todayMeals.reduce(0) { $0 + $1.totalCalories })", unit: "kcal", color: .orange)
                        NutritionSummaryItem(title: "Protein", value: String(format: "%.0f", todayMeals.reduce(0) { $0 + $1.totalProtein }), unit: "g", color: .red)
                        NutritionSummaryItem(title: "Carbs", value: String(format: "%.0f", todayMeals.reduce(0) { $0 + $1.totalCarbs }), unit: "g", color: .blue)
                        NutritionSummaryItem(title: "Fat", value: String(format: "%.0f", todayMeals.reduce(0) { $0 + $1.totalFat }), unit: "g", color: .yellow)
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Meals Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Today's Meals")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 10) {
                        ForEach(MealType.allCases, id: \.self) { mealType in
                            MealSectionCard(mealType: mealType, meals: todayMeals.filter { $0.mealType == mealType })
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// Nutrition Summary Item
struct NutritionSummaryItem: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                    .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(unit)
                .font(.caption2)
                    .foregroundColor(color)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
    }
}

// Meal Section Card
struct MealSectionCard: View {
    let mealType: MealType
    let meals: [Meal]
    
    private var totalCalories: Int {
        meals.reduce(0) { $0 + $1.totalCalories }
    }
    
    var body: some View {
        HStack {
            Image(systemName: mealType.icon)
                .font(.title2)
                .foregroundColor(Color(hex: mealType.color))
                .frame(width: 40)
            
            VStack(alignment: .leading, spacing: 3) {
                Text(mealType.rawValue)
                    .font(.headline)
                        .foregroundColor(.white)
                
                Text(meals.isEmpty ? "No meals added" : "\(meals.count) meal(s)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("\(totalCalories) kcal")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(15)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}

// Nutrition History View
struct NutritionHistoryView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var meals: [Meal]
    @State private var selectedPeriod: HistoryPeriod = .week
    
    private var filteredMeals: [Meal] {
        let calendar = Calendar.current
        let now = Date()
        
        let startDate: Date
        switch selectedPeriod {
        case .week:
            startDate = calendar.date(byAdding: .weekOfYear, value: -1, to: now) ?? now
        case .month:
            startDate = calendar.date(byAdding: .month, value: -1, to: now) ?? now
        case .year:
            startDate = calendar.date(byAdding: .year, value: -1, to: now) ?? now
        }
        
        return meals.filter { $0.date >= startDate }
    }
    
    private var groupedMeals: [Date: [Meal]] {
        Dictionary(grouping: filteredMeals) { meal in
            Calendar.current.startOfDay(for: meal.date)
        }
    }
    
    var body: some View {
        ScrollView {
                VStack(spacing: 20) {
                // Period Selector
                Picker("Period", selection: $selectedPeriod) {
                    ForEach(HistoryPeriod.allCases, id: \.self) { period in
                        Text(period.rawValue).tag(period)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                
                // Average daily intake
                VStack(spacing: 15) {
                    Text("Average Daily Intake")
                        .font(.headline)
                                    .foregroundColor(.white)
                    
                    let avgCalories = groupedMeals.isEmpty ? 0 : groupedMeals.values.map { $0.reduce(0) { $0 + $1.totalCalories } }.reduce(0, +) / groupedMeals.count
                    let avgProtein = groupedMeals.isEmpty ? 0 : groupedMeals.values.map { $0.reduce(0) { $0 + $1.totalProtein } }.reduce(0, +) / Double(groupedMeals.count)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Text("\(avgCalories)")
                                    .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                            Text("kcal/day")
                                .font(.caption)
                                .foregroundColor(.orange.opacity(0.8))
                        }
                        
                        VStack {
                            Text(String(format: "%.0f", avgProtein))
                                    .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.red)
                            Text("protein/day")
                                .font(.caption)
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // Daily breakdowns
                LazyVStack(spacing: 10) {
                    ForEach(groupedMeals.keys.sorted(by: >), id: \.self) { date in
                        if let dayMeals = groupedMeals[date] {
                            DailyNutritionCard(date: date, meals: dayMeals)
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// Nutrition Goals View
struct NutritionGoalsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var goals: [NutritionGoals]
    @Query private var meals: [Meal]
    @State private var showEditGoals = false
    
    private var currentGoals: NutritionGoals {
        return goals.first ?? NutritionGoals()
    }
    
    private var todayMeals: [Meal] {
        let calendar = Calendar.current
        let today = Date()
        let startOfDay = calendar.startOfDay(for: today)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay) ?? today
        
        return meals.filter { $0.date >= startOfDay && $0.date < endOfDay }
    }
    
    private var todayTotals: (calories: Int, protein: Double, carbs: Double, fat: Double) {
        let totalCalories = todayMeals.reduce(0) { $0 + $1.totalCalories }
        let totalProtein = todayMeals.reduce(0) { $0 + $1.totalProtein }
        let totalCarbs = todayMeals.reduce(0) { $0 + $1.totalCarbs }
        let totalFat = todayMeals.reduce(0) { $0 + $1.totalFat }
        return (totalCalories, totalProtein, totalCarbs, totalFat)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Goals Overview
                VStack(spacing: 15) {
                    HStack {
                        Text("Today's Goals")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                        
                        Spacer()
                        
                        Button("Edit") {
                            showEditGoals = true
                        }
                        .foregroundColor(.blue)
                    }
                    
                    VStack(spacing: 15) {
                        NutritionGoalCard(
                            title: "Calories",
                            current: todayTotals.calories,
                            goal: currentGoals.dailyCaloriesGoal,
                            unit: "kcal",
                            color: .orange,
                            icon: "flame.fill"
                        )
                        
                        NutritionGoalCard(
                            title: "Protein",
                            current: Int(todayTotals.protein),
                            goal: Int(currentGoals.dailyProteinGoal),
                            unit: "g",
                            color: .red,
                            icon: "heart.fill"
                        )
                        
                        NutritionGoalCard(
                            title: "Carbs",
                            current: Int(todayTotals.carbs),
                            goal: Int(currentGoals.dailyCarbsGoal),
                            unit: "g",
                            color: .blue,
                            icon: "drop.fill"
                        )
                        
                        NutritionGoalCard(
                            title: "Fat",
                            current: Int(todayTotals.fat),
                            goal: Int(currentGoals.dailyFatGoal),
                            unit: "g",
                            color: .yellow,
                            icon: "circle.fill"
                        )
                    }
                }
                
                // Weekly Progress
                WeeklyGoalsProgress(currentGoals: currentGoals)
                
                // Tips Section
                GoalsTipsSection()
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .onAppear {
            if goals.isEmpty {
                let defaultGoals = NutritionGoals()
                modelContext.insert(defaultGoals)
                try? modelContext.save()
            }
        }
        .sheet(isPresented: $showEditGoals) {
            EditNutritionGoalsView(currentGoals: currentGoals)
        }
    }
}

// Tab Button
struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline)
                .fontWeight(isSelected ? .semibold : .regular)
                .foregroundColor(isSelected ? .green : .white.opacity(0.6))
                .padding(.vertical, 12)
                .frame(maxWidth: .infinity)
                .background(
                    isSelected ? Color.green.opacity(0.2) : Color.clear
                )
                .cornerRadius(8)
        }
    }
}

// MARK: - Add Meal View
struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var selectedMealType: MealType = .breakfast
    @State private var mealName = ""
    @State private var foodItems: [FoodItemEntry] = []
    @State private var showAddFoodView = false
    
    private var totalCalories: Int {
        foodItems.reduce(0) { $0 + $1.totalCalories }
    }
    
    private var totalProtein: Double {
        foodItems.reduce(0) { $0 + $1.totalProtein }
    }
    
    private var totalCarbs: Double {
        foodItems.reduce(0) { $0 + $1.totalCarbs }
    }
    
    private var totalFat: Double {
        foodItems.reduce(0) { $0 + $1.totalFat }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 10) {
                            Text("Ajouter un Repas")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text("Trackez votre nutrition")
                                .font(.title3)
                                .foregroundColor(.green.opacity(0.8))
                        }
                        .padding(.top, 20)
                        
                        // Meal Type Selection
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Type de Repas")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                ForEach(MealType.allCases, id: \.self) { mealType in
                                    MealTypeSelectionCard(
                                        mealType: mealType,
                                        isSelected: selectedMealType == mealType
                                    ) {
                                        selectedMealType = mealType
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Meal Name
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Nom du Repas (Optionnel)")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            TextField("Ex: Petit-déjeuner énergétique", text: $mealName)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Food Items Section
                        VStack(alignment: .leading, spacing: 15) {
                            HStack {
                                Text("Aliments")
                                    .font(.headline)
                                .foregroundColor(.white)
                            
                                Spacer()
                                
                                Button {
                                    showAddFoodView = true
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .font(.title2)
                                        .foregroundColor(.green)
                                }
                            }
                            
                            if foodItems.isEmpty {
                                VStack(spacing: 10) {
                                    Image(systemName: "fork.knife")
                                        .font(.system(size: 40))
                                        .foregroundColor(.gray)
                                    
                                    Text("Aucun aliment ajouté")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                    
                                    Text("Appuyez sur + pour ajouter des aliments")
                                        .font(.caption)
                                        .foregroundColor(.gray.opacity(0.7))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(30)
                            } else {
                                VStack(spacing: 10) {
                                    ForEach(foodItems.indices, id: \.self) { index in
                                        FoodItemCard(
                                            foodItem: foodItems[index],
                                            onDelete: {
                                                foodItems.remove(at: index)
                                            },
                                            onEdit: { newQuantity in
                                                foodItems[index].quantity = newQuantity
                                            }
                                        )
                                    }
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Nutrition Summary
                        if !foodItems.isEmpty {
                            VStack(spacing: 15) {
                                Text("Résumé Nutritionnel")
                                    .font(.headline)
                        .foregroundColor(.white)
                                
                                HStack(spacing: 20) {
                                    NutritionSummaryItem(
                                        title: "Calories",
                                        value: "\(totalCalories)",
                                        unit: "kcal",
                                        color: .orange
                                    )
                                    
                                    NutritionSummaryItem(
                                        title: "Protéines",
                                        value: String(format: "%.1f", totalProtein),
                                        unit: "g",
                                        color: .red
                                    )
                                    
                                    NutritionSummaryItem(
                                        title: "Glucides",
                                        value: String(format: "%.1f", totalCarbs),
                                        unit: "g",
                                        color: .blue
                                    )
                                    
                                    NutritionSummaryItem(
                                        title: "Lipides",
                                        value: String(format: "%.1f", totalFat),
                                        unit: "g",
                                        color: .yellow
                                    )
                                }
                            }
                            .padding(20)
                        .background(
                            LinearGradient(
                                    colors: [Color.green.opacity(0.2), Color.green.opacity(0.1)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .stroke(Color.green.opacity(0.5), lineWidth: 1)
                            )
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Ajouter Repas")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Sauvegarder") {
                        saveMeal()
                    }
                    .disabled(foodItems.isEmpty)
                    .foregroundColor(foodItems.isEmpty ? .gray : .green)
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showAddFoodView) {
            AddFoodItemView { foodItem in
                foodItems.append(foodItem)
            }
        }
    }
    
    private func saveMeal() {
        let meal = Meal(
            name: mealName.isEmpty ? selectedMealType.rawValue : mealName,
            date: Date(),
            mealType: selectedMealType
        )
        
        // Convert FoodItemEntry to FoodItem and add to meal
        for entry in foodItems {
            let foodItem = FoodItem(
                name: entry.name,
                brand: entry.brand,
                servingSize: entry.servingSize,
                quantity: entry.quantity,
                caloriesPerServing: entry.caloriesPerServing,
                proteinPerServing: entry.proteinPerServing,
                carbsPerServing: entry.carbsPerServing,
                fatPerServing: entry.fatPerServing,
                isManualEntry: true
            )
            
            meal.foodItems.append(foodItem)
            modelContext.insert(foodItem)
        }
        
        meal.calculateTotals()
        modelContext.insert(meal)
        
        do {
            try modelContext.save()
            dismiss()
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }
    }
}

// MARK: - Food Item Entry (Local struct for editing)
struct FoodItemEntry {
    var name: String
    var brand: String?
    var servingSize: Double = 100.0
    var quantity: Double = 1.0
    var caloriesPerServing: Int = 0
    var proteinPerServing: Double = 0.0
    var carbsPerServing: Double = 0.0
    var fatPerServing: Double = 0.0
    
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
}

// MARK: - Meal Type Selection Card
struct MealTypeSelectionCard: View {
    let mealType: MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: mealType.icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .white : Color(hex: mealType.color))
                
                Text(mealType.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .white.opacity(0.8))
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(
                isSelected ? 
                Color(hex: mealType.color).opacity(0.8) :
                Color.white.opacity(0.1)
            )
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: mealType.color) : Color.clear, lineWidth: 2)
            )
        }
    }
}

// MARK: - Food Item Card
struct FoodItemCard: View {
    let foodItem: FoodItemEntry
    let onDelete: () -> Void
    let onEdit: (Double) -> Void
    
    @State private var showingQuantityEdit = false
    @State private var editQuantity: String
    
    init(foodItem: FoodItemEntry, onDelete: @escaping () -> Void, onEdit: @escaping (Double) -> Void) {
        self.foodItem = foodItem
        self.onDelete = onDelete
        self.onEdit = onEdit
        self._editQuantity = State(initialValue: String(format: "%.1f", foodItem.quantity))
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(foodItem.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    if let brand = foodItem.brand, !brand.isEmpty {
                        Text(brand)
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                    }
                }
                
                Spacer()
                
                HStack(spacing: 10) {
                    Button {
                        showingQuantityEdit = true
                    } label: {
                        Image(systemName: "pencil")
                            .foregroundColor(.blue)
                    }
                    
                    Button {
                        onDelete()
                    } label: {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
            HStack {
                Text("Quantité: \(String(format: "%.1f", foodItem.quantity))x")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(foodItem.totalCalories) kcal")
                                .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.orange)
            }
            
            HStack(spacing: 15) {
                NutritionMicroItem(
                    title: "P",
                    value: String(format: "%.1f", foodItem.totalProtein),
                    color: .red
                )
                
                NutritionMicroItem(
                    title: "G",
                    value: String(format: "%.1f", foodItem.totalCarbs),
                    color: .blue
                )
                
                NutritionMicroItem(
                    title: "L",
                    value: String(format: "%.1f", foodItem.totalFat),
                    color: .yellow
                )
            }
        }
        .padding(15)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
        .alert("Modifier la quantité", isPresented: $showingQuantityEdit) {
            TextField("Quantité", text: $editQuantity)
                .keyboardType(.decimalPad)
            
            Button("Annuler", role: .cancel) { }
            
            Button("Sauvegarder") {
                if let newQuantity = Double(editQuantity), newQuantity > 0 {
                    onEdit(newQuantity)
                }
            }
        }
    }
}

// MARK: - Nutrition Micro Item
struct NutritionMicroItem: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 2) {
            Text(title)
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(color)
            
            Text(value)
                .font(.caption)
                .foregroundColor(.white.opacity(0.8))
        }
    }
}

// MARK: - Add Food Item View
struct AddFoodItemView: View {
    @Environment(\.dismiss) private var dismiss
    let onAdd: (FoodItemEntry) -> Void
    
    @State private var foodName = ""
    @State private var brandName = ""
    @State private var servingSize = "100"
    @State private var quantity = "1"
    @State private var calories = ""
    @State private var protein = ""
    @State private var carbs = ""
    @State private var fat = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("Ajouter un Aliment")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(spacing: 20) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Informations de base")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                CustomTextField(title: "Nom de l'aliment*", text: $foodName, placeholder: "Ex: Yaourt grec")
                                CustomTextField(title: "Marque (optionnel)", text: $brandName, placeholder: "Ex: Danone")
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            
                            // Serving Info
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Portion")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 15) {
                                    CustomTextField(title: "Taille portion (g)", text: $servingSize, placeholder: "100")
                                    CustomTextField(title: "Quantité", text: $quantity, placeholder: "1")
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                            
                            // Nutrition Info
                            VStack(alignment: .leading, spacing: 15) {
                                Text("Valeurs nutritionnelles (pour 100g)")
                                    .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 15) {
                                    CustomTextField(title: "Calories (kcal)", text: $calories, placeholder: "150")
                                    CustomTextField(title: "Protéines (g)", text: $protein, placeholder: "10")
                                    CustomTextField(title: "Glucides (g)", text: $carbs, placeholder: "15")
                                    CustomTextField(title: "Lipides (g)", text: $fat, placeholder: "8")
                                }
                            }
                            .padding(20)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                        
                        Spacer(minLength: 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("Nouvel Aliment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Annuler") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Ajouter") {
                        addFoodItem()
                    }
                    .disabled(foodName.isEmpty || calories.isEmpty)
                    .foregroundColor(foodName.isEmpty || calories.isEmpty ? .gray : .green)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func addFoodItem() {
        let foodItem = FoodItemEntry(
            name: foodName,
            brand: brandName.isEmpty ? nil : brandName,
            servingSize: Double(servingSize) ?? 100.0,
            quantity: Double(quantity) ?? 1.0,
            caloriesPerServing: Int(calories) ?? 0,
            proteinPerServing: Double(protein) ?? 0.0,
            carbsPerServing: Double(carbs) ?? 0.0,
            fatPerServing: Double(fat) ?? 0.0
        )
        
        onAdd(foodItem)
        dismiss()
    }
}

// MARK: - Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
    }
}







#Preview {
    ContentView()
}