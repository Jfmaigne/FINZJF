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
    @StateObject private var sessionManager = SessionManager()
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(sessionManager)
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
