//
//  PlantAddingViewModel.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import CoreData
import SwiftUI

class PlantAddingViewModel: ObservableObject{
    
    private(set) var wateringIntervals = [1 : "Everyday", 2 : "Every 2 days", 3 : "Every 3 days", 7 : "Every week", 30 : "Every month"]
    var intervals: [Int]{
        wateringIntervals.keys.sorted()
    }
    private var genuses: [String]
    private var descriptionIsLoaded = false
    private var imageIsLoaded = false
    private(set) var options: [String]
    private(set) var thumbnails: [String: URL]
    private(set) var imageURL: URL?
    
    @Published var showingImagePicker = false
    
    var imageCount: Int = 0
    var images: [UIImage] = []{
        didSet{
            updateImages()
        }
    }
    var genus = "" {
        didSet{
            if genus != oldValue{
                updateWikiImage()
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
    private let fsm: FileSystemManager
    
    init(){
        genuses = []
        options = []
        thumbnails = [:]
        parser = WikiParser()
        api = APIService()
        fsm = FileSystemManager()
        start()
    }
    
    private func start(){
        api.fetchPageFromWiki(pageTitle: "Houseplant"){ result in
            switch result {
            case .success(let query):
                self.genuses = self.parser.parseListOfPlants(from: query)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    
    private func updateImages(){
        guard imageCount != 0 else {
            updateWikiImage()
            return
        }
        DispatchQueue.main.async { [ weak self ] in
            self?.objectWillChange.send()
        }
    }
    
    private func updateWikiImage(){
        imageURL = nil
        if imageCount == 0 && checkGenus(){
            api.fetchImagesFromWiki(pageTitles: [genus], pithumbsize: 1000) { result in
                switch result {
                case .success(let query):
                    guard
                        let page = query.query.pages.first,
                        self.genus == page.title,
                        let source = page.thumbnail?.source,
                        let url = URL(string: source)
                    else {
                        return
                    }
                    DispatchQueue.main.async { [ weak self ] in
                        guard let self = self else {
                            return
                        }
                        self.imageURL = url
                        self.objectWillChange.send()
                    }
                case .failure(let error):
                    print(error)
                    return
                }
            }
        }
    }
    
    private func updateFilled(){
        if checkGenus() && wateringInterval != 0{
            isAllFilled = true
        } else {
            isAllFilled = false
        }
    }
    
    private func checkGenus() -> Bool{
        genuses.contains(genus.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func removeImage(_ image: UIImage){
        if let index = images.firstIndex(of: image){
            imageCount -= 1
            images.remove(at: index)
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
                    guard
                        let source = item.thumbnail?.source,
                        let url = URL(string: source)
                    else {
                        print("Wrong URL format")
                        continue
                    }
                    self.thumbnails[item.title] = url
                }
                DispatchQueue.main.async { [ weak self ] in
                    guard let self = self else {
                        return
                    }
                    self.objectWillChange.send()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func updateOptions(){
        objectWillChange.send()
        options = []
        guard genus != "" else {
            return
        }
        var highPriority = [String]()
        var lowPriority = [String]()
        var res = [String]()
        for option in genuses{
            let clearGenus = genus.trimmingCharacters(in: .whitespacesAndNewlines)
            if option.lowercased().starts(with: clearGenus.lowercased()){
                highPriority.append(option)
            } else if option.lowercased().contains(clearGenus.lowercased()){
                lowPriority.append(option)
            }
        }
        res = highPriority + lowPriority
        if !res.isEmpty{
            options = Array(res.prefix(5))
            fetchThumbnails(withLimit: 50, for: options)
        }
    }
    
    private func saveContext(_ viewContext: NSManagedObjectContext) -> Bool{
        do {
            try viewContext.save()
            return true
        } catch {
            // Replace this implementation with code to handle the error appropriately.
            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func addPlant(viewContext: NSManagedObjectContext, isPresented: Binding<PresentationMode>){
        let id = UUID()
        let newPlant = Plant(context: viewContext)
        newPlant.id = id
        newPlant.name = name == "" ? nil : name
        newPlant.genus = genus
        newPlant.wateringInterval = Int16(wateringInterval)
        newPlant.location = location == "" ?  nil : location
        newPlant.creationDate = Date()
        newPlant.nextWatering = Date() + Double(wateringInterval) * 86400
        
        
        if imageCount == 0 && imageURL != nil{
            guard let url = imageURL else {
                print("Saving error: empty image URL")
                return
            }
            api.downloadImage(from: url){ result in
                switch result{
                case.success(let image):
                    self.images.append(image)
                    guard let path = self.fsm.saveImages(images: self.images, plantId: id) else {
                        print("Error saving images")
                        return
                    }
                    newPlant.imagesPath = path.joined(separator: "%20")
                    self.imageIsLoaded = true
                    if self.descriptionIsLoaded{
                        if self.saveContext(viewContext){
                            isPresented.wrappedValue.dismiss()
                        }
                    }
                case.failure(let error):
                    print(error)
                }
            }
        } else {
            if
                imageCount > 0,
                let paths = fsm.saveImages(images: images, plantId: id)
            {
                newPlant.imagesPath = paths.joined(separator: "%20")
            }
            imageIsLoaded = true
            if descriptionIsLoaded{
                if saveContext(viewContext){
                    isPresented.wrappedValue.dismiss()
                }
            }
        }
        api.fetchPageFromWiki(pageTitle: genus){ result in
            switch result{
            case.success(let query):
                newPlant.wikiDescription = self.parser.parseDescription(from: query)
                self.descriptionIsLoaded = true
                if self.imageIsLoaded{
                    if self.saveContext(viewContext){
                        isPresented.wrappedValue.dismiss()
                    }
                }
            case.failure(let error):
                print(error)
            }
        }
    }
}
