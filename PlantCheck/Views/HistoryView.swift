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
        ScrollView{
            VStack{
                Text("Watering history")
                    .padding()
                    .font(.headline)
                    ForEach(plant._wateringIvents, id: \.self){ ivent in
                        HStack{
                            Text(ivent)
                                .padding(2)
                            Spacer()
                        }
                    }
                }
            }
            .padding()
            .overlay(alignment: .topTrailing, content: { closeButton })
            .background{
                Image("background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
                    .opacity(0.25)
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

