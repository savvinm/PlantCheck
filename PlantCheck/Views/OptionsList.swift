//
//  OptionsList.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 04.05.2022.
//

import SwiftUI

struct OptionsList: View{
    @ObservedObject var vm: PlantAddingController
    @FocusState var genusFieldIsFocused: Bool
    
    var body: some View{
        VStack{
            if vm.options.isEmpty{
                emptyMessage
            } else {
                ForEach(vm.options, id: \.self){ option in
                    optionView(for: option)
                }
            }
        }
    }
    
    private func optionView(for option: String) -> some View{
        Button(action: {
            withAnimation(.easeInOut){
                genusFieldIsFocused = false
                vm.genusIsFocused = false
                vm.genus = option
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
    
    private var emptyMessage: some View{
        HStack{
            Image(systemName: "questionmark.circle")
                .font(.headline)
            Text("Nothing found, try something else")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding([.leading, .bottom])
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
            } else {
                Image("default")
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}
