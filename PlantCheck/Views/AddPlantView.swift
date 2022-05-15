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
    @State var isShowingAllert = false
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView(showsIndicators: false){
                ImagePikcerView(vm: vm)
                VStack{
                    genusSelector
                    nameAndLocationFields
                    wateringInformation
                    saveButton
                }
                .padding(.horizontal)
                .padding(.bottom, 50)
                .padding(.top)
                .onTapGesture {
                    genusFieldIsFocused = false
                }
            }
            .modifier(ImageBackground(geometry: geometry))
            .overlay(alignment: .topTrailing){ pageOverlay }
        }
        .ignoresSafeArea(.container, edges: .bottom)
    }
    
    private var pageOverlay: some View{
        VStack{
            if isShowingAllert{
                noConnectionAllert
                    .transition(AnyTransition.opacity.animation(.easeIn(duration: 0.5)))
            } else {
                if isSaving{
                    savingOverlay
                }
                else {
                    CloseButton(presentationMode: presentationMode)
                }
            }
        }
    }
    
    private var noConnectionAllert: some View{
        GeometryReader{ geometry in
            ZStack(alignment: .center){
                Rectangle()
                    .background(.thickMaterial)
                    .opacity(0)
                VStack{
                    Image(systemName: "wifi.slash")
                        .padding(.bottom)
                        .font(Font.system(size: 40))
                    Text("No Internet Connection")
                        .font(.headline)
                        .padding(.bottom, 1)
                    Text("Check your connection or try again")
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color(red: 0.81, green: 1, blue: 0.78))
                .frame(width: geometry.size.width * 0.55, height: geometry.size.height * 0.25)
                .padding(20)
                .background(Color(.systemGray))
                .cornerRadius(15)
                .opacity(0.95)
            }
        }
    }
    
    private func showAllert(){
        isShowingAllert = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            isShowingAllert = false
        }
    }
    
    private var savingOverlay: some View{
        ZStack(alignment: .center){
            Rectangle()
                .background(.thickMaterial)
                .opacity(0.6)
            VStack{
                Spacer()
                ProgressView()
                    .scaleEffect(1.2)
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 0.81, green: 1, blue: 0.78)))
                    .padding()
                Text("Saving new plant")
                    .foregroundColor(Color(red: 0.81, green: 1, blue: 0.78))
                Spacer()
            }
            .font(.headline)
        }
    }
    
    
    private var saveButton: some View{
        Button(action: {
            isSaving = true
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(100)){
                do{
                    try vm.savePlant(viewContext: viewContext)
                    presentationMode.wrappedValue.dismiss()
                } catch {
                    print(error)
                    showAllert()
                    isSaving = false
                }
            }
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
            FootnoteView(text: "Select a suitable watering interval for your plant. You will see which plants need to be watered on the main screen")
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
                FootnoteView(text: "You can name your new plant to distinguish it from other plants of the same kind")
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
                FootnoteView(text: "Write where your new plant lives, for example, by the window in the kitchen")
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
                            vm.genusIsFocused = isBegin
                        }
                    })
                    .disableAutocorrection(true)
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
