//
//  FileSystemManager.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 06.05.2022.
//

import SwiftUI

final class FileSystemManager {
    
    private let baseURLs = FileManager.default.urls(for: .documentDirectory, in: FileManager.SearchPathDomainMask.userDomainMask)
    
    func saveImages(images: [UIImage], plantId: UUID) -> [String]? {
        guard let baseURL = baseURLs.first else {
            print("Error getting file system root")
            return nil
        }
        var paths = [String]()
        for index in 0..<images.count {
            let name = plantId.uuidString + ".\(index).jpg"
            let url = baseURL.appendingPathComponent(name)
            do {
                try saveImageInFS(image: images[index], path: url)
                paths.append(name)
            } catch {
                print(error)
            }
        }
        return paths
    }
    
    private func saveImageInFS(image: UIImage, path: URL) throws {
        guard let data = image.jpegData(compressionQuality: 0.4) else {
            throw FSError.imageCompressingError
        }
        do {
            try data.write(to: path)
        } catch {
            throw FSError.savingError
        }
    }
    
    func readImage(imageName: String) -> UIImage? {
        guard let baseURL = baseURLs.first else {
            print("Error getting file system root")
            return nil
        }
        let url = baseURL.appendingPathComponent(imageName)
        if let data = FileManager.default.contents(atPath: url.path),
           let image = UIImage(data: data) {
            return image
        } else {
            print("Error reading image")
            return nil
        }
    }
    
    func deleteFile(fileName: String) throws {
        guard let baseURL = baseURLs.first else {
            throw FSError.invalidSystemRoot
        }
        let url = baseURL.appendingPathComponent(fileName)
        do {
            try FileManager.default.removeItem(atPath: url.path)
        } catch {
            throw FSError.deletingError
        }
    }
}

enum FSError: Error {
    case invalidSystemRoot
    case readingError
    case savingError
    case deletingError
    case imageCompressingError
}
