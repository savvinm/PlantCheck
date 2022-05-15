//
//  HistoryView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 10.05.2022.
//

import SwiftUI

struct HistoryView: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    let plant: Plant
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView{
                VStack{
                    Text("Watering history")
                        .padding(.bottom, 15)
                        .font(.headline)
                        ForEach(plant._wateringIvents, id: \.self){ ivent in
                            HStack{
                                Text(ivent)
                                    .fontWeight(Font.Weight.medium)
                                    .padding(2)
                                Spacer()
                            }
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 20)
            }
            .overlay(alignment: .topTrailing, content: { CloseButton(presentationMode: presentationMode, withBackground: false) })
            .modifier(ImageBackground(geometry: geometry))
        }
        .ignoresSafeArea(edges: .bottom)
    }
}

