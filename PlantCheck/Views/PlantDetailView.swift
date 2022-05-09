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
    let plant: Plant
    let fsm: FileSystemManager
    @State var isShowingAlert = false
    
    var body: some View {
        GeometryReader{ geometry in
            ScrollView{
                imageScroll(for: plant.getImages(with: fsm), in: geometry)
                Text(plant.description)
            }
            .ignoresSafeArea(edges: .top)
            .overlay(alignment: .topLeading){
                HStack{
                    backButton
                    Spacer()
                    deleteButton
                }
            }
            .navigationBarHidden(true)
            .background{
                Image("background")
                    .resizable()
                    .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
                    .ignoresSafeArea(edges: .all)
                    .opacity(0.25)
            }
        }
    }
        
    private func imageScroll(for images: [UIImage]?, in geometry: GeometryProxy) -> some View{
        VStack{
            if images != nil{
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack{
                        ForEach(images!, id : \.self){ img in
                            VStack{
                                Image(uiImage: img)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: geometry.size.width, height: geometry.size.height * 0.5)
                                    .clipped()
                                scrollPosition(for: img, in: images!)
                            }
                        }
                    }
                })
            } else {
                Image("default")
                    .resizable()
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.4)
            }
        }
    }
    
    private func scrollPosition(for img: UIImage, in images: [UIImage]) -> some View{
        HStack(alignment: .center){
            if images.count > 1 {
                Text(String(images.firstIndex(of: img)! + 1) + " of " + String(images.count))
            }
        }
        .foregroundColor(.secondary)
        .font(.caption)
    }
    
    private func inScrollImage(for img: UIImage) -> some View{
        Image(uiImage: img)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height *  0.35)
            .clipped()
    }
    
    
    private var backButton: some View{
        Button(action: { presentationMode.wrappedValue.dismiss() }){
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondary)
                    .frame(width: 45, height: 45)
                    .opacity(0.6)
                Image(systemName: "arrow.backward")
                .foregroundColor(.white)
                .font(Font.system(size: 30).bold())
            }
            .padding()
        }
    }
    
    private var deleteButton: some View{
        Button(action: { isShowingAlert = true }){
            ZStack(alignment: .center){
                RoundedRectangle(cornerRadius: 10)
                    .foregroundColor(.secondary)
                    .frame(width: 45, height: 45)
                    .opacity(0.6)
                Image(systemName: "trash.fill")
                    .foregroundColor(.white)
                    .font(.system(size: 30).bold())
            }
            .padding()
        }
        .alert("Delete this plant?", isPresented: $isShowingAlert){
            Button("No", role: .cancel, action: {})
            Button("Yes", role: .destructive, action: {
                deletePlant()
            })
        }
    }
    
    private func deletePlant(){
        if plant.getImagesCount(with: fsm) > 0{
            do{
                try plant.deleteImagesFromStorage(with: fsm)
            } catch {
                print(error)
                return
            }
        }
        viewContext.delete(plant)
        do{
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


