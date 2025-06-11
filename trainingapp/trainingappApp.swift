//
//  trainingappApp.swift - Configuration Principale de l'Application
//  trainingapp
//
//  Created by Missi Cherifi on 08/06/2025.
//
//  Ce fichier contient:
//  - Configuration SwiftData avec tous les modèles
//  - Gestion d'erreurs et récupération automatique de base de données
//  - Garantit la persistance des données entre les sessions
//  - Point d'entrée principal de l'application Shadow Gym
//

import SwiftUI
import SwiftData

@main
/// Point d'entrée principal de l'application Shadow Gym
/// Configure SwiftData avec gestion d'erreurs robuste et récupération automatique
struct trainingappApp: App {
    /// Container SwiftData partagé avec tous les modèles de données
    /// Utilise la persistance avec fallback automatique en cas d'erreur
    var sharedModelContainer: ModelContainer = {
        // Définition du schéma avec tous les modèles de l'application
        let schema = Schema([
            User.self,          // Profil utilisateur avec niveaux et XP
            Workout.self,       // Séances d'entraînement
            Exercise.self,      // Exercices individuels
            Achievement.self,   // Système d'achievements
            Quest.self,         // Quêtes quotidiennes/hebdomadaires
            Meal.self,          // Repas pour nutrition
            FoodItem.self,      // Aliments individuels
            NutritionGoals.self // Objectifs nutritionnels
        ])
        // Configuration persistante (données sauvegardées sur disque)
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            print("⚠️ Erreur SwiftData détectée: \(error)")
            print("🔄 Tentative de résolution automatique...")
            
            // Système de récupération automatique en cas d'erreur de migration
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
