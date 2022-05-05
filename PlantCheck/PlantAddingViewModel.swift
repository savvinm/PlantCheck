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
    
    private(set) var wateringIntervals = [1 : "Everyday", 2 : "Every 2 days", 3 : "Every 3 days", 7 : "Every week", 30 : "Every month"]
    var intervals: [Int]{
        wateringIntervals.keys.sorted()
    }
    private var genuses: [String]
    private(set) var options: [String]
    private(set) var thumbnails: [String: URL]
    private(set) var imageURL: URL?
    
    @Published var showingImagePicker = false
    
    var imageCount: Int = 0{
        didSet{
            updateImage()
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
            if genus != oldValue{
                updateImage()
                updateOptions()
                updateFilled()
            }
        }
    }
    @Published var isAllFilled = false
    var name = ""
    var location = ""
    @Published var wateringInterval = 0{
        didSet{
            updateFilled()
        }
    }
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
    
    private func updateImage(){
        imageURL = nil
        if imageCount == 0{
            if checkGenus(){
                api.fetchImagesFromWiki(pageTitles: [genus]) { result in
                    switch result {
                    case .success(let query):
                        guard let page = query.query.pages.first else {
                            return
                        }
                        if self.genus == page.title{
                            if let source = page.original?.source{
                                guard let url = URL(string: source) else {
                                    return
                                }
                                DispatchQueue.main.async {
                                    [ weak self ] in
                                    self?.imageURL = url
                                    self?.objectWillChange.send()
                                }
                            }
                        }
                    case .failure(let error):
                        print(error)
                        return
                    }
                }
            }
        }
    }
    
    private func updateFilled(){
        if checkGenus() && wateringInterval != 0{
            isAllFilled = true
        }
        else{
            isAllFilled = false
        }
    }
    
    private func checkGenus() -> Bool{
        genuses.contains(genus.trimmingCharacters(in: .whitespacesAndNewlines))
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
        api.fetchImagesFromWiki(pageTitles: titles, pithumbsize: 100){ result in
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
    
    private func updateOptions(){
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
        newPlant.id = UUID()
        newPlant.name = name
        newPlant.genus = genus
        newPlant.wateringInterval = Int16(wateringInterval)
        newPlant.location = location
        newPlant.creationDate = Date()
        newPlant.nextWatering = Date() + Double(wateringInterval) * 86400
        do{
            newPlant.imagesData = try NSKeyedArchiver.archivedData(withRootObject: images, requiringSecureCoding: false)
        } catch {
            print("Error archiving images")
            return
        }
        do {
            try viewContext.save()
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }}
