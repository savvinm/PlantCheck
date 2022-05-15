//
//  Plant.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 05.05.2022.
//


import CoreData
import SwiftUI

extension Plant{
    enum PlantError: Error{
        case imagesDeletingError
    }
    
    var _wateringIvents: [String]{
        guard let ivents = wateringIvents as? Set<WateringIvent> else {
            return []
        }
        var dates = [Date]()
        for ivent in ivents{
            dates.append(ivent.date!)
        }
        var res = [String]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMMM yyyy, HH:mm:ss"
        for date in dates.sorted(){
            res.append(dateFormatter.string(from: date))
        }
        return res.reversed()
    }
    
    var _nextWatering: String{
        guard let nextWatering = nextWatering else {
            return ""
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(nextWatering){
            return "Today"
        }
        if calendar.isDateInTomorrow(nextWatering){
            return "Tommorow"
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d"
        return dateFormatter.string(from: nextWatering)
    }
    
    /*var isWateringDateToday: Bool{
        guard let nextWatering = nextWatering else {
            return true
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(nextWatering){
            return true
        }
        return false
    }*/
    
    var hasWateringIvents: Bool{
        if let ivents = wateringIvents as? Set<WateringIvent>{
            if ivents.count > 0{
                return true
            }
        }
        return false
    }
    
    var canBeWatered: Bool{
        guard let lastWatering = lastWatering else {
            return true
        }
        let calendar = Calendar.current
        if calendar.isDateInToday(lastWatering){
            return false
        }
        return true
    }
    
    func water(){
        lastWatering = Date()
        nextWatering = Date() + Double(wateringInterval) * 86400
        objectWillChange.send()
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
    
    func prepareForDeletion(context: NSManagedObjectContext, fsm: FileSystemManager) throws {
        deleteWateringIvents(context: context)
        try deleteImagesFromStorage(with: fsm)
    }
    
    private func deleteWateringIvents(context: NSManagedObjectContext){
        if let ivents = wateringIvents as? Set<WateringIvent>{
            for ivent in ivents{
                context.delete(ivent)
            }
        }
    }
    
    private func deleteImagesFromStorage(with fsm: FileSystemManager) throws {
        guard let paths = imagesPath?.components(separatedBy: "%20") else {
            return
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
            imagesPath = newPaths.joined(separator: "%20")
            throw PlantError.imagesDeletingError
        }
    }
    
    func getCultivationPair() -> (dictionary: [String: String], titles: [String])?{
        guard let cultivation = wikiCultivation else {
            return nil
        }
        return parseParagraph(cultivation)
    }
    
    private func parseParagraph(_ text: String) -> ([String: String], [String]){
        var titles = [String]()
        var res = [String: String]()
        let clearText = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n\n\n\n", with: "\n\n")
        let parts = clearText.components(separatedBy: "\n")
        var title = "body"
        var tmp = ""
        for index in parts.indices{
            if parts[index].first == "=" && parts[index].last == "="{
                if tmp != "" && tmp != "\n"{
                    res[title] = tmp.trimmingCharacters(in: .whitespacesAndNewlines)
                    titles.append(title)
                    tmp = ""
                }
                title = parts[index].replacingOccurrences(of: "=", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            } else {
                tmp += parts[index] + "\n"
            }
        }
        if tmp != "" && tmp != "\n"{
            res[title] = tmp.trimmingCharacters(in: .whitespacesAndNewlines)
            titles.append(title)
        }
        return (res, titles)
    }
}

