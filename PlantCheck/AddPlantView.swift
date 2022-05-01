//
//  AddPlantView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 01.05.2022.
//

import SwiftUI

struct AddPlantView: View {
    @State private var genus = ""
    @State private var name = ""
    @State private var location = ""
    @State private var wateringInterval = ""
    
    
    var body: some View {
        Form{
            Section(header: Text("Genus and name of your plant")){
                TextField("Select plant's genus", text: $genus )
                TextField("Your name for new plant", text: $name)
            }
            Section(header: Text("Location and watering interval")){
                TextField("Location of new plant", text: $location)
                Picker(selection: $wateringInterval, label: Text("Watering interval")){
                    Text("Every day").tag("Every day")
                }
            }
        }
    }
}

struct AddPlantView_Previews: PreviewProvider {
    static var previews: some View {
        AddPlantView()
    }
}
