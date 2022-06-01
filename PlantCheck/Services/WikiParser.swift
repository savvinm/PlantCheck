//
//  WikiParser.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import Foundation

final class WikiParser {
    
    func parseListOfPlants(from query: WikiPageRevisionModel) -> [String] {
        var parts = query.query.pages.first!.revisions.first!.slots.main.content.components(separatedBy: "==List of common houseplants==")
        guard let tail = parts.last else {
            print("Wrong page format: expected 'List of common houseplants'")
            return []
        }
        parts = tail.components(separatedBy: "==Notable specimens==")
        guard let body = parts.first else {
            print("Wrong page format: expected 'Notable specimes'")
            return []
        }
        parts = body.components(separatedBy: "\n")
        var plants =  [String]()
        for part in parts {
            if let plant = parsePlant(from: part) {
                    plants.append(plant.trimmingCharacters(in: .whitespacesAndNewlines))
                }
            }
        return plants
    }
    
    func parseBlock(from query: WikiPageRevisionModel, title: String) -> String? {
        if let text = query.query.pages.first?.revisions.first?.slots.main.content {
            if let description = getParagraph(in: text, title: title) {
                return clearParagraph(paragraph: description)
            }
        }
        return nil
    }
    
    func parseDescription(from query: WikiPageRevisionModel) -> String? {
        guard
            let text = query.query.pages.first?.revisions.first?.slots.main.content,
            let title = query.query.pages.first?.title
        else {
            return nil
        }
        var parts = text.components(separatedBy: "'''\(title)")
        guard parts.count > 1 else {
            return nil
        }
        parts.remove(at: 0)
        var tmp = title
        tmp += removeFirstTranscription(text: parts.joined(separator: ""))
        parts = tmp.components(separatedBy: "==")
        guard let description = parts.first else {
            return nil
        }
        let res = clearParagraph(paragraph: description)
        return res.replacingOccurrences(of: "\n\n\n", with: "\n\n")
        
    }
    
    private func getParagraph(in text: String, title: String) -> String? {
        guard text.contains(title) else {
            return nil
        }
        let parts1 = text.components(separatedBy: "== \(title)")
        let parts2 = text.components(separatedBy: "==\(title)")
        guard parts1.count == 2 || parts2.count == 2 else {
            return nil
        }
        var parts = parts1.count == 2 ? parts1 : parts2
        var res = ""
        parts = parts[1].components(separatedBy: "==")
        if parts.count > 1 {
            res += parts[1]
            for index in 2..<parts.count {
                if parts[index].first == "="{
                    res += parts[index]
                } else {
                    return res
                }
            }
        }
        return nil
    }
    
    private func clearParagraph(paragraph: String) -> String {
        var res = paragraph.replacingOccurrences(of: "\'\'", with: "")
        res = res.replacingOccurrences(of: "\"", with: "")
        res = res.replacingOccurrences(of: "\'", with: "")
        res = res.replacingOccurrences(of: "&nbsp;", with: " ")
        res = handleLinks(text: res)
        res = handleHyperLinksAndFiles(text: res)
        res = handleConvertions(text: res)
        return res
    }
    
    private func removeFirstTranscription(text: String) -> String {
        let stringArray = Array(text)
        guard
            let startIndex = stringArray.firstIndex(of: "("),
            startIndex < 7,
            let endIndex = stringArray.firstIndex(of: ")")
        else {
            return text
        }
        var res = ""
        res += String(stringArray[0..<startIndex])
        res += String(stringArray[endIndex + 1..<stringArray.endIndex])
        return res
    }
    
    private func handleConvertions(text: String) -> String {
        var res = ""
        let parts = text.components(separatedBy: "{{")
        for part in parts {
            let smallParts = part.components(separatedBy: "}}")
            if smallParts.count == 1 {
                res += smallParts.first!
            } else {
                res += handleConvertion(convertion: smallParts[0])
                res += smallParts[1]
            }
        }
        return res
    }
    
    private func handleConvertion(convertion: String) -> String {
        let parts = convertion.components(separatedBy: "|")
        if parts.count < 3 {
            return ""
        }
        if parts.first?.lowercased() != "convert"{
            return ""
        }
        if parts[2] == "-"{
            return "\(parts[1])-\(parts[3]) \(parts[4])"
        }
        if parts[2] == "to"{
            return "\(parts[1]) to \(parts[3]) \(parts[4])"
        }
        return "\(parts[1]) \(parts[2])"
    }
    
    private func handleLinks(text: String) -> String {
        let stringArray = Array(text)
        var res = ""
        var openBracetCount = 0
        var closeBracetCount = 0
        var lastSlashIndex: Int?
        for index in stringArray.indices {
            if stringArray[index] == "/"{
                lastSlashIndex = index
            }
            if stringArray[index] == "<"{
                openBracetCount += 1
                if openBracetCount == 1 {
                    res += stringArray[0..<index]
                }
            }
            if stringArray[index] == ">"{
                closeBracetCount += 1
                if
                    closeBracetCount == openBracetCount,
                    let slashIndex = lastSlashIndex,
                    slashIndex + 4 >= index && index + 1 < stringArray.count
                {
                    res += handleLinks(text: String(stringArray[index + 1..<stringArray.endIndex]))
                    break
                }
            }
        }
        if openBracetCount == closeBracetCount && openBracetCount == 0 {
            res += text
        }
        return res
    }
    
    private func handleLinkOrFile(text: String) -> String {
        guard
            !text.contains("File:"),
            !text.contains("Image:")
        else {
            return ""
        }
        let tmp = text.replacingOccurrences(of: "[", with: "").replacingOccurrences(of: "]", with: "")
        let parts = tmp.components(separatedBy: "|")
        if parts.count == 2 {
            return parts[1]
        } else {
            return parts.first!
        }
    }
    
    private func handleHyperLinksAndFiles(text: String) -> String {
        let stringArray = Array(text)
        var res = ""
        var openBracetCount = 0
        var closeBracetCount = 0
        var openIndex = 0
        var closeIndex = 0
        for index in stringArray.indices {
            if stringArray[index] == "["{
                openBracetCount += 1
                if openBracetCount == 1 {
                    openIndex = index
                    res += stringArray[0..<index]
                }
            }
            if stringArray[index] == "]"{
                closeBracetCount += 1
                if closeBracetCount == openBracetCount {
                    closeIndex = index
                    res += handleLinkOrFile(text: String(stringArray[openIndex...closeIndex]))
                    if index + 1 < stringArray.endIndex {
                        res += handleHyperLinksAndFiles(text: String(stringArray[index + 1..<stringArray.endIndex]))
                        break
                    }
                }
            }
        }
        if openBracetCount == closeBracetCount && openBracetCount == 0 {
            res += text
        }
        return res
    }
    
    private func parsePlant(from plantString: String) -> String? {
        if plantString.starts(with: "*") && !plantString.starts(with: "**") {
            if let plant = plantString.slice(from: "[[", to: "]]") {
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
