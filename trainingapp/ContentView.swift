//
//  ContentView.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showWorkoutView = false
    @State private var showProgressView = false
    @State private var showQuestsView = false
    
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
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Custom Training View
struct CustomTrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var exerciseName = ""
    @State private var sets = 1
    @State private var reps = 10
    @State private var weight = 0.0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 20) {
                    VStack(alignment: .leading) {
                        Text("Exercise")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("Enter exercise name", text: $exerciseName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    HStack(spacing: 30) {
                        VStack {
                            Text("Sets")
                                .foregroundColor(.white.opacity(0.8))
                            Stepper(value: $sets, in: 1...50) {
                                Text("\(sets)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                        
                        VStack {
                            Text("Reps")
                                .foregroundColor(.white.opacity(0.8))
                            Stepper(value: $reps, in: 1...100) {
                                Text("\(reps)")
                                    .foregroundColor(.white)
                                    .font(.title2)
                            }
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        Text("Weight (kg)")
                            .foregroundColor(.white.opacity(0.8))
                        TextField("0", value: $weight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                }
                .padding(20)
                .background(Color.white.opacity(0.1))
                .cornerRadius(16)
                
                // XP Preview
                VStack {
                    Text("XP Gain Preview")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("\(sets * reps) XP")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(12)
                
                Button("Complete Training") {
                    // Add training completion logic here
                    dismiss()
                }
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity)
                .background(
                    LinearGradient(
                        colors: [.blue, .purple],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .cornerRadius(12)
                .shadow(color: .blue.opacity(0.3), radius: 10)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
    }
}

// MARK: - Discover Training View
struct DiscoverTrainingView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var selectedWorkout: PresetWorkout? = nil
    
    let presetWorkouts = [
        PresetWorkout(
            name: "Pectoraux Power",
            emoji: "💪",
            description: "Développez vos pectoraux avec cet entraînement intense",
            exercises: [
                PresetExercise(name: "Push-ups", sets: 3, reps: 15, restTime: 60),
                PresetExercise(name: "Chest Press", sets: 4, reps: 12, restTime: 90),
                PresetExercise(name: "Incline Press", sets: 3, reps: 10, restTime: 90),
                PresetExercise(name: "Chest Fly", sets: 3, reps: 12, restTime: 60)
            ],
            duration: 45,
            difficulty: "Intermediate",
            xpReward: 180
        ),
        PresetWorkout(
            name: "Dos de Fer",
            emoji: "🦅",
            description: "Forgez un dos solide et puissant",
            exercises: [
                PresetExercise(name: "Pull-ups", sets: 3, reps: 8, restTime: 90),
                PresetExercise(name: "Lat Pulldown", sets: 4, reps: 12, restTime: 90),
                PresetExercise(name: "Rowing", sets: 4, reps: 10, restTime: 75),
                PresetExercise(name: "Deadlift", sets: 3, reps: 8, restTime: 120)
            ],
            duration: 50,
            difficulty: "Advanced",
            xpReward: 220
        ),
        PresetWorkout(
            name: "Bras Sculptés",
            emoji: "🔥",
            description: "Tonifiez et renforcez vos bras",
            exercises: [
                PresetExercise(name: "Bicep Curls", sets: 3, reps: 15, restTime: 60),
                PresetExercise(name: "Tricep Dips", sets: 3, reps: 12, restTime: 60),
                PresetExercise(name: "Hammer Curls", sets: 3, reps: 12, restTime: 60),
                PresetExercise(name: "Overhead Press", sets: 3, reps: 10, restTime: 75)
            ],
            duration: 35,
            difficulty: "Beginner",
            xpReward: 140
        ),
        PresetWorkout(
            name: "Jambes Titanium",
            emoji: "🦵",
            description: "Renforcez le bas de votre corps",
            exercises: [
                PresetExercise(name: "Squats", sets: 4, reps: 15, restTime: 90),
                PresetExercise(name: "Lunges", sets: 3, reps: 12, restTime: 60),
                PresetExercise(name: "Leg Press", sets: 4, reps: 12, restTime: 90),
                PresetExercise(name: "Calf Raises", sets: 3, reps: 20, restTime: 45)
            ],
            duration: 40,
            difficulty: "Intermediate",
            xpReward: 160
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("Découvrez nos entraînements")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .padding(.top)
                
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 15) {
                    ForEach(presetWorkouts, id: \.name) { workout in
                        PresetWorkoutCard(workout: workout) {
                            selectedWorkout = workout
                        }
                    }
                }
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .sheet(item: $selectedWorkout) { workout in
            PresetWorkoutDetailView(workout: workout)
        }
    }
}

// MARK: - Preset Workout Models
struct PresetWorkout: Identifiable {
    let id = UUID()
    let name: String
    let emoji: String
    let description: String
    let exercises: [PresetExercise]
    let duration: Int // minutes
    let difficulty: String
    let xpReward: Int
}

struct PresetExercise {
    let name: String
    let sets: Int
    let reps: Int
    let restTime: Int // seconds
}

// MARK: - Preset Workout Card
struct PresetWorkoutCard: View {
    let workout: PresetWorkout
    let onTap: () -> Void
    
    var difficultyColor: Color {
        switch workout.difficulty {
        case "Beginner": return .green
        case "Intermediate": return .orange
        case "Advanced": return .red
        default: return .blue
        }
    }
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 15) {
                // Emoji and Title
                VStack(spacing: 8) {
                    Text(workout.emoji)
                        .font(.system(size: 40))
                    
                    Text(workout.name)
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                
                // Info
                VStack(spacing: 5) {
                    HStack {
                        Image(systemName: "clock")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                        Text("\(workout.duration)min")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    Text(workout.difficulty)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(difficultyColor)
                    
                    Text("\(workout.xpReward) XP")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .frame(height: 160)
            .background(Color.white.opacity(0.1))
            .cornerRadius(16)
            .shadow(color: difficultyColor.opacity(0.3), radius: 5)
        }
    }
}

// MARK: - Preset Workout Detail View
struct PresetWorkoutDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let workout: PresetWorkout
    @State private var isStarted = false
    @State private var completedExercises: Set<String> = []
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        VStack(spacing: 15) {
                            Text(workout.emoji)
                                .font(.system(size: 60))
                            
                            Text(workout.name)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(workout.description)
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Workout Info
                        HStack(spacing: 30) {
                            VStack {
                                Text("\(workout.duration)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                Text("Minutes")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack {
                                Text("\(workout.exercises.count)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.purple)
                                Text("Exercises")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            
                            VStack {
                                Text("\(workout.xpReward)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.green)
                                Text("XP Reward")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Exercises List
                        VStack(alignment: .leading, spacing: 15) {
                            Text("Exercises")
                                .font(.title2)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            
                            ForEach(workout.exercises, id: \.name) { exercise in
                                PresetExerciseRow(
                                    exercise: exercise,
                                    isCompleted: completedExercises.contains(exercise.name),
                                    onToggle: {
                                        if completedExercises.contains(exercise.name) {
                                            completedExercises.remove(exercise.name)
                                        } else {
                                            completedExercises.insert(exercise.name)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Complete Button
                        Button("Complete Workout (+\(workout.xpReward) XP)") {
                            // Add workout completion logic
                            dismiss()
                        }
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [.green, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .green.opacity(0.3), radius: 10)
                        .disabled(completedExercises.count < workout.exercises.count)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Workout Details")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

// MARK: - Preset Exercise Row
struct PresetExerciseRow: View {
    let exercise: PresetExercise
    let isCompleted: Bool
    let onToggle: () -> Void
    
    var body: some View {
        HStack {
            Button(action: onToggle) {
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.title3)
                    .foregroundColor(isCompleted ? .green : .white.opacity(0.3))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.white)
                    .strikethrough(isCompleted)
                
                Text("\(exercise.sets) sets × \(exercise.reps) reps • \(exercise.restTime)s rest")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
        }
        .padding(12)
        .background(isCompleted ? Color.green.opacity(0.1) : Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Simple Progress View
struct SimpleProgressView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Level Progress
                        VStack(spacing: 15) {
                            Text("Hunter Progress")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            HStack {
                                VStack(alignment: .leading) {
                                    Text("Level 1")
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.blue)
                                    
                                    Text("Newbie Hunter")
                                        .font(.subheadline)
                                        .foregroundColor(.purple.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                VStack {
                                    Text("0 / 100 XP")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                    
                                    ProgressView(value: 0.0)
                                        .progressViewStyle(LinearProgressViewStyle(tint: .blue))
                                        .frame(width: 100)
                                }
                            }
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        
                        // Stats Grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 15) {
                            StatCard(title: "Workouts", value: "0", color: .blue)
                            StatCard(title: "Total XP", value: "0", color: .purple)
                            StatCard(title: "Streak", value: "0 days", color: .orange)
                            StatCard(title: "Best Week", value: "0", color: .yellow)
                        }
                        
                        // Coming Soon
                        VStack(spacing: 10) {
                            Text("📊 Advanced Analytics")
                                .font(.title2)
                                .foregroundColor(.white)
                            
                            Text("Detailed charts and progress tracking coming soon!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }
                        .padding(20)
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(16)
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Progress")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
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

// MARK: - Simple Quests View
struct SimpleQuestsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        Text("🎯 Daily Quests")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        // Daily Quests
                        VStack(spacing: 15) {
                            QuestCardSimple(
                                title: "First Training",
                                description: "Complete your first workout",
                                reward: "50 XP",
                                isCompleted: false
                            )
                            
                            QuestCardSimple(
                                title: "Consistency Builder",
                                description: "Train 3 times this week",
                                reward: "100 XP",
                                isCompleted: false
                            )
                            
                            QuestCardSimple(
                                title: "Volume Master",
                                description: "Complete 50 total reps",
                                reward: "75 XP",
                                isCompleted: false
                            )
                        }
                        
                        Text("🏆 Weekly Challenges")
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        VStack(spacing: 15) {
                            QuestCardSimple(
                                title: "Weekly Warrior",
                                description: "Complete 5 workouts this week",
                                reward: "250 XP",
                                isCompleted: false
                            )
                            
                            QuestCardSimple(
                                title: "Strength Builder",
                                description: "Lift 1000kg total this week",
                                reward: "300 XP",
                                isCompleted: false
                            )
                        }
                        
                        Spacer(minLength: 50)
                    }
                    .padding()
                }
            }
            .navigationTitle("Quests")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
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

// MARK: - Simple Stat Card
struct StatCard: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.white)
            
            Text(title)
                .font(.caption)
                .foregroundColor(.white.opacity(0.7))
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(color.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - Simple Quest Card
struct QuestCardSimple: View {
    let title: String
    let description: String
    let reward: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 5) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            Spacer()
            
            VStack(alignment: .trailing, spacing: 5) {
                Text(reward)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                } else {
                    Image(systemName: "circle")
                        .foregroundColor(.white.opacity(0.3))
                }
            }
        }
        .padding(16)
        .background(Color.white.opacity(0.1))
        .cornerRadius(12)
    }
}

#Preview {
    ContentView()
}
