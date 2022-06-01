//
//  TodayWateringScroll.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 12.05.2022.
//

import CoreData
import SwiftUI

struct TodayWateringScroll: View {
    
    private var toWater = [Plant]()
    private var watered = [Plant]()
    let fileSystemManager: FileSystemManager
    let coreDataController: CoreDataController
    
    @State var isShowingPlantSheet = false
    
    init(fileSystemManager: FileSystemManager, coreDataController: CoreDataController, context: NSManagedObjectContext) {
        self.fileSystemManager = fileSystemManager
        self.coreDataController = coreDataController
        let pair = coreDataController.getPlantsForWateringScroll(context: context)
        toWater = pair.toWater
        watered = pair.watered
    }
    
    var body: some View {
        GeometryReader { geometry in
            if toWater.count > 0 || watered.count > 0 {
                wateringScrollView(in: geometry)
            } else {
                HStack {
                    Spacer()
                    Text("No plants to water today")
                        .foregroundColor(.secondary)
                        .font(.headline)
                        .padding()
                    Spacer()
                }
            }
        }
    }
    
    private func wateringScrollView(in geometry: GeometryProxy) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 10) {
                if toWater.count > 0 {
                    inScrollForEach(for: toWater, in: geometry)
                }
                if watered.count > 0 {
                    inScrollForEach(for: watered, in: geometry)
                        .opacity(0.4)
                }
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal)
            .sheet(isPresented: $isShowingPlantSheet, content: { PlantDetailView(plant: coreDataController.selectedPlant!, fileSystemManager: fileSystemManager, coreDataController: coreDataController, isInSheet: true) })
        }
    }
    
    private func inScrollForEach(for plants: [Plant], in geometry: GeometryProxy) -> some View {
        ForEach(plants) { plant in
            plantLink(for: plant)
                .frame(width: geometry.size.width * 0.22, height: geometry.size.width * 0.4)
        }
    }
    
    private func selectPlant(plant: Plant) {
        coreDataController.selectedPlant = plant
        if coreDataController.selectedPlant != nil {
            isShowingPlantSheet = true
        }
    }
    
    private func plantLink(for plant: Plant) -> some View {
        GeometryReader { geometry in
            Button(action: { selectPlant(plant: plant) }, label: {
                plantView(for: plant, in: geometry)
            })
            .contentShape(TapShape())
            .frame(width: geometry.size.width, height: geometry.size.height)
        }
    }
    
    private func plantView(for plant: Plant, in geometry: GeometryProxy) -> some View {
        VStack(alignment: .center) {
            image(for: plant, in: geometry)
            Text(plant.genus ?? "")
                .font(.footnote)
            Spacer()
        }
        .background(Color.clear)
    }
    
    private func image(for plant: Plant, in geometry: GeometryProxy) -> some View {
        VStack {
            if plant.imagesPath == nil {
                Image("default")
                    .resizable()
            } else {
                Image(uiImage: (plant.getThumbnail(with: fileSystemManager))!)
                    .resizable()
            }
        }
        .aspectRatio(contentMode: .fill)
        .frame(width: geometry.size.width, height: geometry.size.height * 0.8)
        .clipped()
        .cornerRadius(10)
    }
}

struct TapShape: Shape {
    func path(in rect: CGRect) -> Path {
        return Path(CGRect(x: 0, y: 0, width: rect.width, height: rect.height))
    }
}
