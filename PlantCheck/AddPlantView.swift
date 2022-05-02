//
//  AddPlantView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 01.05.2022.
//

import SwiftUI

struct AddPlantView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    @State private var showingImagePicker = false
    @State private var images: [UIImage] = []
    @State private var genus = ""
    @State private var name = ""
    @State private var location = ""
    @State private var wateringInterval = 1
    
    
    var body: some View {
            ScrollView{
                ZStack{
                    if images.isEmpty{
                        ZStack{
                            Image("defaultPlant")
                                .resizable()
                                .frame(width: UIScreen.main.bounds.width, height: 300)
                            HStack{
                                Spacer()
                                VStack{
                                    Spacer()
                                    Image(systemName: "photo")
                                        .foregroundColor(Color(.systemGray3))
                                        .font(.system(size: 30))
                                        .padding([.trailing, .bottom])
                                }
                            }
                        }
                    }
                    if !images.isEmpty{
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            HStack(spacing: 15){
                                ForEach(images, id : \.self){ img in
                                    ZStack{
                                        Image(uiImage: img)
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: UIScreen.main.bounds.width, height: 300)
                                            .clipped()
                                        HStack{
                                            Spacer()
                                            VStack{
                                                Spacer()
                                                Button(action: {
                                                    images.remove(at: images.firstIndex(of: img)!)
                                                }, label: {
                                                    Image(systemName: "trash.fill")
                                                        .foregroundColor(.red)
                                                        .font(.system(size: 30))
                                                })
                                                .padding([.trailing, .bottom])
                                            }
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
                .padding(.top, -30)
                .onTapGesture {
                    showingImagePicker.toggle()
                }
                .sheet(isPresented: $showingImagePicker){ ImagePicker(images: $images)}
                
                Section(header: Text("Genus and name of your plant")){
                    TextField("Select plant's genus", text: $genus )
                    TextField("Your name for new plant", text: $name)
                }
                
                Section(header: Text("Location and watering interval")){
                    TextField("Location of new plant", text: $location)
                    Picker(selection: $wateringInterval, label: Text("Watering interval")){
                        Text("Everyday").tag(1)
                        Text("Every 2 days").tag(2)
                    }
                }
            }
            .toolbar{
                saveButton
            }
    }
    
    private var saveButton: some View{
        Button(action: {
            addPlant()
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        })
    }
    
    private func addPlant(){
        let newPlant = Plant(context: viewContext)
        newPlant.name = name
        newPlant.genus = genus
        newPlant.wateringInterval = Int16(wateringInterval)
        newPlant.location = location
        newPlant.creationDate = Date()
        newPlant.nextWatering = Date() + Double(wateringInterval) * 86400
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

struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantView()
    }
}
