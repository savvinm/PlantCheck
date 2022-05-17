//
//  CoreDataController.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 12.05.2022.
//

import CoreData
import SwiftUI

class CoreDataController{
    var selectedPlant: Plant?
    
    
    func savePlant(context: NSManagedObjectContext, fileSystemManager: FileSystemManager, genus: String, name: String?, wateringInterval: Int, stringWateringInterval: String, location: String?, wikiDescription: String?, wikiCultivation: String?, images: [UIImage]) throws {
        let id = UUID()
        let newPlant = Plant(context: context)
        newPlant.id = id
        newPlant.name = name
        newPlant.genus = genus
        newPlant.wateringInterval = Int16(wateringInterval)
        newPlant.stringWateringInterval = stringWateringInterval
        newPlant.location = location
        newPlant.creationDate = Date()
        newPlant.wikiCultivation = wikiCultivation
        newPlant.wikiDescription = wikiDescription
        if
            !images.isEmpty,
            let paths = fileSystemManager.saveImages(images: images, plantId: id)
        {
            newPlant.imagesPath = paths.joined(separator: "%20")
        }
        do{
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func delete(_ plant: Plant, context: NSManagedObjectContext, fsm: FileSystemManager) throws {
        try plant.prepareForDeletion(context: context, fsm: fsm)
        context.delete(plant)
        do{
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func water(_ plant: Plant, context: NSManagedObjectContext){
        let wateringIvent = WateringIvent(context: context)
        wateringIvent.plant = plant
        wateringIvent.date = Date()
        plant.water()
        do{
            try context.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    func getPlantsForWateringScroll(context: NSManagedObjectContext) -> (toWater: [Plant], watered: [Plant]){
        let request = NSFetchRequest<Plant>(entityName: "Plant")
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Plant.genus, ascending: true), NSSortDescriptor(keyPath: \Plant.name, ascending: true)]
        let plants = (try? context.fetch(request)) ?? []
        var watered = [Plant]()
        var toWater = [Plant]()
        let calendar = Calendar.current
        for plant in plants{
            if let nextWatering = plant.nextWatering{
                if nextWatering < Date() || calendar.isDateInToday(nextWatering){
                    toWater.append(plant)
                }
            } else {
                toWater.append(plant)
            }
            if let lastWatering = plant.lastWatering{
                if calendar.isDateInToday(lastWatering){
                    watered.append(plant)
                }
            }
        }
        return (toWater, watered)
    }
    
}
