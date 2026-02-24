//
//  AuthApp.swift
//  Auth
//
//  Created by MAIGNE JEAN-FRANCOIS on 01/02/2026.
//

import SwiftUI
import UIKit
import CoreData

@main
struct AuthApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
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

