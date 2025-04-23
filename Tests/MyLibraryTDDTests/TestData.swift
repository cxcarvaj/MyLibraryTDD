//
//  TestData.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

@testable import MyLibraryTDD
import Foundation

extension Score {
    static let test = Score(id: 1, title: "Star Wars", composer: "John Williams", year: 1977, length: 73, cover: "StarWars", tracks: ["Main Title", "Imperial Attack", "Princess Leia's Theme", "The Desert and the Robot Auction", "Ben's Death and TIE Fighter Attack", "The Little People Work", "Rescue of the Princess", "Inner City", "Cantina Band", "The Land of the Sand People", "Mouse Robot and Blasting Off", "The Return Home", "The Walls Converge", "The Princess Appears", "The Last Battle", "The Throne Room and End Title"], favorited: false)
}

extension ScoreDTO {
    static let test = ScoreDTO(id: 1, title: "Star Wars", composer: "John Williams", year: 1977, length: 73, cover: "StarWars", tracks: ["Main Title", "Imperial Attack", "Princess Leia's Theme", "The Desert and the Robot Auction", "Ben's Death and TIE Fighter Attack", "The Little People Work", "Rescue of the Princess", "Inner City", "Cantina Band", "The Land of the Sand People", "Mouse Robot and Blasting Off", "The Return Home", "The Walls Converge", "The Princess Appears", "The Last Battle", "The Throne Room and End Title"])
}
