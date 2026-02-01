//
//  AuthApp.swift
//  Auth
//
//  Created by MAIGNE JEAN-FRANCOIS on 01/02/2026.
//

import SwiftUI
import CoreData

@main
struct AuthApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
