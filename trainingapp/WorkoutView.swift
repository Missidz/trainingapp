//
//  WorkoutView.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import SwiftData

struct WorkoutView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var workoutName = ""
    @State private var selectedDifficulty = "Normal"
    @State private var exercises = [ExerciseRow]()
    @State private var notes = ""
    @State private var isAwakening = false
    @State private var workoutStarted = false
    @State private var startTime = Date()
    
    let difficulties = ["Easy", "Normal", "Hard", "Nightmare"]
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 25) {
                        // Header
                        WorkoutHeader(
                            isStarted: workoutStarted,
                            startTime: startTime,
                            onStart: startWorkout,
                            onStop: stopWorkout
                        )
                        
                        // Workout Configuration
                        if !workoutStarted {
                            WorkoutConfigurationSection(
                                workoutName: $workoutName,
                                selectedDifficulty: $selectedDifficulty,
                                isAwakening: $isAwakening,
                                difficulties: difficulties
                            )
                        }
                        
                        // Exercises Section
                        ExercisesSection(
                            exercises: $exercises,
                            isActive: workoutStarted
                        )
                        
                        // Notes Section
                        NotesSection(notes: $notes)
                        
                        Spacer(minLength: 100)
                    }
                    .padding()
                }
            }
            .navigationTitle("Training Session")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.red)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        saveWorkout()
                    }
                    .disabled(exercises.isEmpty)
                    .foregroundColor(.blue)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func startWorkout() {
        workoutStarted = true
        startTime = Date()
    }
    
    private func stopWorkout() {
        workoutStarted = false
    }
    
    private func saveWorkout() {
        // Sauvegarder l'entraînement
        let duration = Date().timeIntervalSince(startTime)
        let totalXP = calculateXP()
        
        // Ici on créerait un objet Workout et on l'enregistrerait
        // Pour l'instant, on ferme juste la vue
        dismiss()
    }
    
    private func calculateXP() -> Int {
        let baseXP = exercises.reduce(0) { total, exercise in
            return total + (exercise.sets * exercise.reps)
        }
        
        let difficultyMultiplier: Double = switch selectedDifficulty {
        case "Easy": 0.8
        case "Normal": 1.0
        case "Hard": 1.3
        case "Nightmare": 1.7
        default: 1.0
        }
        
        let awakeningBonus = isAwakening ? 1.5 : 1.0
        
        return Int(Double(baseXP) * difficultyMultiplier * awakeningBonus)
    }
}

// MARK: - Workout Header
struct WorkoutHeader: View {
    let isStarted: Bool
    let startTime: Date
    let onStart: () -> Void
    let onStop: () -> Void
    
    @State private var currentTime = Date()
    
    var elapsedTime: TimeInterval {
        currentTime.timeIntervalSince(startTime)
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack(alignment: .leading) {
                    Text(isStarted ? "Training Active" : "Ready to Train")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    if isStarted {
                        Text(String(format: "%02d:%02d", Int(elapsedTime) / 60, Int(elapsedTime) % 60))
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                    }
                }
                
                Spacer()
                
                Button(action: isStarted ? onStop : onStart) {
                    Image(systemName: isStarted ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(isStarted ? .red : .green)
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
        .shadow(color: .blue.opacity(0.2), radius: 10)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}

// MARK: - Workout Configuration Section
struct WorkoutConfigurationSection: View {
    @Binding var workoutName: String
    @Binding var selectedDifficulty: String
    @Binding var isAwakening: Bool
    let difficulties: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Training Configuration")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            // Workout Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Session Name")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                TextField("Enter workout name", text: $workoutName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
            }
            
            // Difficulty Selection
            VStack(alignment: .leading, spacing: 8) {
                Text("Difficulty Level")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
                
                Picker("Difficulty", selection: $selectedDifficulty) {
                    ForEach(difficulties, id: \.self) { difficulty in
                        Text(difficulty).tag(difficulty)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
            }
            
            // Awakening Toggle
            Toggle(isOn: $isAwakening) {
                HStack {
                    Image(systemName: "star.fill")
                        .foregroundColor(.purple)
                    Text("Awakening Session")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    Text("(+50% XP)")
                        .font(.caption)
                        .foregroundColor(.purple.opacity(0.8))
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .purple))
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

// MARK: - Exercises Section
struct ExercisesSection: View {
    @Binding var exercises: [ExerciseRow]
    let isActive: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Exercises")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Button(action: addExercise) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
            
            if exercises.isEmpty {
                Text("No exercises added yet. Tap + to add one!")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.6))
                    .padding()
            } else {
                ForEach(exercises.indices, id: \.self) { index in
                    ExerciseRowView(
                        exercise: $exercises[index],
                        onDelete: {
                            exercises.remove(at: index)
                        }
                    )
                }
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
    
    private func addExercise() {
        exercises.append(ExerciseRow())
    }
}

// MARK: - Exercise Row
struct ExerciseRow {
    var name = ""
    var sets = 1
    var reps = 10
    var weight = 0.0
    var restTime = 60
}

struct ExerciseRowView: View {
    @Binding var exercise: ExerciseRow
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            // Exercise Name
            TextField("Exercise name", text: $exercise.name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            
            // Exercise Details
            HStack(spacing: 15) {
                VStack {
                    Text("Sets")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Stepper("\(exercise.sets)", value: $exercise.sets, in: 1...50)
                        .labelsHidden()
                }
                
                VStack {
                    Text("Reps")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    Stepper("\(exercise.reps)", value: $exercise.reps, in: 1...100)
                        .labelsHidden()
                }
                
                VStack {
                    Text("Weight (kg)")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                    TextField("0", value: $exercise.weight, format: .number)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .frame(width: 80)
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
            }
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(12)
    }
}

// MARK: - Notes Section
struct NotesSection: View {
    @Binding var notes: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Training Notes")
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.white)
            
            TextField("How did you feel? Any observations...", text: $notes, axis: .vertical)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .lineLimit(3...6)
        }
        .padding(20)
        .background(Color.white.opacity(0.1))
        .cornerRadius(16)
    }
}

#Preview {
    WorkoutView()
} 