//
//  Plant.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 05.05.2022.
//


import CoreData
import Foundation
import SwiftUI

extension Plant{
    enum PlantError: Error{
        case imagesDeletingError
    }
    
    func getImages(with fsm: FileSystemManager) -> [UIImage]?{
        guard let paths = imagesPath?.components(separatedBy: "%20") else {
            return nil
        }
        var images = [UIImage]()
        for path in paths {
            if let image = fsm.readImage(imageName: path){
                images.append(image)
            }
        }
        return images
    }
    
    func getThumbnail(with fsm: FileSystemManager) -> UIImage?{
        if let paths = imagesPath?.components(separatedBy: "%20"){
            return fsm.readImage(imageName: paths.first!)
        }
        return nil
    }
    
    func getImagesCount(with fsm: FileSystemManager) -> Int{
        if let paths = imagesPath?.components(separatedBy: "%20"){
            return paths.count
        }
        return 0
    }
    
    func deleteImagesFromStorage(with fsm: FileSystemManager) throws {
        guard let paths = imagesPath?.components(separatedBy: "%20") else {
            throw PlantError.imagesDeletingError
        }
        var newPaths = [String]()
        for path in paths {
            do{
                try fsm.deleteFile(fileName: path)
            } catch {
                print(error)
                newPaths.append(path)
            }
        }
        if !newPaths.isEmpty{
            self.imagesPath = newPaths.joined(separator: "%20")
            throw PlantError.imagesDeletingError
        }
    }
}

