//
//  DataRepository.swift
//  ScoresAppUIKit
//
//  Created by Carlos Xavier Carvajal Villegas on 10/3/25.
//

import Foundation

struct Repository: DataRepository {}

protocol DataRepository: JSONLoader, Sendable {
    var url: URL { get }
    var urlDoc: URL { get }
    
    func getScores() throws -> [Score]
    func saveScores(_ scores: [Score]) throws
}

extension DataRepository {
    var url: URL {
        Bundle.main.url(forResource:"scoresdata",
                        withExtension: "json")!
    }
    
    var urlDoc: URL {
        URL.documentsDirectory.appending(path: "scoredata").appendingPathExtension("json")
    }
    
    func getScores() throws -> [Score] {
//        throw NSError(domain: "", code: 0, userInfo: nil)
        if FileManager.default.fileExists(atPath: urlDoc.path()) {
            try load(url: urlDoc, type: [Score].self)
        } else {
            try load(url: url, type: [ScoreDTO].self).map(\.toScore)
        }
    }
    
    func saveScores(_ scores: [Score]) throws {
//        throw NSError(domain: "", code: 0, userInfo: nil)
        try save(url: urlDoc, data: scores)
    }
}
