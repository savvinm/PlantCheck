//
//  PlantDetailView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 09.05.2022.
//

import SwiftUI

struct PlantDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let plant: Plant
    let fsm: FileSystemManager
    @State var isShowingAlert = false
    @State var isShowingDescription = false
    @State var isShowingWateringLog = false
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView{
                imageScroll(for: plant.getImages(with: fsm), in: geometry)
                VStack{
                    titleSection
                    //Divider()
                    toolBar
                        .frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.15)
                    //Divider()
                    if plant.location != nil{
                        VStack{
                            //Divider()
                            plantSection(title: "Location", value: plant.location!, imageName: "location.fill")
                            //Divider()
                        }
                        .padding(.top)
                    }
                    VStack{
                        //Divider()
                        plantSection(title: "Watering schedule", value: plant.stringWateringInterval ?? "", imageName: "calendar")
                        //Divider()
                    }
                    .padding(.top)
                    VStack{
                        //Divider()
                        plantSection(title: "Next watering", value: plant._nextWatering, imageName: "calendar")
                        //Divider()
                    }
                    .padding(.top)
                    VStack{
                        //Divider()
                        plantSection(title: "Last watered", value: plant._lastWatered, imageName: "calendar")
                        //Divider()
                    }
                    .padding(.top)
                }
                .padding(.top, 5)
                .padding([.horizontal, .bottom])
            }
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $isShowingWateringLog, content: { HistoryView(plant: plant) })
            .sheet(isPresented: $isShowingDescription, content: { WikiDescriptionView(plant: plant) })
            .overlay(alignment: .topLeading){
                HStack{
                    backButton
                    Spacer()
                    deleteButton
                }
            }
            .navigationBarHidden(true)
            .background{
                Image("background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
                    .opacity(0.25)
            }
        }
    }
    
    private func icon(title: String?, imageName: String) -> some View{
        VStack{
            VStack{
                Image(systemName: imageName)
                    .foregroundColor(.secondary)
                    .font(Font.system(size: 30))
            }
            .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
            .background(.thickMaterial)
            .cornerRadius(15)
            if title != nil {
                Text(title!)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private var toolBar: some View{
        GeometryReader{ geometry in
            HStack{
                Spacer()
                Button(action: { waterPlant() }){
                    icon(title: "Water", imageName: "drop.fill")
                        .padding()
                }
                Button(action: { isShowingWateringLog = true }){
                    icon(title: "History", imageName: "archivebox.fill")
                        .padding()
                }
                .disabled(plant.wateringIvents == nil)
                Spacer()
            }
        }
    }
    
    private func waterPlant(){
        let wateringIvent = WateringIvent(context: viewContext)
        wateringIvent.plant = plant
        wateringIvent.date = Date()
        plant.water()
        do{
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func plantSection(title: String, value: String, imageName: String) -> some View{
        HStack{
            icon(title: nil, imageName: imageName)
                .padding(.trailing)
            VStack(alignment: .leading){
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
    }
    
    private var titleSection: some View{
        HStack{
            VStack(alignment: .leading){
                HStack(alignment: .top){
                    Text(plant.genus ?? "")
                        .font(.title)
                        .fontWeight(Font.Weight.semibold)
                    if plant.wikiDescription != nil{
                        Button(action: { isShowingDescription = true }){
                            VStack{
                                Image(systemName: "info.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(Font.system(size: 20))
                            }
                            .opacity(0.7)
                            .padding(.leading, -5)
                            .padding(.top, -5)
                        }
                    }
                }
                if plant.name != nil{
                    Text(plant.name!)
                        .font(.headline)
                        .fontWeight(Font.Weight.semibold)
                        .opacity(0.8)
                }
            }
            Spacer()
        }
    }
        
    private func imageScroll(for images: [UIImage]?, in geometry: GeometryProxy) -> some View{
        VStack{
            if images != nil{
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack{
                        ForEach(images!, id : \.self){ img in
                            VStack{
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                                    .clipped()
                                //scrollPosition(for: img, in: images!)
                            }
                        }
                    }
                })
            } else {
                Image("default")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
            }
        }
    }
    
    private func scrollPosition(for img: UIImage, in images: [UIImage]) -> some View{
        HStack(alignment: .center){
            if images.count > 1 {
                Text(String(images.firstIndex(of: img)! + 1) + " of " + String(images.count))
            }
        }
        .foregroundColor(.secondary)
        .font(.caption)
    }
    
    
    private var backButton: some View{
        Button(action: { presentationMode.wrappedValue.dismiss() }){
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondary)
                    .frame(width: 30, height: 30)
                    .opacity(0.6)
                Image(systemName: "arrow.backward")
                .foregroundColor(.white)
                .font(Font.system(size: 20).bold())
            }
            .padding()
        }
    }
    
    private var deleteButton: some View{
        Button(action: { isShowingAlert = true }){
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondary)
                    .frame(width: 30, height: 30)
                    .opacity(0.6)
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 20).bold())
            }
            .padding()
        }
        .alert("Delete this plant?", isPresented: $isShowingAlert){
            Button("No", role: .cancel, action: {})
            Button("Yes", role: .destructive, action: {
                deletePlant()
            })
        }
    }
    
    private func deletePlant(){
        if plant.getImagesCount(with: fsm) > 0{
            do{
                try plant.prepareForDeletion(context: viewContext, fsm: fsm)
            } catch {
                print(error)
                return
            }
        }
        viewContext.delete(plant)
        do{
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


