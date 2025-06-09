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
    @State private var showWorkoutView = false
    @State private var showProgressView = false
    @State private var showQuestsView = false
    @State private var showNutritionView = false
    
    var body: some View {
        NavigationView {
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
                    .padding(.top, 50)
                    
                    // Profil utilisateur
                    UserProfileCard()
                    
                    // Navigation principale
                    VStack(spacing: 20) {
                        NavigationButton(
                            title: "Start Training",
                            subtitle: "Begin your workout",
                            icon: "dumbbell.fill",
                            color: .blue,
                            action: { showWorkoutView = true }
                        )
                        
                        NavigationButton(
                            title: "View Progress",
                            subtitle: "Track your journey",
                            icon: "chart.line.uptrend.xyaxis",
                            color: .purple,
                            action: { showProgressView = true }
                        )
                        
                        NavigationButton(
                            title: "Quests & Goals",
                            subtitle: "Complete challenges",
                            icon: "target",
                            color: .indigo,
                            action: { showQuestsView = true }
                        )
                        
                        NavigationButton(
                            title: "Nutrition Hub",
                            subtitle: "Track your meals",
                            icon: "fork.knife",
                            color: .green,
                            action: { showNutritionView = true }
                        )
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationBarBackButtonHidden(true)
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showWorkoutView) {
            SimpleWorkoutView()
        }
        .sheet(isPresented: $showProgressView) {
            SimpleProgressView()
        }
        .sheet(isPresented: $showQuestsView) {
            SimpleQuestsView()
        }
        .sheet(isPresented: $showNutritionView) {
            NutritionView()
        }
    }
}

// MARK: - User Profile Card
struct UserProfileCard: View {
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
                    
                    Text("Newbie Hunter")
                        .font(.subheadline)
                        .foregroundColor(.purple.opacity(0.8))
                    
                    Text("Level 1")
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
                    
                    Text("0 / 100 XP")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Rectangle()
                            .frame(width: geometry.size.width, height: 8)
                            .opacity(0.3)
                            .foregroundColor(.white)
                        
                        Rectangle()
                            .frame(width: 0, height: 8)
                            .foregroundColor(.blue)
                            .shadow(color: .blue.opacity(0.5), radius: 5)
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

// MARK: - Navigation Button
struct NavigationButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                    .frame(width: 50, height: 50)
                    .background(color.opacity(0.2))
                    .cornerRadius(12)
                    .shadow(color: color.opacity(0.3), radius: 5)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.title3)
                    .foregroundColor(color)
            }
            .padding(20)
            .background(
                LinearGradient(
                    colors: [color.opacity(0.1), color.opacity(0.05)],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .cornerRadius(16)
            .shadow(color: color.opacity(0.2), radius: 8)
        }
    }
}

// MARK: - Training Hub View
struct SimpleWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header
                    Text("Training Hub")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top, 20)
                        .padding(.bottom, 30)
                    
                    // Tab Selector
                    Picker("Training Type", selection: $selectedTab) {
                        Text("Custom Training").tag(0)
                        Text("Discover Training").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                    
                    // Content based on selected tab
                    TabView(selection: $selectedTab) {
                        CustomTrainingView()
                            .tag(0)
                        DiscoverTrainingView()
                            .tag(1)
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Training")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Custom Training View
struct CustomTrainingView: View {
    @State private var selectedMuscleGroup = "All"
    @State private var showCreateWorkout = false
    
    let muscleGroups = ["All", "Chest", "Back", "Legs", "Arms", "Shoulders", "Core"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Quick Start Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("⚡ Quick Start")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Button {
                        showCreateWorkout = true
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.blue)
                            
                            VStack(alignment: .leading, spacing: 3) {
                                Text("Create New Workout")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Design your custom training session")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.blue)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                    }
                }
                
                // Muscle Group Filter
                VStack(alignment: .leading, spacing: 15) {
                    Text("🎯 Target Muscle Group")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 10) {
                            ForEach(muscleGroups, id: \.self) { group in
                                Button {
                                    selectedMuscleGroup = group
                                } label: {
                                    Text(group)
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .foregroundColor(selectedMuscleGroup == group ? .black : .white)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(selectedMuscleGroup == group ? Color.blue : Color.white.opacity(0.2))
                                        .cornerRadius(20)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                
                // Recent Workouts
                VStack(alignment: .leading, spacing: 15) {
                    Text("📚 Recent Workouts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        WorkoutCard(
                            name: "Upper Body Power",
                            duration: "45 min",
                            exercises: 8,
                            lastPerformed: "2 days ago",
                            difficulty: .normal
                        )
                        
                        WorkoutCard(
                            name: "Leg Day Destroyer",
                            duration: "60 min",
                            exercises: 10,
                            lastPerformed: "5 days ago",
                            difficulty: .hard
                        )
                        
                        WorkoutCard(
                            name: "Core Crusher",
                            duration: "30 min",
                            exercises: 6,
                            lastPerformed: "1 week ago",
                            difficulty: .easy
                        )
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .sheet(isPresented: $showCreateWorkout) {
            CreateWorkoutView()
        }
    }
}

// MARK: - Discover Training View
struct DiscoverTrainingView: View {
    let featuredWorkouts = [
        ("🔥 HIIT Inferno", "20 min", "Beginner", "High intensity interval training"),
        ("💪 Strength Builder", "45 min", "Intermediate", "Build muscle and power"),
        ("🧘‍♀️ Mobility Flow", "30 min", "All Levels", "Improve flexibility"),
        ("🏃‍♂️ Cardio Blast", "35 min", "Intermediate", "Burn calories fast")
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Featured Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("⭐ Featured Workouts")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    VStack(spacing: 12) {
                        ForEach(featuredWorkouts, id: \.0) { workout in
                            FeaturedWorkoutCard(
                                title: workout.0,
                                duration: workout.1,
                                level: workout.2,
                                description: workout.3
                            )
                        }
                    }
                }
                
                // Categories
                VStack(alignment: .leading, spacing: 15) {
                    Text("📂 Categories")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 15) {
                        CategoryCard(title: "Strength", icon: "dumbbell.fill", color: .red)
                        CategoryCard(title: "Cardio", icon: "heart.fill", color: .orange)
                        CategoryCard(title: "Flexibility", icon: "figure.yoga", color: .green)
                        CategoryCard(title: "HIIT", icon: "flame.fill", color: .purple)
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// MARK: - Workout Card
struct WorkoutCard: View {
    let name: String
    let duration: String
    let exercises: Int
    let lastPerformed: String
    let difficulty: WorkoutDifficulty
    
    var body: some View {
        Button {
            // Start workout action
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(name)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: difficulty)
                }
                
                HStack(spacing: 20) {
                    Label(duration, systemImage: "clock")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                    
                    Label("\(exercises) exercises", systemImage: "list.bullet")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Text("Last: \(lastPerformed)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Featured Workout Card
struct FeaturedWorkoutCard: View {
    let title: String
    let duration: String
    let level: String
    let description: String
    
    var body: some View {
        Button {
            // Start featured workout
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Text(level)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.8))
                        .cornerRadius(8)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    Label(duration, systemImage: "clock")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Image(systemName: "play.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        Button {
            // Browse category
        } label: {
            VStack(spacing: 10) {
                Image(systemName: icon)
                    .font(.system(size: 30))
                    .foregroundColor(color)
                
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.white)
            }
            .frame(height: 80)
            .frame(maxWidth: .infinity)
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
        }
    }
}

// MARK: - Create Workout View
struct CreateWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var workoutName = ""
    @State private var selectedMuscleGroup = "Chest"
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("Create Custom Workout")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding(.top)
                    
                    Text("Design your perfect training session")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text("Coming Soon!")
                        .font(.title3)
                        .foregroundColor(.blue)
                        .padding(.top, 50)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Create Workout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Progress Analytics View
struct SimpleProgressView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedTimeframe = "This Week"
    
    let timeframes = ["This Week", "This Month", "Last 3 Months"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text("Progress Analytics")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Picker("Timeframe", selection: $selectedTimeframe) {
                                ForEach(timeframes, id: \.self) { timeframe in
                                    Text(timeframe).tag(timeframe)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                            .padding(.horizontal)
                        }
                        
                        // Weekly Overview
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📈 Weekly Overview")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 15) {
                                StatCard(
                                    title: "Workouts",
                                    value: "12",
                                    subtitle: "This week",
                                    icon: "dumbbell.fill",
                                    color: .blue
                                )
                                
                                StatCard(
                                    title: "Total Time",
                                    value: "8.5h",
                                    subtitle: "Training time",
                                    icon: "clock.fill",
                                    color: .green
                                )
                                
                                StatCard(
                                    title: "Calories",
                                    value: "3,420",
                                    subtitle: "Burned",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                                
                                StatCard(
                                    title: "PR's",
                                    value: "5",
                                    subtitle: "New records",
                                    icon: "trophy.fill",
                                    color: .yellow
                                )
                            }
                        }
                        
                        // Strength Progress
                        VStack(alignment: .leading, spacing: 15) {
                            Text("💪 Strength Progress")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                StrengthProgressCard(
                                    exercise: "Bench Press",
                                    current: "185 lbs",
                                    previous: "175 lbs",
                                    improvement: "+10 lbs"
                                )
                                
                                StrengthProgressCard(
                                    exercise: "Deadlift",
                                    current: "275 lbs",
                                    previous: "265 lbs",
                                    improvement: "+10 lbs"
                                )
                                
                                StrengthProgressCard(
                                    exercise: "Squat",
                                    current: "225 lbs",
                                    previous: "220 lbs",
                                    improvement: "+5 lbs"
                                )
                            }
                        }
                        
                        // Body Composition
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📏 Body Composition")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 12) {
                                BodyMetricCard(
                                    metric: "Weight",
                                    current: "172 lbs",
                                    change: "-2 lbs",
                                    isPositive: false
                                )
                                
                                BodyMetricCard(
                                    metric: "Body Fat",
                                    current: "12.5%",
                                    change: "-1.2%",
                                    isPositive: false
                                )
                                
                                BodyMetricCard(
                                    metric: "Muscle Mass",
                                    current: "145 lbs",
                                    change: "+3 lbs",
                                    isPositive: true
                                )
                            }
                        }
                        
                        // Weekly Activity Chart Placeholder
                        VStack(alignment: .leading, spacing: 15) {
                            Text("📊 Activity Chart")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            VStack(spacing: 10) {
                                Text("Weekly Training Volume")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Text("Chart visualization coming soon")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                                
                                Rectangle()
                                    .fill(Color.white.opacity(0.1))
                                    .frame(height: 200)
                                    .cornerRadius(12)
                                    .overlay(
                                        Text("📈 Interactive Charts\nComing Soon!")
                                            .font(.headline)
                                            .foregroundColor(.blue)
                                            .multilineTextAlignment(.center)
                                    )
                            }
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Quests & Challenges View
struct SimpleQuestsView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory = "All"
    
    let categories = ["All", "Strength", "Cardio", "Consistency", "Habits"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        QuestsHeaderView()
                        QuestCategoryFilterView(selectedCategory: $selectedCategory, categories: categories)
                        ActiveQuestsSection()
                        AvailableQuestsSection()
                        RecentAchievementsSection()
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Quests")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Quest View Components
struct QuestsHeaderView: View {
    var body: some View {
        VStack(spacing: 15) {
            Text("Quests & Challenges")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text("Level up your fitness journey")
                .font(.title3)
                .foregroundColor(.indigo.opacity(0.8))
        }
        .padding(.top, 10)
    }
}

struct QuestCategoryFilterView: View {
    @Binding var selectedCategory: String
    let categories: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("📂 Categories")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(categories, id: \.self) { category in
                        Button {
                            selectedCategory = category
                        } label: {
                            Text(category)
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundColor(selectedCategory == category ? .black : .white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(selectedCategory == category ? Color.indigo : Color.white.opacity(0.2))
                                .cornerRadius(20)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}

struct ActiveQuestsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🔥 Active Quests")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                QuestCard(
                    title: "Consistency Streak",
                    description: "Work out 5 days this week",
                    progress: 3,
                    target: 5,
                    reward: 150,
                    isCompleted: false
                )
                
                QuestCard(
                    title: "Strength Challenger",
                    description: "Increase bench press by 10 lbs",
                    progress: 7,
                    target: 10,
                    reward: 200,
                    isCompleted: false
                )
                
                QuestCard(
                    title: "Cardio Explorer",
                    description: "Complete 120 minutes of cardio",
                    progress: 85,
                    target: 120,
                    reward: 100,
                    isCompleted: false
                )
            }
        }
    }
}

struct AvailableQuestsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("✨ Available Quests")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 15) {
                AvailableQuestCard(
                    title: "Perfect Week",
                    description: "Complete all planned workouts this week",
                    reward: "300 XP + Badge",
                    estimatedTime: "7 days",
                    difficulty: .hard
                )
                
                AvailableQuestCard(
                    title: "Morning Warrior",
                    description: "Complete 3 morning workouts",
                    reward: "75 XP",
                    estimatedTime: "1 week",
                    difficulty: .easy
                )
                
                AvailableQuestCard(
                    title: "Leg Day Legend",
                    description: "Complete 4 leg workouts this month",
                    reward: "200 XP",
                    estimatedTime: "4 weeks",
                    difficulty: .normal
                )
            }
        }
    }
}

struct RecentAchievementsSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("🏆 Recent Achievements")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            VStack(spacing: 12) {
                AchievementCard(
                    title: "First Week Complete",
                    description: "Completed your first week of training",
                    dateEarned: "2 days ago",
                    xpEarned: 100
                )
                
                AchievementCard(
                    title: "Strength Gains",
                    description: "Increased total lifting volume by 20%",
                    dateEarned: "1 week ago",
                    xpEarned: 150
                )
            }
        }
    }
}

// MARK: - Nutrition View
struct NutritionView: View {
    @Environment(\.dismiss) private var dismiss
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
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
    }
}

// MARK: - Add Meal View
struct AddMealView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var selectedMealType: MealType = .breakfast
    @State private var showBarcodeScannerView = false
    @State private var showManualEntryView = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // Header
                    VStack(spacing: 10) {
                        Text("Add Meal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        Text("Track your nutrition")
                            .font(.title3)
                            .foregroundColor(.green.opacity(0.8))
                    }
                    .padding(.top, 20)
                    
                    // Meal Type Selector
                    VStack(alignment: .leading, spacing: 15) {
                        Text("Meal Type")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            ForEach(MealType.allCases, id: \.self) { mealType in
                                MealTypeCard(
                                    mealType: mealType,
                                    isSelected: selectedMealType == mealType
                                ) {
                                    selectedMealType = mealType
                                }
                            }
                        }
                    }
                    
                    // Add Options
                    VStack(spacing: 20) {
                        Text("How do you want to add food?")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 15) {
                            // Barcode Scanner Option
                            Button {
                                showBarcodeScannerView = true
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "barcode.viewfinder")
                                        .font(.system(size: 30))
                                        .foregroundColor(.blue)
                                        .frame(width: 50, height: 50)
                                        .background(Color.blue.opacity(0.2))
                                        .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Scan Barcode")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text("Quickly scan product barcode")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.blue)
                                }
                                .padding(20)
                                .background(
                                    LinearGradient(
                                        colors: [Color.blue.opacity(0.1), Color.blue.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                            
                            // Manual Entry Option
                            Button {
                                showManualEntryView = true
                            } label: {
                                HStack(spacing: 15) {
                                    Image(systemName: "square.and.pencil")
                                        .font(.system(size: 30))
                                        .foregroundColor(.green)
                                        .frame(width: 50, height: 50)
                                        .background(Color.green.opacity(0.2))
                                        .cornerRadius(12)
                                    
                                    VStack(alignment: .leading, spacing: 5) {
                                        Text("Manual Entry")
                                            .font(.title3)
                                            .fontWeight(.semibold)
                                            .foregroundColor(.white)
                                        
                                        Text("Enter food details manually")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.7))
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.green)
                                }
                                .padding(20)
                                .background(
                                    LinearGradient(
                                        colors: [Color.green.opacity(0.1), Color.green.opacity(0.05)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(16)
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Add Meal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
                 .sheet(isPresented: $showBarcodeScannerView) {
             BarcodeScannerView(selectedMealType: selectedMealType)
         }
         .sheet(isPresented: $showManualEntryView) {
             ManualFoodEntryView(selectedMealType: selectedMealType)
         }
    }
}

// MARK: - Supporting Views

// Meal Type Card
struct MealTypeCard: View {
    let mealType: MealType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                Image(systemName: mealType.icon)
                    .font(.system(size: 30))
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

// Today Nutrition View
struct TodayNutritionView: View {
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
                        NutritionSummaryItem(title: "Calories", value: "0", unit: "kcal", color: .orange)
                        NutritionSummaryItem(title: "Protein", value: "0", unit: "g", color: .red)
                        NutritionSummaryItem(title: "Carbs", value: "0", unit: "g", color: .blue)
                        NutritionSummaryItem(title: "Fat", value: "0", unit: "g", color: .yellow)
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
                            MealSectionCard(mealType: mealType)
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
                
                Text("No meals added")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
            }
            
            Spacer()
            
            Text("0 kcal")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(15)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
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

// MARK: - Missing Nutrition Views

// Nutrition History View
struct NutritionHistoryView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("📊 Nutrition History")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text("Your nutrition history will be displayed here")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Text("Add meals to see your history!")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(.top, 50)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// Nutrition Goals View
struct NutritionGoalsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("🎯 Nutrition Goals")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                Text("Set and track your daily nutrition targets")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                
                Text("Goals feature coming soon!")
                    .font(.title3)
                    .foregroundColor(.green)
                    .padding(.top, 50)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// Barcode Scanner View
struct BarcodeScannerView: View {
    @Environment(\.dismiss) private var dismiss
    let selectedMealType: MealType
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    Text("📱 Barcode Scanner")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Point your camera at the product barcode")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                        .multilineTextAlignment(.center)
                    
                    // Placeholder for camera view
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.1))
                        .frame(height: 300)
                        .overlay(
                            VStack(spacing: 15) {
                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 60))
                                    .foregroundColor(.blue)
                                
                                Text("Camera Preview")
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.6))
                                
                                Text("Barcode scanning requires camera access.\nThis is a demo placeholder.")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.5))
                                    .multilineTextAlignment(.center)
                            }
                        )
                    
                    Button("Simulate Scan Result") {
                        // For demo purposes - would normally process scanned barcode
                        dismiss()
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// Manual Food Entry View
struct ManualFoodEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    let selectedMealType: MealType
    
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
                        Text("Add Food Manually")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(spacing: 15) {
                            // Basic Info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Basic Information")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                CustomTextField(title: "Food Name*", text: $foodName, placeholder: "e.g., Greek Yogurt")
                                CustomTextField(title: "Brand (Optional)", text: $brandName, placeholder: "e.g., Chobani")
                            }
                            
                            // Serving Info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Serving Information")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 15) {
                                    CustomTextField(title: "Serving Size (g)", text: $servingSize, placeholder: "100")
                                    CustomTextField(title: "Quantity", text: $quantity, placeholder: "1")
                                }
                            }
                            
                            // Nutrition Info
                            VStack(alignment: .leading, spacing: 10) {
                                Text("Nutrition per Serving")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                VStack(spacing: 12) {
                                    CustomTextField(title: "Calories", text: $calories, placeholder: "150")
                                    CustomTextField(title: "Protein (g)", text: $protein, placeholder: "10")
                                    CustomTextField(title: "Carbs (g)", text: $carbs, placeholder: "15")
                                    CustomTextField(title: "Fat (g)", text: $fat, placeholder: "8")
                                }
                            }
                        }
                        .padding(.bottom, 30)
                    }
                    .padding()
                }
            }
            .navigationTitle("Manual Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.blue)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveFoodItem()
                        dismiss()
                    }
                    .foregroundColor(.green)
                    .disabled(foodName.isEmpty || calories.isEmpty)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func saveFoodItem() {
        let foodItem = FoodItem(
            name: foodName,
            brand: brandName.isEmpty ? nil : brandName,
            servingSize: Double(servingSize) ?? 100.0,
            quantity: Double(quantity) ?? 1.0,
            caloriesPerServing: Int(calories) ?? 0,
            proteinPerServing: Double(protein) ?? 0.0,
            carbsPerServing: Double(carbs) ?? 0.0,
            fatPerServing: Double(fat) ?? 0.0,
            isManualEntry: true
        )
        
        let meal = Meal(name: selectedMealType.rawValue, mealType: selectedMealType)
        meal.foodItems.append(foodItem)
        meal.calculateTotals()
        
        modelContext.insert(meal)
        modelContext.insert(foodItem)
        
        do {
            try modelContext.save()
        } catch {
            print("Error saving meal: \(error)")
        }
    }
}

// Custom Text Field
struct CustomTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.8))
            
            TextField(placeholder, text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
        }
    }
}

// MARK: - Supporting Views for Progress

// Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
            
            Text(subtitle)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .frame(maxWidth: .infinity)
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// Strength Progress Card
struct StrengthProgressCard: View {
    let exercise: String
    let current: String
    let previous: String
    let improvement: String
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(exercise)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Previous: \(previous)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(current)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(improvement)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.green)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// Body Metric Card
struct BodyMetricCard: View {
    let metric: String
    let current: String
    let change: String
    let isPositive: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(metric)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text("Current")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(current)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(change)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(isPositive ? .green : .red)
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Supporting Views for Quests

// Difficulty Badge
struct DifficultyBadge: View {
    let difficulty: WorkoutDifficulty
    
    var difficultyColor: Color {
        switch difficulty {
        case .easy:
            return .green
        case .normal:
            return .blue
        case .hard:
            return .orange
        case .nightmare:
            return .red
        }
    }
    
    var body: some View {
        Text(difficulty.rawValue)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(difficultyColor.opacity(0.8))
            .cornerRadius(8)
    }
}

// Available Quest Card
struct AvailableQuestCard: View {
    let title: String
    let description: String
    let reward: String
    let estimatedTime: String
    let difficulty: WorkoutDifficulty
    
    var body: some View {
        Button {
            // Accept quest action
        } label: {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text(title)
                        .font(.headline)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    DifficultyBadge(difficulty: difficulty)
                }
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.leading)
                
                HStack {
                    VStack(alignment: .leading, spacing: 3) {
                        Text("Reward: \(reward)")
                            .font(.caption)
                            .foregroundColor(.yellow)
                            .fontWeight(.semibold)
                        
                        Text("Time: \(estimatedTime)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.6))
                    }
                    
                    Spacer()
                    
                    Text("Accept")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.indigo)
                        .cornerRadius(20)
                }
            }
            .padding(16)
            .background(Color.white.opacity(0.05))
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.indigo.opacity(0.3), lineWidth: 1)
            )
        }
    }
}

// Achievement Card
struct AchievementCard: View {
    let title: String
    let description: String
    let dateEarned: String
    let xpEarned: Int
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 30))
                .foregroundColor(.yellow)
                .frame(width: 50, height: 50)
                .background(Color.yellow.opacity(0.2))
                .cornerRadius(12)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                HStack {
                    Text(dateEarned)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    
                    Spacer()
                    
                    Text("+\(xpEarned) XP")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.yellow)
                }
            }
            
            Spacer()
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}



#Preview {
    ContentView()
} 