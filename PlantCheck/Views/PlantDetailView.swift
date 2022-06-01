//
//  PlantDetailView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 09.05.2022.
//

import SwiftUI

struct PlantDetailView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @ObservedObject var plant: Plant
    let fileSystemManager: FileSystemManager
    let coreDataController: CoreDataController
    let isInSheet: Bool
    
    @State var isShowingAlert = false
    @State var isShowingDescription = false
    @State var isShowingWateringLog = false
    
    var body: some View {
        GeometryReader { geometry in
            ScrollView {
                imageScroll(for: plant.getImages(with: fileSystemManager), in: geometry)
                plantBody(in: geometry)
            }
            .ignoresSafeArea(edges: .top)
            .sheet(isPresented: $isShowingWateringLog, content: { HistoryView(plant: plant) })
            .sheet(isPresented: $isShowingDescription, content: { WikiDescriptionView(plant: plant) })
            .overlay(alignment: .topTrailing) { pageOverlay }
            .navigationBarHidden(true)
            .modifier(ImageBackground(geometry: isInSheet ? geometry : nil))
        }
        .ignoresSafeArea(edges: .bottom)
    }
    
    private func plantBody(in geometry: GeometryProxy) -> some View {
        VStack {
            titleSection
            toolBar.frame(width: geometry.size.width * 0.9, height: geometry.size.height * 0.15)
            if plant.location != nil {
                VStack {
                    infoSection(title: "Location", value: plant.location!, imageName: "location.fill")
                }
                .padding(.top)
            }
            wateringInfo.padding(.bottom, 30)
        }
        .padding(.top, 5)
        .padding(.horizontal)
    }
    
    private func icon(title: String?, imageName: String) -> some View {
        VStack {
            VStack {
                Image(systemName: imageName)
                    .foregroundColor(.secondary)
                    .font(Font.system(size: 30))
            }
            .frame(width: UIScreen.main.bounds.width * 0.12, height: UIScreen.main.bounds.width * 0.12)
            .background(.thickMaterial)
            .cornerRadius(15)
            if title != nil {
                Text(title!)
                .foregroundColor(.secondary)
            }
        }
    }
    
    private var pageOverlay: some View {
        VStack {
            if isInSheet {
                CloseButton(presentationMode: presentationMode, withBackground: true)
            } else {
                HStack {
                    backButton
                    Spacer()
                    deleteButton
                }
            }
        }
    }
    
    private var toolBar: some View {
        HStack(alignment: .center) {
            Button(action: { waterPlant() }, label: {
                icon(title: "Water", imageName: plant.canBeWatered ? "drop" : "drop.fill")
            })
            .padding()
            .disabled(!plant.canBeWatered)
            Button(action: { isShowingWateringLog = true }, label: {
                icon(title: "History", imageName: plant.hasWateringIvents ? "archivebox.fill" : "archivebox")
            })
            .padding()
            .disabled(!plant.hasWateringIvents)
        }
    }
    
    private var wateringInfo: some View {
        VStack {
            infoSection(title: "Watering schedule", value: plant.stringWateringInterval ?? "", imageName: "calendar")
            VStack {
                infoSection(title: "Next watering", value: plant.nextWatering_, imageName: "calendar.badge.clock")
                if !plant.hasWateringIvents {
                    Text("Water your plant to update information")
                        .multilineTextAlignment(.center)
                        .font(.footnote)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.top)
        }
        .padding(.top)
    }
    
    private func waterPlant() {
        if plant.canBeWatered {
            coreDataController.water(plant, context: viewContext)
        }
    }
    
    private func infoSection(title: String, value: String, imageName: String) -> some View {
        HStack {
            icon(title: nil, imageName: imageName)
                .padding(.trailing)
            VStack(alignment: .leading) {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
            }
            Spacer()
        }
    }
    
    private var titleSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading) {
                genusLabel
                if plant.name != nil {
                    Text(plant.name!)
                        .font(.headline)
                        .fontWeight(Font.Weight.semibold)
                        .opacity(0.8)
                }
            }
            Spacer()
        }
    }
    
    private var genusLabel: some View {
        HStack(alignment: .top) {
            Text(plant.genus ?? "")
                .font(.title)
                .fontWeight(Font.Weight.semibold)
            if plant.wikiDescription != nil {
                Button(action: { isShowingDescription = true }, label: {
                    VStack {
                        Image(systemName: "info.circle.fill")
                            .foregroundColor(.secondary)
                            .font(Font.system(size: 20))
                    }
                    .opacity(0.7)
                    .padding(.leading, -5)
                    .padding(.top, -5)
                })
            }
        }
    }
        
    private func imageScroll(for images: [UIImage]?, in geometry: GeometryProxy) -> some View {
        VStack {
            if images != nil {
                ScrollView(.horizontal, showsIndicators: false) {
                    LazyHStack {
                        ForEach(images!, id: \.self) { img in
                            Image(uiImage: img)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                                .clipped()
                        }
                    }
                }
            } else {
                Image("default")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
            }
        }
    }
    
    private var backButton: some View {
        Button(action: { presentationMode.wrappedValue.dismiss() }, label: {
            buttonLabel(imageName: "arrow.backward")
        })
    }
    
    private var deleteButton: some View {
        Button(action: { isShowingAlert = true }, label: {
            buttonLabel(imageName: "trash.fill")
        })
        .alert("Delete this plant?", isPresented: $isShowingAlert) {
            Button("No", role: .cancel, action: {})
            Button("Yes", role: .destructive, action: {
                deletePlant()
            })
        }
    }
    
    private func buttonLabel(imageName: String) -> some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.secondary)
                .frame(width: 35, height: 35)
                .opacity(0.6)
            Image(systemName: imageName)
                .foregroundColor(.white)
                .font(.system(size: 20).bold())
        }
        .padding()
    }
    
    private func deletePlant() {
        do {
            try coreDataController.delete(plant, context: viewContext, fsm: fileSystemManager)
            presentationMode.wrappedValue.dismiss()
        } catch {
            print(error)
        }
    }
}
