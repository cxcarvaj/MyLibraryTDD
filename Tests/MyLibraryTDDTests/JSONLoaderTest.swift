//
//  JSONLoaderTest.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Testing
import Foundation
@testable import MyLibraryTDD

struct RemoveFilesTrait: SuiteTrait, TestScoping {
    @TaskLocal static var urlDoc = URL.documentsDirectory.appending(path: "scoresdatatest.json")
    
    func provideScope(for test: Test, testCase: Test.Case?, performing function: () async throws -> Void) async throws {
        try await function()
        if FileManager.default.fileExists(atPath: RemoveFilesTrait.urlDoc.path()) {
            try FileManager.default.removeItem(at: RemoveFilesTrait.urlDoc)
        }    }
}

extension Trait where Self == RemoveFilesTrait {
    static var removeFiles: Self { Self() }
}

@Suite("Repository Logic of Scores Test", .removeFiles)
struct RepositoryTestScores {
    
    let testRepository: DataRepository = RepositoryTest()
    
    @Test("Load from a JSON file")
    func loadScoresFromJSONFile() throws {
        // Si el archivo no existe, no pasa del require
        let url = try #require(Bundle.module.url(forResource: "scoresdatatest", withExtension: "json"))
        // Como el never es el tipo de error que implica que no hay error
        // Si esperamos un throws de un Never, es el equivalente a un NoThrows
        // https://developer.apple.com/documentation/testing/migratingfromxctest
        #expect(throws: Never.self) {
            try testRepository.load(url: url, type: [ScoreDTO].self)
        }
        
    }
    
    @Test("Load of scores")
    func loadScoresTest() throws {
        let scores: [Score] = try testRepository.getScores()
        #expect(scores.count == 12)
    }
    
    @Test("Save data to JSON file")
    func saveScoresToJSONFile() throws {
        #expect(throws: Never.self) {
            try testRepository.save(url: RemoveFilesTrait.urlDoc, data: ScoreDTO.test)
        }
        #expect(FileManager.default.fileExists(atPath: RemoveFilesTrait.urlDoc.path()))
    }
    
    @Test("Save of scores")
    func saveScoresTest() throws {
        let scores: [Score] = try testRepository.getScores()
        #expect(throws: Never.self) {
            try testRepository.saveScores(scores)
        }
        #expect(FileManager.default.fileExists(atPath: RemoveFilesTrait.urlDoc.path()))
    }

}
