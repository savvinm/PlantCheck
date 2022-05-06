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
    /*var images: [UIImage]{
        var images = [UIImage]()
        if let data = imagesData{
        do{
            //images =
            try NSKeyedUnarchiver.unarchivedArrayOfObjects(ofClass: UIImage.self, from: data)!
                //return images
            } catch{
                print("Error reading images")
            }
        }
        return images
    }*/
    func getThumbnail(with fsm: FileSystemManager) -> UIImage?{
        if let paths = imagesPath?.components(separatedBy: "%20"){
            return fsm.readImage(imageName: paths.first!)
        }
        return nil
    }
}

