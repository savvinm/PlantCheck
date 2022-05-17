//
//  WikiPageRevisionModel.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import Foundation

struct WikiPageRevisionModel: Codable{
    
    let batchcomplete: Bool
    let query: WikiQuery
    
    struct WikiQuery: Codable{
        let pages: [WikiPage]
    }
    
    struct WikiPage: Codable{
        let pageid: Int
        let title: String
        let revisions: [WikiRevision]
    }
    struct WikiRevision: Codable{
        let slots: WikiSlot
    }
    
    struct WikiSlot: Codable{
        let main: WikiMain
    }
    
    struct WikiMain: Codable{
        let content: String
    }
}
