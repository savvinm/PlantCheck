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
                    if
                        let pair = plant.getDescriptionPair(),
                        let titles = pair.titles,
                        let dictionary = pair.dictionary
                    {
                        VStack{
                            Text("Plant description from Wikipedia")
                                .font(.headline)
                                .padding()
                            VStack(alignment: .leading){
                                if titles.contains("body"){
                                    Text(dictionary["body"]!)
                                        .font(.callout)
                                }
                                ForEach(titles, id: \.self){ title in
                                    if title != "body"{
                                        Text(title)
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
            .overlay(alignment: .topTrailing, content: { closeButton })
            .background{
                Image("background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
                    .opacity(0.25)
            }
        }
    }
    
    private var closeButton: some View{
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

