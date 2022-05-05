//
//  OptionsList.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 04.05.2022.
//

import SwiftUI

struct OptionsList: View{
    @ObservedObject var vm: PlantAddingViewModel
    @FocusState var genusFieldIsFocused: Bool
    
    var body: some View{
        VStack{
            if vm.options.isEmpty{
                emptyMessage
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
    
    private var emptyMessage: some View{
        HStack{
            Image(systemName: "questionmark.circle")
                .font(.headline)
            Text("Nothing found, try something else")
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
