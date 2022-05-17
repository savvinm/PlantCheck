//
//  PlantAddingController.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import CoreData
import SwiftUI

class PlantAddingController: ObservableObject{
    
    private(set) var wateringIntervals = [1 : "Everyday", 2 : "Every 2 days", 3 : "Every 3 days", 7 : "Every week", 14: "Every two weeks", 30 : "Every month"]
    var intervals: [Int]{
        wateringIntervals.keys.sorted().reversed()
    }
    private var genuses: [String]{
        didSet{
            fetchThumbnails(withLimit: 45, for: genuses)
        }
    }

    private(set) var options: [String]
    private(set) var thumbnails: [String: URL]
    private(set) var imageURL: URL?
    
    @Published var showingImagePicker = false
    
    @Published var imageCount: Int = 0
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
    @Published var name = ""
    @Published var location = ""
    @Published var wateringInterval = 0{
        didSet{
            updateFilled()
        }
    }
    @Published var genusIsFocused = false

    private let api: APIService
    private let wikiParser: WikiParser
    private let fileSystemManager: FileSystemManager
    private let coreDataController: CoreDataController
    
    init(){
        genuses = []
        options = []
        thumbnails = [:]
        wikiParser = WikiParser()
        api = APIService()
        fileSystemManager = FileSystemManager()
        coreDataController = CoreDataController()
        start()
    }
    
    private func start(){
        api.fetchPageFromWiki(pageTitle: "Houseplant"){ [weak self] result in
            guard let self = self else {
                return
            }
            switch result {
            case .success(let query):
                self.genuses = self.wikiParser.parseListOfPlants(from: query)
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
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    private func updateWikiImage(){
        imageURL = nil
        guard imageCount == 0 && checkGenus() else {
            return
        }
        api.fetchImagesFromWiki(pageTitles: [genus], pithumbsize: 1000) { [weak self] result in
            guard let self = self else {
                return
            }
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
                DispatchQueue.main.async { [weak self] in
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
    
    private func updateFilled(){
        isAllFilled = (checkGenus() && wateringInterval != 0)
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
            fetchThumbnails(withLimit: limit, for: Array(titles.suffix(titles.count - limit)))
        }
        api.fetchImagesFromWiki(pageTitles: Array(titles.prefix(limit)) , pithumbsize: 100){ [weak self] result in
            switch result{
            case .success(let query):
                for item in query.query.pages{
                    guard
                        let source = item.thumbnail?.source,
                        let url = URL(string: source)
                    else {
                        print("Wrong URL format")
                        continue
                    }
                    self?.thumbnails[item.title] = url
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
        }
    }
    
    func savePlant(viewContext: NSManagedObjectContext) throws {
        var wikiDescription: String?
        var wikiCultivation: String?
        
        let group = DispatchGroup()
        group.enter()
        api.fetchPageFromWiki(pageTitle: genus){ [weak self] result in
            guard let self = self else {
                return
            }
            switch result{
            case.success(let query):
                wikiDescription = self.wikiParser.parseDescription(from: query)
                wikiCultivation = self.wikiParser.parseBlock(from: query, title: "Cultivation")
                group.leave()
            case.failure(let error):
                print(error)
            }
        }
        var timeoutResult = group.wait(timeout: .now() + 2)
        if timeoutResult == .timedOut{
            throw SavingError.wikiDescriptionTimeout
        }
        
        if imageCount == 0 && imageURL != nil{
            group.enter()
            api.downloadImage(from: imageURL!){ [weak self] result in
                guard let self = self else {
                    return
                }
                switch result{
                case.success(let image):
                    self.images.append(image)
                    group.leave()
                case.failure(let error):
                    print(error)
                }
            }
        }
        
        timeoutResult = group.wait(timeout: .now() + 2)
        switch timeoutResult{
        case.success:
            try coreDataController.savePlant(
                context: viewContext,
                fileSystemManager: fileSystemManager,
                genus: genus,
                name: name == "" ? nil : name,
                wateringInterval: wateringInterval,
                stringWateringInterval: wateringIntervals[wateringInterval]!,
                location: location == "" ? nil : location,
                wikiDescription: wikiDescription,
                wikiCultivation: wikiCultivation,
                images: images
            )
        case.timedOut:
            throw SavingError.fetchingImageTmeout
        }
    }
}

enum SavingError: Error{
    case fetchingImageTmeout
    case wikiDescriptionTimeout
}
