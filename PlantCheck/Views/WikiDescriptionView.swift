//
//  WikiDescriptionView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 10.05.2022.
//

import SwiftUI

struct WikiDescriptionView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let plant: Plant
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView{
                VStack{
                    Text("Plant description from Wikipedia")
                        .font(.headline)
                        .padding(5)
                    if plant.wikiDescription != nil{
                        VStack(alignment: .leading){
                            Text(plant.wikiDescription!)
                                .font(.callout)
                        }
                    }
                    if
                        let pair = plant.getCultivationPair(),
                        let titles = pair.titles,
                        let dictionary = pair.dictionary
                    {
                        VStack(alignment: .leading){
                            Text("Cultivation")
                                .font(.headline)
                                .padding(.vertical, 5)
                            VStack(alignment: .leading){
                                if titles.contains("body"){
                                    Text(dictionary["body"]!)
                                        .font(.callout)
                                }
                                ForEach(titles, id: \.self){ title in
                                    if title != "body"{
                                        Text("\n\(title)")
                                            .font(.headline)
                                        Text(dictionary[title]!)
                                            .font(.callout)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .overlay(alignment: .topTrailing, content: { CloseButton(presentationMode: presentationMode) })
            .modifier(ImageBackground(geometry: geometry))
        }
    }
}

