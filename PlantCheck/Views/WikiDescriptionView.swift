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
                        .padding(10)
                    descriptionBlock
                    cultivationBlock
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .overlay(alignment: .topTrailing, content: { CloseButton(presentationMode: presentationMode) })
            .modifier(ImageBackground(geometry: geometry))
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private var descriptionBlock: some View{
        VStack{
            if plant.wikiDescription != nil{
                VStack(alignment: .leading){
                    Text(plant.wikiDescription!)
                        .font(.callout)
                }
            }
        }
    }
    
    private var cultivationBlock: some View{
        VStack{
            if
                let pair = plant.getCultivationPair(),
                let titles = pair.titles,
                let dictionary = pair.dictionary
            {
                VStack(alignment: .leading){
                    Text("Cultivation")
                        .font(.headline)
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
    }
}

