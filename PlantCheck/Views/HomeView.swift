//
//  HomeView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 29.04.2022.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.name, ascending: true)],
        animation: .default)
    private var plants: FetchedResults<Plant>
    @State var isAddingSheetPresented = false
    
    var body: some View {
        NavigationView{
            List {
                ForEach(plants) { plant in
                    VStack{
                        Text(plant.name!)
                        Text(plant.creationDate!.formatted())
                        Text(plant.nextWatering!.formatted())
                    }
                }
                .onDelete(perform: deleteItems)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: { isAddingSheetPresented = true}){
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isAddingSheetPresented, content: { AddPlantView() })
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { plants[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
