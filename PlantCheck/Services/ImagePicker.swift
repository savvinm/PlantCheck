//
//  ImagePicker.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 01.05.2022.
//

import PhotosUI
import SwiftUI

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var images: [UIImage]
    @Binding var imageCount: Int
    

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration(photoLibrary: .shared())
        config.filter = .images
        config.selection = .ordered
        config.selectionLimit = 4
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {

    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            guard !results.isEmpty else {
                return
            }
            parent.imageCount = results.count
            parent.images = []
            for result in results{
                guard result.itemProvider.canLoadObject(ofClass: UIImage.self) else {
                    print("Error getting image from picker")
                    continue
                }
                result.itemProvider.loadObject(ofClass: UIImage.self) { image, error in
                    guard let image = image else{
                        print(error!)
                        return
                    }
                    self.parent.images.append(image as! UIImage)
                }
            }
        }
    }
}
