//
//  ContentView.swift
//  Auth
//
//  Created by MAIGNE JEAN-FRANCOIS on 01/02/2026.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var session: SessionManager

    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                Text("Bienvenue")
                    .font(.title)
                Text("Cette vue n'utilise plus l'entité d'exemple Item.")
                    .foregroundStyle(.secondary)
            }
            .navigationTitle("Accueil")
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionManager())
}
