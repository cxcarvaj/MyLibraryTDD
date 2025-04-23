//
//  Model.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Foundation

struct Score: Codable, Identifiable ,Hashable {
    let id: Int
    let title: String
    let composer: String
    let year: Int
    let length: Double
    let cover: String
    let tracks: [String]
    var favorited: Bool
}

struct ScoreDTO: Codable {
    let id: Int
    let title: String
    let composer: String
    let year: Int
    let length: Double
    let cover: String
    let tracks: [String]
    
    var toScore: Score {
        Score(id: id,
              title: title,
              composer: composer,
              year: year,
              length: length,
              cover: cover,
              tracks: tracks,
              favorited: false)
    }
}
