//
//  WikiParser.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import Foundation

class WikiParser{
    
    func parseListOfPlants(from query: WikiPageRevisionModel) -> [String]{
        var parts = query.query.pages.first!.revisions.first!.slots.main.content.components(separatedBy: "==List of common houseplants==")
        if let tail = parts.last{
            parts = tail.components(separatedBy: "==Notable specimens==")
            if let body = parts.first{
                parts = body.components(separatedBy: "\n")
                var plants =  [String]()
                for part in parts{
                    if let plant = parsePlant(from: part){
                        plants.append(plant)
                    }
                }
                return plants
            }
            else{
                print("Wrong page format: expected 'Notable specimes'")
                return []
            }
        }
        else{
            print("Wrong page format: expected 'List of common houseplants'")
            return []
        }
    }
    
    func parsePlant(from plantString: String) -> String?{
        if plantString.starts(with: "*") && !plantString.starts(with: "**"){
            if let plant = plantString.slice(from: "[[", to: "]]"){
                return plant.components(separatedBy: "(").first?.components(separatedBy: "|").first
            }
        }
        return nil
    }
}

extension String {
     
    func slice(from: String, to: String) -> String? {
        guard let rangeFrom = range(of: from)?.upperBound else {
            return nil
        }
        guard let rangeTo = self[rangeFrom...].range(of: to)?.lowerBound else {
            return nil
        }
        return String(self[rangeFrom..<rangeTo])
    }
     
}
