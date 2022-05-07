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
    
    func parseDescription(from query: WikiPageRevisionModel) -> String{
        if let text = query.query.pages.first?.revisions.first?.slots.main.content{
            if let description = getParagraph(in: text, title: "Description"){
                parseParagraph(clearParagraph(paragraph: description))
            }
        }
        return ""
    }
    
    private func parseParagraph(_ text: String) -> [String: String]?{
        var res = [String: String]()
        let clearText = text.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "\n\n", with: "\n")
        let parts = clearText.components(separatedBy: "\n")
        var title = "body"
        var tmp = ""
        for index in parts.indices{
            if parts[index].first == "=" && parts[index].last == "="{
                if tmp != ""{
                    res[title] = tmp
                    tmp = ""
                }
                title = parts[index].replacingOccurrences(of: "=", with: "").trimmingCharacters(in: .whitespacesAndNewlines)
            }
            else{
                tmp += parts[index] + "\n"
            }
        }
        if tmp != ""{
            res[title] = tmp
        }
        return res
    }
    
    private func getParagraph(in text: String, title: String) -> String?{
        if text.contains(title){
            var res = ""
            let parts = text.components(separatedBy: "==")
            if let startIndex = parts.firstIndex(where: { $0.contains(title) }){
                if startIndex + 1 < parts.count{
                    res += parts[startIndex + 1]
                    for index in startIndex + 2..<parts.count{
                        if parts[index].first == "="{
                            res += parts[index]
                        }
                        else{
                            return res
                        }
                    }
                }
            }
        }
        return nil
        
    }
    
    private func clearParagraph(paragraph: String) -> String{
        var res = paragraph.replacingOccurrences(of: "\'\'", with: "")
        res = res.replacingOccurrences(of: "\"", with: "")
        res = res.replacingOccurrences(of: "\'", with: "")
        res = handleLinks(text: res)
        res = handleHyperLinksAndFiles(text: res)
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
        if parts[2] == "-"{
            return "\(parts[1])-\(parts[3]) \(parts[4])"
        }
        if parts[2] == "to"{
            return "\(parts[1]) to \(parts[3]) \(parts[4])"
        }
        else{
            return "\(parts[1]) \(parts[2])"
        }
    }
    
    private func handleLinks(text: String) -> String{
        let stringArray = Array(text)
        var res = ""
        var openBracetCount = 0
        var closeBracetCount = 0
        var lastSlashIndex: Int?
        for index in stringArray.indices{
            if stringArray[index] == "/"{
                lastSlashIndex = index
            }
            if stringArray[index] == "<"{
                openBracetCount += 1
                if openBracetCount == 1{
                    res += stringArray[0..<index]
                }
            }
            if stringArray[index] == ">"{
                closeBracetCount += 1
                if closeBracetCount == openBracetCount{
                    if let slashIndex = lastSlashIndex{
                        if slashIndex + 4 >= index && index + 1 < stringArray.count{
                            res += handleLinks(text: String(stringArray[index + 1..<stringArray.endIndex]))
                            break
                        }
                    }
                }
            }
        }
        if openBracetCount == closeBracetCount && openBracetCount == 0{
            res += text
        }
        return res
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
        var index = 0
        while index < parts.count{
            // case [[File: .... [[hyperlink]]]]
            if index + 1 < parts.count && parts[index + 1].contains("]]]]"){
                let smallParts = parts[index + 1].components(separatedBy: "]]]]")
                res += smallParts[1]
                res += handleLinkOrFile(text: parts[index] + smallParts[0])
                index += 2
            }
            else{
                let smallParts = parts[index].components(separatedBy: "]]")
                if smallParts.count == 1{
                    res += smallParts.first!
                }
                else{
                    res += handleLinkOrFile(text: smallParts[0])
                    res += smallParts[1]
                }
                index += 1
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
