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

    @FocusState var genusFieldIsFocused: Bool
    @ObservedObject var vm = PlantAddingViewModel()
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .scaledToFill()
                .opacity(0.25)
                .ignoresSafeArea(edges: .bottom)
            ScrollView{
                ImagePikcerView(vm: vm)
                    .frame(maxWidth: UIScreen.main.bounds.width)
                VStack{
                    genusSelector
                    nameAndLocationFields
                    wateringInformation
                }
                .frame(width: UIScreen.main.bounds.width * 0.9)
                .padding(.bottom, 50)
                .onTapGesture {
                    genusFieldIsFocused = false
                }
            }
            //.overlay(content: { toolsOverlay })
        }
    }
    
    private var toolsOverlay: some View{
        VStack{
            HStack{
                Spacer()
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }, label: {
                    Image(systemName: "x.circle.fill")
                        .font(.system(size: 25))
                        .foregroundColor(.secondary)
                        .opacity(0.9)
                })
                .padding(.trailing, 5)
                .padding(.top, 5)
            }
            Spacer()
        }
        .padding()
    }
    
    private var wateringInformation: some View{
        VStack(alignment: .leading){
            Text("Watering information").font(.headline)
            Picker(selection: $vm.wateringInterval, label: Text("Watering interval")){
                    Text("Everyday").tag(1)
                    Text("Every 2 days").tag(2)
            }.modifier(InputStyle())
        }
        .padding(.bottom)
    }
    
    private var nameAndLocationFields: some View{
        VStack(alignment: .leading){
            Text("Custom name and location").font(.headline)
            VStack{
                TextField("Name (optional)", text: $vm.name)
                    .modifier(InputStyle())
                    .overlay(alignment: .trailing){
                    if vm.name != ""{
                        Button(action: { vm.name = "" }, label: {
                            clearButtonIcon
                            })
                        }
                    }
                HStack{
                    Text("You can define a name for your new plant to identify it from plants of the same kind")
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
            }
            VStack{
                TextField("Location", text: $vm.location)
                    .overlay(alignment: .trailing){
                    if vm.location != ""{
                        Button(action: { vm.location = "" }, label: {
                            clearButtonIcon
                            })
                        }
                    }
                    .modifier(InputStyle())
                HStack{
                    Text("Write where your new plant lives, for example, by the window in the kitchen")
                        .multilineTextAlignment(.leading)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    Spacer()
                }
                .padding(.horizontal)
            }
            .padding(.top)
        }
        .padding(.vertical)
    }
    
    
    private var clearButtonIcon: some View{
        Image(systemName: "x.circle.fill")
            .font(.headline)
            .padding()
            .foregroundColor(.secondary)
    }
    
    
    private var genusSelector: some View{
        VStack(alignment: .leading){
            Text("Plant type").font(.headline)
            VStack{
                HStack{
                    Image(systemName: "magnifyingglass")
                        .font(.headline)
                        .padding(.leading)
                        .foregroundColor(.secondary)
                    TextField("Search", text: $vm.genus, onEditingChanged: {
                        (isBegin) in
                        withAnimation(.easeInOut){
                            if isBegin{
                                vm.genusIsFocused = true
                            }
                            else{
                                vm.genusIsFocused = false
                            }
                        }
                    })
                    .focused($genusFieldIsFocused)
                    .font(.headline)
                    .frame(height: 50)
                    .overlay(alignment: .trailing){
                    if vm.genus != ""{
                        Button(action: { vm.genus = "" }, label: {
                            clearButtonIcon
                            })
                        }
                    }
                }
                if vm.genusIsFocused && vm.genus != ""{
                    OptionsList(vm: vm, genusFieldIsFocused: _genusFieldIsFocused)
                }
            }
            .background(.thickMaterial)
            .cornerRadius(10)
        }
    }
    
    
    private var saveButton: some View{
        Button(action: {
            vm.addPlant(viewContext: viewContext)
            self.presentationMode.wrappedValue.dismiss()
        }, label: {
            Text("Save")
        })
    }
}


private struct InputStyle: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.headline)
            .padding(.leading)
            .frame(maxWidth: .infinity, idealHeight: 50)
            .background(.thickMaterial)
            .cornerRadius(10)
    }
}



struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            AddPlantView()
                .previewDevice("iPhone 11")
            AddPlantView()
                .previewDevice("iPhone 8")
        }
    }
}
