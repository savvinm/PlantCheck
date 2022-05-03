//
//  APIService.swift
//  PlantCheck
//
//  Created by Maksim Savvin on 03.05.2022.
//

import Foundation
class APIService{
    @Published var status: Bool = false
   
    
    func fetchPageFromWiki(pageTitle: String, completion: @escaping (Result<WikiPageRevisionModel,APIError>) -> Void) {
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php?")!
        urlComponents.queryItems = [
        "action": "query",
        "rvprop": "content",
        "formatversion": "2",
        "rvslots": "main",
        "titles": pageTitle,
        "prop": "revisions",
        "format": "json"].map { URLQueryItem(name: $0.key, value: $0.value) }

        URLSession.shared.dataTask(with: urlComponents.url!) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                completion(.failure(.invalidResponseStatus))
                return
            }
            guard
                error == nil
            else {
                completion(.failure(.dataTaskError))
                return
            }
            guard
                let data = data
            else {
                completion(.failure(.corruptData))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            do {
                let decodedData = try decoder.decode(WikiPageRevisionModel.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError))
            }

        }
        .resume()
    }
    
    func fetchThumbnailsFromWiki(pageTitles: [String], completion: @escaping (Result<WikiThumbnailModel,APIError>) -> Void) {
        var titles = ""
        for index in 0..<pageTitles.count{
            titles += pageTitles[index].replacingOccurrences(of: " ", with: "%20")
            if index < pageTitles.count-1{
                titles += "%7C"
            }
        }
        var urlComponents = URLComponents(string: "https://en.wikipedia.org/w/api.php?")!
        urlComponents.queryItems = [
        "action": "query",
        "formatversion": "2",
        "pithumbsize": "100",
        "prop": "pageimages",
        "format": "json"].map { URLQueryItem(name: $0.key, value: $0.value) }
        let urlString = urlComponents.url!.absoluteString + "&titles=" + titles

        guard let url = URL(string: urlString) else{
            completion(.failure(.invalidURL))
            return
        }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200
            else {
                completion(.failure(.invalidResponseStatus))
                return
            }
            guard
                error == nil
            else {
                completion(.failure(.dataTaskError))
                return
            }
            guard
                let data = data
            else {
                completion(.failure(.corruptData))
                return
            }
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            do {
                let decodedData = try decoder.decode(WikiThumbnailModel.self, from: data)
                completion(.success(decodedData))
            } catch {
                completion(.failure(.decodingError))
            }

        }
        .resume()
    }}

enum APIError: Error {
    case invalidURL
    case invalidResponseStatus
    case dataTaskError
    case corruptData
    case decodingError
}
