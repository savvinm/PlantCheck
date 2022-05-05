//
//  ImagePickerView.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 04.05.2022.
//

import SwiftUI

struct ImagePikcerView: View{
    @ObservedObject var vm: PlantAddingViewModel
    
    var body: some View{
        VStack{
            if vm.images.isEmpty{
                VStack{
                    defaultImage
                    Text("1 of 1").opacity(0).font(.footnote)
                }
            }
            else{
                ScrollView(.horizontal, showsIndicators: false, content: {
                    HStack{
                        ForEach(vm.images, id : \.self){ img in
                            VStack{
                                inScrollImage(for: img)
                                scrollPosition(for: img)
                            }
                        }
                    }
                })
            }
        }
        .onTapGesture {
            vm.showingImagePicker.toggle()
        }
        .sheet(isPresented: $vm.showingImagePicker){ ImagePicker(images: $vm.images, imageCount: $vm.imageCount) }
    }
    
    private func scrollPosition(for img: UIImage) -> some View{
        HStack(alignment: .center){
            if vm.imageCount <= 1{
                Text("1of1").opacity(0)
            }
            else{
                Text(String(vm.images.firstIndex(of: img)! + 1) + " of " + String(vm.imageCount))
            }
        }
        .foregroundColor(.secondary)
        .font(.caption)
    }
    
    private func inScrollImage(for img: UIImage) -> some View{
        ZStack{
            Image(uiImage: img)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width, height: 250)
                .clipped()
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    Button(action: {
                        withAnimation(.easeInOut){
                            vm.removeImage(img)
                        }
                    }, label: {
                        deleteIcon
                    })
                    .padding([.trailing, .bottom])
                }
            }
        }
    }
    
    private var galeryIcon: some View{
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .opacity(0.7)
            Image(systemName: "photo")
                .foregroundColor(.secondary)
                .font(.system(size: 25))
                .opacity(0.9)
        }
    }
    
    private var deleteIcon: some View{
        ZStack(alignment: .center){
            RoundedRectangle(cornerRadius: 10)
                .foregroundColor(.white)
                .frame(width: 45, height: 45)
                .opacity(0.7)
            Image(systemName: "trash.fill")
                .foregroundColor(.secondary)
                .font(.system(size: 25))
                .opacity(0.9)
        }
    }
    
    private var defaultImage: some View{
        ZStack{
            Image("default")
                .resizable()
                .frame(width: UIScreen.main.bounds.width, height: 250)
            HStack{
                Spacer()
                VStack{
                    Spacer()
                    galeryIcon
                        .padding([.trailing, .bottom])
                }
            }
        }
    }
}
