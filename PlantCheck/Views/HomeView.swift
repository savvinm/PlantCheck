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
    let fsm = FileSystemManager()
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Plant.name, ascending: true)],
        animation: .default)
    private var plants: FetchedResults<Plant>
    @State var isAddingSheetPresented = false
    
    var body: some View {
        NavigationView{
            ScrollView{
                LazyVGrid(columns: [GridItem(), GridItem()], alignment: .center, spacing: 20){
                    ForEach(plants) { plant in
                        plantPreview(for: plant)
                            //.padding()
                            .frame(width: UIScreen.main.bounds.width * 0.44, height: UIScreen.main.bounds.width * 0.66)
                            .shadow(color: Color(.systemGray4), radius: 5, x: 5, y: 5)
                    }
                }
                .padding(.bottom)
                .padding(.horizontal, 10)
            }
            .ignoresSafeArea(.keyboard)
            .sheet(isPresented: $isAddingSheetPresented, content: { AddPlantView() })
            .toolbar {
                ToolbarItem {
                    Button(action: { isAddingSheetPresented = true}){
                        Image(systemName: "plus")
                    }
                }
            }
            .background{
            Image("background")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                .ignoresSafeArea(edges: .all)
                .opacity(0.25)
            }
        }
    }

    private func plantPreview(for plant: Plant) -> some View{
        GeometryReader{ geometry in
            NavigationLink(destination: { PlantDetailView(plant: plant, fsm: fsm) }){
            ZStack(alignment: .center){
                    VStack{
                        if plant.imagesPath == nil{
                            Image("default")
                                .resizable()
        
                        } else {
                            Image(uiImage: (plant.getThumbnail(with: fsm))!)
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
                Text(plant.genus!)
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
                .opacity(0.85)
        }
        //.cornerRadius(15)
        //.padding(5)
        //.opacity(0.8)
    }
    
    /*
     VStack(alignment: .center, spacing: 0){
             VStack{
                 if plant.imagesPath == nil{
                     Image("default")
                         .resizable()
 
                 } else {
                     Image(uiImage: (plant.getThumbnail(with: fsm))!)
                         .resizable()
                 }
             }
             .aspectRatio(contentMode: .fill)
             .frame(width: geometry.size.width, height: geometry.size.height * 0.75)
             //.clipped()

             VStack(alignment: .leading){
                 HStack{
                     Text(plant.genus!)
                         //.padding()
                         .multilineTextAlignment(.leading)
                         
                         .font(.subheadline)
                     
                     Spacer()
                 }
                 Text("Name")
                     .font(.footnote)
             }
             .foregroundColor(.primary)
             .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
             .background{
                 Rectangle()
                     .foregroundColor(Color(.white))
                     .opacity(1)
             }
         }
     
     .cornerRadius(15)
     */
    
    
    
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
