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
    @State var isSaving = false
    
    var body: some View {
        ScrollView{
            ImagePikcerView(vm: vm)
                .frame(maxWidth: UIScreen.main.bounds.width)
            VStack{
                genusSelector
                nameAndLocationFields
                wateringInformation
                saveButton
            }
            .frame(width: UIScreen.main.bounds.width * 0.9)
            .padding(.bottom, 50)
            .padding(.top)
            .onTapGesture {
                genusFieldIsFocused = false
            }
        }
        .overlay(content: { toolsOverlay })
        .background(content: {
            Image("background")
                .resizable()
                .scaledToFill()
                .opacity(0.25)
                .ignoresSafeArea(edges: .bottom)
        })
    }
    
    private var toolsOverlay: some View{
        VStack{
            if isSaving{
                ZStack(alignment: .center){
                    Rectangle()
                        .background(.thickMaterial)
                        .opacity(0.6)
                    ProgressView()
                }
            }
            else{
                HStack{
                    Spacer()
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }, label: {
                        Image(systemName: "x.circle.fill")
                            .font(.system(size: 25))
                            .foregroundColor(.secondary)
                            .opacity(0.95)
                    })
                }
                Spacer()
            }
        }
        .padding()
    }
    
    
    private var saveButton: some View{
        Button(action: {
            isSaving = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                vm.addPlant(viewContext: viewContext, isPresented: presentationMode)
            }
            //vm.addPlant(viewContext: viewContext, isPresented: presentationMode)
            //self.presentationMode.wrappedValue.dismiss()
        }, label: {
            HStack{
                Text("Save")
                    .foregroundColor(.primary)
                    .opacity(0.7)
                    .font(.headline)
            }
            .frame(width: UIScreen.main.bounds.width * 0.7, height: 50)
            .background(vm.isAllFilled ? Color(red: 0.81, green: 1, blue: 0.78) : Color(.systemGray6))
            .cornerRadius(10)
            .opacity(vm.isAllFilled ? 0.95 : 0.6)
        }).disabled(!vm.isAllFilled)
    }
    
    private var wateringInformation: some View{
        VStack(alignment: .leading){
            Text("Watering schedual").font(.headline)
            MenuPicker(selection: vm.wateringInterval, vm: vm)
            footnoteView(for: "Select a suitable watering interval for your plant. You will see which plants need to be watered on the main screen")
        }
        .padding(.bottom)
    }
    private func footnoteView(for text: String) -> some View{
        HStack{
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
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
                footnoteView(for: "You can name your new plant to distinguish it from other plants of the same kind")
            }
            VStack{
                TextField("Location (optional)", text: $vm.location)
                    .modifier(InputStyle())
                    .overlay(alignment: .trailing){
                    if vm.location != ""{
                        Button(action: { vm.location = "" }, label: {
                            clearButtonIcon
                            })
                        }
                    }
                footnoteView(for: "Write where your new plant lives, for example, by the window in the kitchen")
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
                    .frame(height: 50)
                    .overlay(alignment: .trailing){
                    if vm.genus != ""{
                        Button(action: { vm.genus = "" }, label: {
                            clearButtonIcon
                            })
                        }
                    }
                }
                .padding(.leading)
                .font(.headline)
                
                if vm.genusIsFocused && vm.genus != ""{
                    OptionsList(vm: vm, genusFieldIsFocused: _genusFieldIsFocused)
                }
            }
            .background(.thickMaterial)
            .cornerRadius(10)
        }
    }
}


private struct MenuPicker: View{
    @State var selection: Int
    @ObservedObject var vm: PlantAddingViewModel
    var body: some View{
        VStack{
            Menu{
                pickerBody
            } label: {
                pickerLabel
            }
        }
    }
    
    private var pickerBody: some View{
        Picker("Intervals", selection: $selection) {
            ForEach(vm.intervals, id: \.self) { id in
                Text(vm.wateringIntervals[id]!).tag(id)
            }
        }
        .onChange(of: selection){
            vm.wateringInterval = $0
        }
        .pickerStyle(InlinePickerStyle())
    }
    
    private var pickerLabel: some View{
        HStack{
            if vm.wateringInterval == 0{
                Text("Select")
            }
            else{
                Text(vm.wateringIntervals[selection]!)
            }
        }
        .frame(maxWidth: .infinity, minHeight: 50, maxHeight: 50)
        .foregroundColor(vm.wateringInterval == 0 ? .secondary : .primary)
        .font(.headline)
        .background(.thickMaterial)
        .cornerRadius(10)
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
