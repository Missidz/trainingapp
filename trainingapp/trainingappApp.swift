//
//  trainingappApp.swift
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//

import SwiftUI
import SwiftData

@main
struct trainingappApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            User.self,
            Workout.self,
            Exercise.self,
            Achievement.self,
            Quest.self,
            Meal.self,
            FoodItem.self,
            NutritionGoals.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("⚠️ Erreur SwiftData détectée: \(error)")
            print("🔄 Tentative de résolution automatique...")
            
            // Étape 1: Essayer de supprimer les anciens fichiers et recréer la DB
            do {
                // Supprimer l'ancienne base de données
                let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
                if let appSupportDir = urls.first {
                    let storeURL = appSupportDir.appendingPathComponent("default.store")
                    let walURL = appSupportDir.appendingPathComponent("default.store-wal")
                    let shmURL = appSupportDir.appendingPathComponent("default.store-shm")
                    
                    try? FileManager.default.removeItem(at: storeURL)
                    try? FileManager.default.removeItem(at: walURL)
                    try? FileManager.default.removeItem(at: shmURL)
                    print("🗑️ Anciens fichiers DB supprimés")
                }
                
                // Créer un nouveau container persistant avec la DB fraîche
                let freshConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
                let freshContainer = try ModelContainer(for: schema, configurations: [freshConfig])
                print("✅ Nouveau container persistant créé avec succès")
                return freshContainer
                
            } catch {
                print("❌ Impossible de créer un container persistant: \(error)")
                print("⚡ Utilisation d'un container temporaire pour cette session")
                
                // Seulement en dernier recours : container en mémoire
                let memoryConfig = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
                do {
                    return try ModelContainer(for: schema, configurations: [memoryConfig])
                } catch {
                    fatalError("💥 Impossible de créer tout type de ModelContainer: \(error)")
                }
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
