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
            Quest.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
