//
//  ImagePickerView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 04.05.2022.
//

import SwiftUI

struct ImagePikcerView: View {
    @ObservedObject var vm: PlantAddingController
    
    var body: some View {
        VStack {
            if vm.images.isEmpty {
                if vm.imageURL == nil {
                    defaultImage.padding(.bottom)
                } else {
                    wikiImage.padding(.bottom)
                }
            } else {
                imagesScroll
            }
        }
        .onTapGesture { vm.showingImagePicker.toggle() }
        .sheet(isPresented: $vm.showingImagePicker) { ImagePicker(images: $vm.images, imageCount: $vm.imageCount) }
    }
    
    private var imagesScroll: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(vm.images, id: \.self) { img in
                    VStack {
                        inScrollImage(for: img)
                        scrollPosition(for: img)
                    }
                }
            }
        }
    }
    
    private func scrollPosition(for img: UIImage) -> some View {
        HStack(alignment: .center) {
            if vm.imageCount <= 1 {
                Text("1of1").opacity(0)
            } else {
                Text(String(vm.images.firstIndex(of: img)! + 1) + " of " + String(vm.imageCount))
            }
        }
        .foregroundColor(.secondary)
        .font(.caption)
    }
    
    private func inScrollImage(for img: UIImage) -> some View {
        Image(uiImage: img)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
            .clipped()
            .overlay(alignment: .bottomTrailing) {
                removeButton(for: img).padding([.trailing, .bottom])
            }
    }
    
    private func toolIcon(imageName: String) -> some View {
        ZStack(alignment: .center) {
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .opacity(0.7)
            Image(systemName: imageName)
                .foregroundColor(.secondary)
                .font(.system(size: 25))
                .opacity(0.9)
        }
    }
    
    private var wikiImage: some View {
        AsyncImage(url: vm.imageURL!) { image in
            image
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
        } placeholder: {
            ZStack {
                defaultImage
                ProgressView()
            }
        }
        .overlay(alignment: .bottomTrailing) {
            toolIcon(imageName: "photo").padding([.trailing, .bottom])
        }
    }
    
    private func removeButton(for img: UIImage) -> some View {
        Button(action: {
            withAnimation(.easeInOut) {
                vm.removeImage(img)
            }
        }, label: {
            toolIcon(imageName: "trash.fill")
        })
    }
    
    private var defaultImage: some View {
        Image("default")
            .resizable()
            .frame(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height * 0.35)
            .overlay(alignment: .bottomTrailing) {
                toolIcon(imageName: "photo").padding([.trailing, .bottom])
            }
    }
}
