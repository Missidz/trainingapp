//
//  ProgressViews.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import Charts

struct ProgressDashboard: View {
    @State private var selectedTimeframe = "Week"
    let timeframes = ["Week", "Month", "Year"]
    
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
    let currentLevel = 1
    let currentXP = 0
    let maxXP = 100
    let totalWorkouts = 0
    
    var body: some View {
        VStack(spacing: 20) {
            HStack {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Hunter Level")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Newbie Hunter")
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
                            .trim(from: 0, to: CGFloat(currentXP) / CGFloat(maxXP))
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
                        
                        Text("\(Int((Double(currentXP) / Double(maxXP)) * 100))%")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Text("\(currentXP)/\(maxXP) XP")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.7))
                }
            }
            
            // Next Level Preview
            HStack {
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                
                Text("Next: Fighter (Level 6)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Spacer()
                
                Text("\(600 - currentXP) XP to go")
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
    var body: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 15) {
            EnhancedStatCard(
                title: "Total Workouts",
                value: "0",
                icon: "dumbbell.fill",
                color: .blue
            )
            
            EnhancedStatCard(
                title: "Total XP",
                value: "0",
                icon: "star.fill",
                color: .purple
            )
            
            EnhancedStatCard(
                title: "Streak",
                value: "0 days",
                icon: "flame.fill",
                color: .orange
            )
            
            EnhancedStatCard(
                title: "Best Week",
                value: "0 workouts",
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

// MARK: - Quests View
struct QuestsDashboard: View {
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack {
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
                        DailyQuestsView()
                            .tag(0)
                        
                        WeeklyQuestsView()
                            .tag(1)
                        
                        AchievementsView()
                            .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                }
            }
            .navigationTitle("Quests & Goals")
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Daily Quests
struct DailyQuestsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                QuestCard(
                    title: "First Training",
                    description: "Complete your first workout session",
                    progress: 0,
                    target: 1,
                    reward: 50,
                    isCompleted: false
                )
                
                QuestCard(
                    title: "Consistency",
                    description: "Train 3 days this week",
                    progress: 0,
                    target: 3,
                    reward: 100,
                    isCompleted: false
                )
                
                QuestCard(
                    title: "Volume Builder",
                    description: "Complete 50 total reps today",
                    progress: 0,
                    target: 50,
                    reward: 75,
                    isCompleted: false
                )
            }
            .padding()
        }
    }
}

// MARK: - Weekly Quests
struct WeeklyQuestsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                QuestCard(
                    title: "Weekly Warrior",
                    description: "Complete 5 workouts this week",
                    progress: 0,
                    target: 5,
                    reward: 250,
                    isCompleted: false
                )
                
                QuestCard(
                    title: "Strength Builder",
                    description: "Lift a total of 1000kg this week",
                    progress: 0,
                    target: 1000,
                    reward: 300,
                    isCompleted: false
                )
            }
            .padding()
        }
    }
}

// MARK: - Achievements View
struct AchievementsView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 15) {
                Text("No achievements unlocked yet")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
                
                Text("Start training to unlock rewards and titles!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
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

#Preview {
    ProgressDashboard()
} 