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
        NavigationView{
            ScrollView{
                VStack(alignment: .leading){
                    Text("Water today")
                        .font(.title)
                        .fontWeight(Font.Weight.semibold)
                        .padding(.horizontal)
                    TodayWateringScroll(fileSystemManager: fileSystemManager, coreDataController: coreDataController, context: viewContext)
                        .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.22)
                        .padding(.bottom)
                }
                .padding(.vertical)
                VStack{
                    HStack{
                        Text("Your plants")
                            .font(.title)
                            .fontWeight(Font.Weight.semibold)
                        Button(action: { isAddingSheetPresented = true}){
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(.secondary)
                                .font(Font.system(size: 20))
                        }
                        .padding(.top, -8)
                        .padding(.leading, -5)
                        Spacer()
                    }
                    if plants.count > 0{
                        LazyVGrid(columns: [GridItem(), GridItem()], alignment: .center, spacing: 20){
                            ForEach(plants) { plant in
                                plantPreview(for: plant)
                                    .frame(width: UIScreen.main.bounds.width * 0.42, height: UIScreen.main.bounds.width * 0.64)
                                    .shadow(color: Color(.systemGray4), radius: 5, x: 5, y: 5)
                            }
                        }
                    } else {
                        Text("No plants here")
                            .foregroundColor(.secondary)
                            .font(.headline)
                            .padding()
                    }
                }
                .padding(.bottom)
                .padding(.horizontal)
            }
            .padding(.top)
            .modifier(ImageBackground(geometry: nil))
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $isAddingSheetPresented, content: { AddPlantView() })
            .navigationBarHidden(true)
        }
    }

    private func plantPreview(for plant: Plant) -> some View{
        GeometryReader{ geometry in
            NavigationLink(destination: { PlantDetailView(plant: plant, fileSystemManager: fileSystemManager, coreDataController: coreDataController, isInSheet: false) }){
                ZStack(alignment: .center){
                        VStack{
                            if plant.imagesPath == nil{
                                Image("default")
                                    .resizable()
            
                            } else {
                                Image(uiImage: (plant.getThumbnail(with: fileSystemManager))!)
                                    .resizable()
                            }
                        }
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        //.clipped()
                        .overlay(alignment: .bottomLeading){
                            imageOverlay(for: plant)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.3)
                        }
                        //.overlay(imageOverlay(for: plant), alignment: .bottomLeading)

                }
                
                .cornerRadius(15)
            }
        }
    }
    
    private func imageOverlay(for plant: Plant) -> some View{
        HStack{
            VStack(alignment: .leading){
                Spacer()
                Text(plant.genus ?? "")
                    .font(.subheadline)
                    .fontWeight(Font.Weight.semibold)
                if plant.name != nil{
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
        .background{
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
