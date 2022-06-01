//
//  HomeView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 29.04.2022.
//

import CoreData
import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    let fileSystemManager = FileSystemManager()
    let coreDataController = CoreDataController()
    
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.genus, ascending: true), NSSortDescriptor(keyPath: \Plant.name, ascending: true)],
        animation: .default)
    private var plants: FetchedResults<Plant>

    @State var isAddingSheetPresented = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                todayWateringBlock
                    .padding(.vertical)
                plantsBlock
                    .padding(.bottom)
                    .padding(.horizontal)
            }
            .padding(.top)
            .modifier(ImageBackground(geometry: nil))
            .sheet(isPresented: $isAddingSheetPresented, content: { AddPlantView() })
            .navigationBarHidden(true)
        }
    }

    private var todayWateringBlock: some View {
        VStack(alignment: .leading) {
            Text("Water today")
                .font(.title)
                .fontWeight(Font.Weight.semibold)
                .padding(.horizontal)
            TodayWateringScroll(fileSystemManager: fileSystemManager, coreDataController: coreDataController, context: viewContext)
                .frame(width: UIScreen.main.bounds.width, height: 150)
                .padding(.bottom)
        }
    }
    
    private var plantsBlock: some View {
        VStack(alignment: .leading) {
            plantsListHeader
            if plants.count > 0 {
                LazyVGrid(columns: [GridItem(), GridItem()], alignment: .center, spacing: 20) {
                    ForEach(plants) { plant in
                        plantLink(for: plant)
                            .frame(width: UIScreen.main.bounds.width * 0.42, height: UIScreen.main.bounds.width * 0.64)
                            .shadow(color: Color(.systemGray4), radius: 5, x: 5, y: 5)
                    }
                }
            } else {
                emptyMessage
            }
        }
    }
    
    private var plantsListHeader: some View {
        HStack {
            Text("My plants")
                .font(.title)
                .fontWeight(Font.Weight.semibold)
            Button(action: { isAddingSheetPresented = true }, label: {
                Image(systemName: "plus.rectangle")
                    .foregroundColor(.primary)
                    .font(Font.system(size: 20))
            })
            .padding(.top, 3)
            .padding(.leading, -3)
        }
    }
    
    private var emptyMessage: some View {
        Text("You don't have any plants yet. Tap \(Image(systemName: "plus.rectangle")) to get started")
            .foregroundColor(.secondary)
            .multilineTextAlignment(.center)
            .font(.headline)
            .padding()
    }
    
    private func plantLink(for plant: Plant) -> some View {
        GeometryReader { geometry in
            NavigationLink(
                destination: { PlantDetailView(plant: plant, fileSystemManager: fileSystemManager, coreDataController: coreDataController, isInSheet: false) },
                label: { plantLabel(for: plant, in: geometry) })
        }
    }
    
    private func plantLabel(for plant: Plant, in geometry: GeometryProxy) -> some View {
        VStack {
            if plant.imagesPath == nil {
                Image("default").resizable()
            } else {
                Image(uiImage: (plant.getThumbnail(with: fileSystemManager))!).resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: geometry.size.width, height: geometry.size.height)
        .overlay(alignment: .bottomLeading) {
            imageOverlay(for: plant).frame(width: geometry.size.width, height: geometry.size.height * 0.3)
        }
        .cornerRadius(15)
    }
    
    private func imageOverlay(for plant: Plant) -> some View {
        HStack {
            VStack(alignment: .leading) {
                Spacer()
                Text(plant.genus ?? "")
                    .font(.subheadline)
                    .fontWeight(Font.Weight.semibold)
                if plant.name != nil {
                    Text(plant.name!)
                        .font(.footnote)
                        .lineLimit(1)
                }
                Spacer()
            }
            .multilineTextAlignment(.leading)
            .padding(.horizontal, 10)
            .foregroundColor(.black)
            Spacer()
        }
        .background {
            Rectangle()
                .foregroundColor(.white)
                .opacity(0.9)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
