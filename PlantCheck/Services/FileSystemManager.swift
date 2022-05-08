//
//  FileSystemManager.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 06.05.2022.
//

import SwiftUI

final class FileSystemManager{
    
    private let baseURLs = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    func saveImages(images: [UIImage], plantId: UUID) -> [String]?{
        guard let baseURL = baseURLs.first else {
            print("Error getting file system root")
            return nil
        }
        var paths = [String]()
        for index in 0..<images.count{
            let name = plantId.uuidString + ".\(index).jpg"
            let url = baseURL.appendingPathComponent(name)
            if !saveImageInFS(image: images[index], path: url){
                print("Error saving image number \(index)")
            } else {
                paths.append(name)
            }
        }
        return paths
    }
    
    private func saveImageInFS(image: UIImage, path: URL) -> Bool{
        guard let data = image.jpegData(compressionQuality: 0.4) else {
            return false
        }
        do{
            try data.write(to: path)
            return true
        } catch{
            print("Error saving image to file system")
            return false
        }
    }
    
    func readImage(imageName: String) -> UIImage?{
        guard let baseURL = baseURLs.first else {
            print("Error getting file system root")
            return nil
        }
        let url = baseURL.appendingPathComponent(imageName)
        if let data = FileManager.default.contents(atPath: url.path),
           let image = UIImage(data: data){
            return image
        } else {
            print("Error reading image")
            return nil
        }
    }
}
