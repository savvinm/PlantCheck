//
//  WikiThumbnailModel.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import Foundation

struct WikiThumbnailModel: Codable{
    let batchcomplete: Bool
    let query: WikiQuery
    
    struct WikiQuery: Codable{
        let pages: [WikiPage]
    }
    
    struct WikiPage: Codable{
        let pageid: Int
        let title: String
        let thumbnail: WikiThumbnail?
    }
    struct WikiThumbnail: Codable{
        let source: String
    }
}
