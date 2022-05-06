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
    
    func parseDescription(from query: WikiPageRevisionModel) -> [String: String]{
        let parts = query.query.pages.first!.revisions.first!.slots.main.content.components(separatedBy: "==")
        var trimmed = [String]()
        for part in parts{
            trimmed.append(part.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        var descriptionParts = [String: String]()
        if let index = trimmed.firstIndex(of: "Description and biology"){
            descriptionParts["Description"] = clearParagraph(paragraph: trimmed[index + 1])
        }
        if let index = trimmed.firstIndex(of: "Description"){
            descriptionParts["Description"] = clearParagraph(paragraph: trimmed[index + 1])
        }
        if let index = trimmed.firstIndex(of: "Cultivation"){
           // descriptionParts["Cultivation"] = trimmed[index + 1]
        }
        print(descriptionParts)
        return descriptionParts
    }
    
    private func clearParagraph(paragraph: String) -> String{
        var res = paragraph.replacingOccurrences(of: "\'\'", with: "")
        res = res.replacingOccurrences(of: "\"", with: "")
        res = handleHyperLinksAndFiles(text: res)
        res = handleLinks(text: res)
        res = handleConvertions(text: res)
        return res
    }
    
    private func handleConvertions(text: String) -> String{
        var res = ""
        let parts = text.components(separatedBy: "{{")
        for part in parts{
            let smallParts = part.components(separatedBy: "}}")
            if smallParts.count == 1{
                res += smallParts.first!
            }
            else{
                res += handleConvertion(convertion: smallParts[0])
                res += smallParts[1]
            }
        }
        return res
    }
    
    private func handleConvertion(convertion: String) -> String{
        let parts = convertion.components(separatedBy: "|")
        if parts.count < 3{
            return ""
        }
        var res = ""
        if parts[2] == "-"{
            res += "\(parts[1])-\(parts[3]) \(parts[4])"
        }
        else{
            res += "\(parts[1]) \(parts[2])"
        }
        return res
    }
    
    private func handleLinks(text: String) -> String{
        let arrayString = Array(text)
        if arrayString.firstIndex(of: "<") == nil{
            return text
        }
        var res = ""
        let startIndex = arrayString.firstIndex(of: "<")!
        res += arrayString[0..<startIndex]
        if let endIndex = arrayString.firstIndex(of: ">"){
            if arrayString[startIndex...endIndex].contains("/"){
                if endIndex + 1 < arrayString.count{
                    res += handleLinks(text: String(arrayString[endIndex + 1..<arrayString.count]))
                }
            }
            else{
                if let endIndex = nextIndexOf(element: ">", in: arrayString, startIndex: endIndex){
                    if endIndex + 1 < arrayString.count{
                        res += handleLinks(text: String(arrayString[endIndex + 1..<arrayString.count]))
                    }
                }
                
                
            }
        }
        return res
    }
    private func nextIndexOf(element: Character, in array: [Character], startIndex: Int) -> Int?{
        if startIndex < array.count{
            for index in startIndex + 1..<array.count{
                if array[index] == element{
                    return index
                }
            }
        }
        return nil
    }
    
    private func handleLinkOrFile(text: String) -> String{
        if text.contains("File:") || text.contains("Image:"){
            return ""
        }
        else{
            let parts = text.components(separatedBy: "|")
            if parts.count == 2{
                return parts[1]
            }
            else{
                return parts.first!
            }
        }
    }
    
    
    private func handleHyperLinksAndFiles(text: String) -> String{
        var res = ""
        let parts = text.components(separatedBy: "[[")
        for part in parts{
            let smallParts = part.components(separatedBy: "]]")
            if smallParts.count == 1{
                res += smallParts.first!
            }
            else{
                res += handleLinkOrFile(text: smallParts[0])
                res += smallParts[1]
            }
        }
        return res
    }
    
    
    private func parsePlant(from plantString: String) -> String?{
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
