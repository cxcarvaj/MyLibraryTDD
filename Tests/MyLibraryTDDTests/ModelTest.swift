//
//  ModelTest.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Testing
import Foundation
@testable import MyLibraryTDD

@Suite("Business Logic of Scores Test")
struct ModelTestScores {
    
    @Test("DTO to Entity Test")
    func dtoToEntityTest() {
        let scoreDTO = ScoreDTO.test.toScore
        let scoreEntity = Score.test
        
        #expect(scoreDTO.id == scoreEntity.id)
        #expect(scoreDTO.title == scoreEntity.title)
        #expect(scoreDTO.composer == scoreEntity.composer)
        #expect(scoreDTO.year == scoreEntity.year)
        #expect(scoreDTO.length == scoreEntity.length)
        #expect(scoreDTO.cover == scoreEntity.cover)
        #expect(scoreDTO.tracks == scoreEntity.tracks)
        
    }

}
