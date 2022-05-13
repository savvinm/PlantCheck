//
//  Shared.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 11.05.2022.
//

import SwiftUI

struct FootnoteView: View{
    let text: String
    var body: some View{
        HStack{
            Text(text)
                .multilineTextAlignment(.leading)
                .font(.footnote)
                .foregroundColor(.secondary)
            Spacer()
        }
    }
}

struct CloseButton: View{
    @State var presentationMode: Binding<PresentationMode>
    
    var body: some View{
        Button(action: {
            presentationMode.wrappedValue.dismiss()
        }, label: {
            Image(systemName: "x.circle.fill")
                .font(.system(size: 25))
                .foregroundColor(.secondary)
                .opacity(0.95)
        })
        .padding()
    }
}

struct ImageBackground: ViewModifier{
    private let width: CGFloat
    private let height: CGFloat
    
    init(geometry: GeometryProxy?){
        if let geometry = geometry{
            width = geometry.size.width
            height = geometry.size.height
            return
        }
        width = UIScreen.main.bounds.width
        height = UIScreen.main.bounds.height
    }
    
    func body(content: Content) -> some View {
        content
            .background{
                Image("background")
                    .resizable()
                    .ignoresSafeArea(.keyboard)
                    .frame(width: width, height: height)
                    .ignoresSafeArea(edges: .all)
                    .opacity(0.25)
            }
    }
}

struct InputStyle: ViewModifier{
    func body(content: Content) -> some View{
        content
            .font(.headline)
            .padding(.leading)
            .frame(maxWidth: .infinity, idealHeight: 50)
            .background(.thickMaterial)
            .cornerRadius(10)
    }
}

struct MenuPicker: View{
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
            } else {
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
