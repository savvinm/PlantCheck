//
//  PlantCheckApp.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 29.04.2022.
//

import SwiftUI

@main
struct PlantCheckApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
