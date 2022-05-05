//
//  PlantAddingViewModel.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import CoreData
import Foundation
import SwiftUI

class PlantAddingViewModel: ObservableObject{
    
    private var genuses: [String]
    private(set) var options: [String]
    private(set) var thumbnails: [String: URL]
    
    @Published var showingImagePicker = false
    
    var imageCount: Int = 0{
        didSet{
            DispatchQueue.main.async {
                [ weak self ] in
                self?.objectWillChange.send()
            }
        }
    }
    
    var images: [UIImage] = []{
        didSet{
            DispatchQueue.main.async {
                [ weak self ] in
                self?.objectWillChange.send()
            }
        }
    }
    var genus = "" {
        didSet{
            updateOptions()
        }
    }
    
    @Published var name = ""
    @Published var location = ""
    var wateringInterval = 1
    @Published var genusIsFocused = false

    private let api: APIService
    private let parser: WikiParser
    
    init(){
        genuses = []
        options = []
        thumbnails = [:]
        parser = WikiParser()
        api = APIService()
        api.fetchPageFromWiki(pageTitle: "Houseplant"){ result in
            switch result {
            case .success(let query):
                self.genuses = self.parser.parseListOfPlants(from: query)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    func removeImage(_ image: UIImage){
        if let index = images.firstIndex(of: image){
            images.remove(at: index)
            imageCount -= 1
        }
    }
    
    private func fetchThumbnails(withLimit limit: Int, for titles: [String]){
        if titles.count > limit{
            fetchThumbnails(withLimit: limit, for: Array(titles.suffix(limit)))
            return
        }
        api.fetchThumbnailsFromWiki(pageTitles: titles){ result in
            switch result{
            case .success(let query):
                self.thumbnails = [:]
                for item in query.query.pages{
                    if let source = item.thumbnail?.source{
                        if let url = URL(string: source){
                            self.thumbnails[item.title] = url
                        }
                        else{
                            print("Wrong URL format")
                        }
                    }
                    else{
                        //self.thumbnails[item.title] = URL(string: "none")
                    }
                }
                DispatchQueue.main.async {
                    [ weak self ] in
                    self?.objectWillChange.send()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func updateOptions(){
        objectWillChange.send()
        options = []
        if genus == ""{
            return
        }
        else {
            for option in genuses{
                let clearGenus = genus.trimmingCharacters(in: .whitespacesAndNewlines)
                if option.lowercased().contains(clearGenus.lowercased()){
                    options.append(option)
                }
            }
        }
        if !options.isEmpty{
            options = Array(options.prefix(5))
            fetchThumbnails(withLimit: 50, for: options)
        }
    }
    
    func addPlant(viewContext: NSManagedObjectContext){
        let newPlant = Plant(context: viewContext)
        newPlant.name = name
        newPlant.genus = genus
        newPlant.wateringInterval = Int16(wateringInterval)
        newPlant.location = location
        newPlant.creationDate = Date()
        newPlant.nextWatering = Date() + Double(wateringInterval) * 86400
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }}
