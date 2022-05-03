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
            ScrollView{
                ZStack{
                    if vm.images.isEmpty{
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
                    else{
                        ScrollView(.horizontal, showsIndicators: false, content: {
                            HStack(spacing: 15){
                                ForEach(vm.images, id : \.self){ img in
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
                                                    vm.removeImage(img)
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
                    vm.showingImagePicker.toggle()
                }
                .sheet(isPresented: $vm.showingImagePicker){ ImagePicker(images: $vm.images) }
                VStack{
                    genusSelector
                    .padding()
                    TextField("Your name for new plant", text: $vm.name)
                    
                    
                    TextField("Location of new plant", text: $vm.location)
                    Picker(selection: $vm.wateringInterval, label: Text("Watering interval")){
                            Text("Everyday").tag(1)
                            Text("Every 2 days").tag(2)
                        }
                }
                //.textFieldStyle(RoundedBorderTextFieldStyle())
            }
            .toolbar{
                saveButton
            }
    }
    
    private var genusSelector: some View{
            VStack(alignment: .leading){
                Text("Plant's genus").padding(.leading)
                VStack{
                    TextField("Start typing", text: $vm.genus, onEditingChanged: {
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
                    .padding(.leading)
                    .font(.headline)
                    .frame(width: UIScreen.main.bounds.width * 0.9, height: 50)

                    if vm.genusIsFocused && vm.genus != ""{
                        optionsList(vm: vm, genusFieldIsFocused: genusFieldIsFocused)
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


private struct optionsList: View{
    @ObservedObject var vm: PlantAddingViewModel
    @State var genusFieldIsFocused: Bool
    var body: some View{
        LazyVStack{
            if vm.options.isEmpty{
                Text("Nothing found")
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding([.leading, .bottom])
            }
            else{
                ForEach(vm.options, id: \.self){ option in
                    Button(action: {
                        withAnimation(.easeInOut){
                            vm.genus = option
                            vm.genusIsFocused = false
                            genusFieldIsFocused = false
                        }
                    }, label: {
                        HStack{
                            thumbnail(for: option)
                                .frame(width: 45, height: 45)
                                .cornerRadius(10)
                            Text(option)
                                .foregroundColor(.primary)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding([.leading, .bottom])
                    })
                }
            }
        }
    }
    
    private func thumbnail(for option: String) -> some View{
        VStack{
            if(vm.thumbnails[option] != nil){
                AsyncImage(url: vm.thumbnails[option]){ image in
                    image
                        .resizable()
                        .scaledToFill()
                } placeholder: {
                    Rectangle().foregroundColor(Color.clear)
                }
            }
            /*else{
                Image("defaultPlant")
                    .resizable()
                    .scaledToFill()
                    .clipped()
            }*/
        }
    }
}


struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantView()
    }
}
