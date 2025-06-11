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
                        
                        // XP Preview (pendant l'entraînement)
                        if workoutStarted && !exercises.isEmpty {
                            XPPreviewCard(
                                exercises: exercises,
                                difficulty: selectedDifficulty,
                                isAwakening: isAwakening,
                                startTime: startTime
                            )
                        }
                        
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
        // Créer l'objet Workout
        let duration = Date().timeIntervalSince(startTime)
        let totalXP = calculateXP()
        
        let workout = Workout(
            name: workoutName.isEmpty ? "Training Session" : workoutName,
            date: startTime,
            duration: duration,
            notes: notes,
            isAwakening: isAwakening
        )
        
        // Convertir la difficulté string en enum
        workout.difficulty = WorkoutDifficulty(rawValue: selectedDifficulty) ?? .normal
        workout.experienceGained = totalXP
        
        // Ajouter les exercices
        for exerciseRow in exercises {
            let exercise = Exercise(
                name: exerciseRow.name.isEmpty ? "Exercise" : exerciseRow.name,
                sets: exerciseRow.sets,
                reps: exerciseRow.reps,
                weight: exerciseRow.weight,
                restTime: TimeInterval(exerciseRow.restTime)
            )
            
            // Définir le type d'exercice par défaut
            exercise.exerciseType = .strength
            workout.exercises.append(exercise)
            modelContext.insert(exercise)
        }
        
        // Sauvegarder dans la base de données
        modelContext.insert(workout)
        
        do {
            try modelContext.save()
            print("Workout sauvegardé avec succès: \(workout.name), XP: \(totalXP)")
        } catch {
            print("Erreur lors de la sauvegarde: \(error)")
        }
        
        dismiss()
    }
    
    private func calculateXP() -> Int {
        let duration = Date().timeIntervalSince(startTime) / 60 // en minutes
        
        // 1. Volume de travail (sets × reps × facteur poids)
        let totalVolume = exercises.reduce(0.0) { total, exercise in
            let weightFactor = exercise.weight > 0 ? (1.0 + exercise.weight / 100.0) : 1.0
            return total + Double(exercise.sets * exercise.reps) * weightFactor
        }
        
        // 2. Bonus de durée adaptatif
        let durationBonus: Double = {
            switch duration {
            case 0..<15:    return 0.5  // Très court
            case 15..<30:   return 0.8  // Court
            case 30..<45:   return 1.0  // Optimal
            case 45..<60:   return 1.1  // Long
            case 60..<90:   return 1.2  // Très long
            case 90...:     return 1.3  // Extrême
            default:        return 1.0
            }
        }()
        
        // 3. Facteur d'intensité (volume par minute)
        let intensity = duration > 0 ? totalVolume / duration : totalVolume
        let intensityMultiplier: Double = {
            switch intensity {
            case 0..<10:    return 0.8  // Faible intensité
            case 10..<20:   return 1.0  // Intensité normale
            case 20..<35:   return 1.2  // Haute intensité
            case 35...:     return 1.4  // Intensité extrême
            default:        return 1.0
            }
        }()
        
        // 4. Multiplicateur de difficulté
        let difficultyMultiplier: Double = switch selectedDifficulty {
        case "Easy":        1.0   // Facile mais pas pénalisé
        case "Normal":      1.1   // Légèrement avantagé
        case "Hard":        1.3   // Bien récompensé
        case "Nightmare":   1.6   // Très bien récompensé
        default:            1.0
        }
        
        // 5. Bonus pour équilibre effort/temps
        let balanceBonus: Double = {
            let timeRatio = min(duration / 45.0, 2.0) // Ratio basé sur 45min optimal
            let difficultyRatio = difficultyMultiplier
            
            // Récompense l'équilibre entre temps et difficulté
            if timeRatio > 1.0 && difficultyRatio < 1.3 {
                return 1.15 // Bonus pour entraînement long mais moins intense
            } else if timeRatio < 1.0 && difficultyRatio > 1.2 {
                return 1.15 // Bonus pour entraînement court mais intense
            } else {
                return 1.0
            }
        }()
        
        // 6. Bonus Awakening
        let awakeningBonus = isAwakening ? 1.4 : 1.0
        
        // 7. Calcul final avec minimum garanti
        let baseXP = max(totalVolume * 0.5, 10.0) // Minimum 10 XP
        let finalXP = baseXP * durationBonus * intensityMultiplier * difficultyMultiplier * balanceBonus * awakeningBonus
        
        // 8. Bonus de cohérence (si plus de 3 exercices différents)
        let varietyBonus = exercises.count >= 3 ? 1.1 : 1.0
        
        return Int(finalXP * varietyBonus)
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
        VStack(spacing: 15) {
            // Exercise Name with Delete Button
            HStack {
                TextField("Nom de l'exercice", text: $exercise.name)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                Button(action: onDelete) {
                    Image(systemName: "trash.circle.fill")
                        .font(.title2)
                        .foregroundColor(.red)
                }
            }
            
            // Exercise Details Grid
            VStack(spacing: 15) {
                HStack(spacing: 20) {
                    // Sets Section
                    VStack(spacing: 8) {
                        Text("Séries")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 8) {
                            Button(action: { 
                                if exercise.sets > 1 { exercise.sets -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(exercise.sets > 1 ? .blue : .gray)
                            }
                            .disabled(exercise.sets <= 1)
                            
                            Text("\(exercise.sets)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: { 
                                if exercise.sets < 50 { exercise.sets += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(exercise.sets < 50 ? .blue : .gray)
                            }
                            .disabled(exercise.sets >= 50)
                        }
                    }
                    
                    // Separator
                    Rectangle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 1, height: 60)
                    
                    // Reps Section
                    VStack(spacing: 8) {
                        Text("Répétitions")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundColor(.green)
                        
                        HStack(spacing: 8) {
                            Button(action: { 
                                if exercise.reps > 1 { exercise.reps -= 1 }
                            }) {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(exercise.reps > 1 ? .green : .gray)
                            }
                            .disabled(exercise.reps <= 1)
                            
                            Text("\(exercise.reps)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .frame(minWidth: 40)
                            
                            Button(action: { 
                                if exercise.reps < 100 { exercise.reps += 1 }
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(exercise.reps < 100 ? .green : .gray)
                            }
                            .disabled(exercise.reps >= 100)
                        }
                    }
                }
                
                // Weight Section
                VStack(spacing: 8) {
                    Text("Poids (kg)")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.orange)
                    
                    HStack(spacing: 8) {
                        Button(action: { 
                            if exercise.weight > 0 { 
                                exercise.weight = max(0, exercise.weight - 2.5)
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .font(.title2)
                                .foregroundColor(exercise.weight > 0 ? .orange : .gray)
                        }
                        .disabled(exercise.weight <= 0)
                        
                        TextField("0", value: $exercise.weight, format: .number)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .frame(width: 80)
                            .multilineTextAlignment(.center)
                        
                        Button(action: { 
                            exercise.weight += 2.5
                        }) {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                // Quick Sets/Reps Presets
                VStack(spacing: 8) {
                    Text("Préréglages rapides")
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.7))
                    
                    HStack(spacing: 8) {
                        QuickSetButton(title: "3x10", sets: 3, reps: 10, exercise: $exercise)
                        QuickSetButton(title: "4x8", sets: 4, reps: 8, exercise: $exercise)
                        QuickSetButton(title: "5x5", sets: 5, reps: 5, exercise: $exercise)
                        QuickSetButton(title: "3x12", sets: 3, reps: 12, exercise: $exercise)
                    }
                }
            }
        }
        .padding(16)
        .background(
            LinearGradient(
                colors: [Color.white.opacity(0.15), Color.white.opacity(0.05)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.3), radius: 5)
    }
}

// MARK: - Quick Set Button
struct QuickSetButton: View {
    let title: String
    let sets: Int
    let reps: Int
    @Binding var exercise: ExerciseRow
    
    var body: some View {
        Button(action: {
            exercise.sets = sets
            exercise.reps = reps
        }) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(8)
        }
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

// MARK: - XP Preview Card
struct XPPreviewCard: View {
    let exercises: [ExerciseRow]
    let difficulty: String
    let isAwakening: Bool
    let startTime: Date
    
    @State private var currentTime = Date()
    
    private var currentXP: Int {
        let duration = currentTime.timeIntervalSince(startTime) / 60
        
        // Même calcul que dans calculateXP mais adapté
        let totalVolume = exercises.reduce(0.0) { total, exercise in
            let weightFactor = exercise.weight > 0 ? (1.0 + exercise.weight / 100.0) : 1.0
            return total + Double(exercise.sets * exercise.reps) * weightFactor
        }
        
        let durationBonus: Double = {
            switch duration {
            case 0..<15:    return 0.5
            case 15..<30:   return 0.8
            case 30..<45:   return 1.0
            case 45..<60:   return 1.1
            case 60..<90:   return 1.2
            case 90...:     return 1.3
            default:        return 1.0
            }
        }()
        
        let intensity = duration > 0 ? totalVolume / duration : totalVolume
        let intensityMultiplier: Double = {
            switch intensity {
            case 0..<10:    return 0.8
            case 10..<20:   return 1.0
            case 20..<35:   return 1.2
            case 35...:     return 1.4
            default:        return 1.0
            }
        }()
        
        let difficultyMultiplier: Double = switch difficulty {
        case "Easy":        1.0
        case "Normal":      1.1
        case "Hard":        1.3
        case "Nightmare":   1.6
        default:            1.0
        }
        
        let balanceBonus: Double = {
            let timeRatio = min(duration / 45.0, 2.0)
            let difficultyRatio = difficultyMultiplier
            
            if timeRatio > 1.0 && difficultyRatio < 1.3 {
                return 1.15
            } else if timeRatio < 1.0 && difficultyRatio > 1.2 {
                return 1.15
            } else {
                return 1.0
            }
        }()
        
        let awakeningBonus = isAwakening ? 1.4 : 1.0
        let baseXP = max(totalVolume * 0.5, 10.0)
        let finalXP = baseXP * durationBonus * intensityMultiplier * difficultyMultiplier * balanceBonus * awakeningBonus
        let varietyBonus = exercises.count >= 3 ? 1.1 : 1.0
        
        return Int(finalXP * varietyBonus)
    }
    
    private var durationMinutes: Int {
        Int(currentTime.timeIntervalSince(startTime) / 60)
    }
    
    private var intensityLevel: String {
        let duration = currentTime.timeIntervalSince(startTime) / 60
        guard duration > 0 else { return "..." }
        
        let totalVolume = exercises.reduce(0.0) { total, exercise in
            let weightFactor = exercise.weight > 0 ? (1.0 + exercise.weight / 100.0) : 1.0
            return total + Double(exercise.sets * exercise.reps) * weightFactor
        }
        
        let intensity = totalVolume / duration
        
        switch intensity {
        case 0..<10:    return "Faible"
        case 10..<20:   return "Normale"
        case 20..<35:   return "Élevée"
        case 35...:     return "Extrême"
        default:        return "Normale"
        }
    }
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                Image(systemName: "star.circle.fill")
                    .font(.title2)
                    .foregroundColor(.purple)
                
                Text("Progression XP")
                    .font(.headline)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text("+\(currentXP) XP")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.purple)
                    .shadow(color: .purple.opacity(0.5), radius: 5)
            }
            
            // Métriques de performance
            HStack(spacing: 20) {
                VStack(spacing: 4) {
                    Text("\(durationMinutes)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                    Text("minutes")
                        .font(.caption2)
                        .foregroundColor(.blue.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text("\(exercises.count)")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.green)
                    Text("exercices")
                        .font(.caption2)
                        .foregroundColor(.green.opacity(0.8))
                }
                
                VStack(spacing: 4) {
                    Text(intensityLevel)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.orange)
                    Text("intensité")
                        .font(.caption2)
                        .foregroundColor(.orange.opacity(0.8))
                }
                
                if isAwakening {
                    VStack(spacing: 4) {
                        Text("+40%")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundColor(.purple)
                        Text("awakening")
                            .font(.caption2)
                            .foregroundColor(.purple.opacity(0.8))
                    }
                }
            }
            
            // Conseils adaptatifs
            if durationMinutes > 0 {
                AdaptiveTip(
                    duration: durationMinutes,
                    exerciseCount: exercises.count,
                    intensity: intensityLevel,
                    difficulty: difficulty
                )
            }
        }
        .padding(20)
        .background(
            LinearGradient(
                colors: [Color.purple.opacity(0.2), Color.purple.opacity(0.1)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.purple.opacity(0.5), lineWidth: 1)
        )
        .shadow(color: .purple.opacity(0.3), radius: 10)
        .onAppear {
            Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { _ in
                currentTime = Date()
            }
        }
    }
}

// MARK: - Adaptive Tip
struct AdaptiveTip: View {
    let duration: Int
    let exerciseCount: Int
    let intensity: String
    let difficulty: String
    
    private var tip: String {
        if duration < 15 {
            return "⚡ Entraînement court détecté. Augmentez l'intensité pour plus d'XP !"
        } else if duration > 75 {
            return "🔥 Session longue ! Votre endurance vous rapporte des bonus XP."
        } else if exerciseCount < 3 {
            return "🎯 Ajoutez plus d'exercices pour un bonus de variété (+10% XP)."
        } else if intensity == "Faible" && difficulty == "Easy" {
            return "💪 Essayez d'augmenter la difficulté ou l'intensité pour optimiser vos gains."
        } else if intensity == "Extrême" {
            return "🚀 Intensité maximale ! Vous gagnez des bonus d'intensité."
        } else {
            return "✅ Excellent équilibre ! Continuez sur cette lancée."
        }
    }
    
    var body: some View {
        HStack {
            Text(tip)
                .font(.caption)
                .foregroundColor(.white.opacity(0.9))
            
            Spacer()
        }
        .padding(12)
        .background(Color.black.opacity(0.3))
        .cornerRadius(8)
    }
}

#Preview {
    WorkoutView()
} 