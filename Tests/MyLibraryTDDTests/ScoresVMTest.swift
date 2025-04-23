//
//  ScoresVMTest.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Foundation
import Testing
@testable import MyLibraryTDD

struct MockScoresVM: SuiteTrait, TestScoping {
    @TaskLocal static var mockScoresVM: ScoresVM!
    
    func provideScope(for test: Test, testCase: Test.Case?, performing function: () async throws -> Void) async throws {
        let scoresVM = await ScoresVM(repository: RepositoryTest())
        
        //Con esto inyectamos al @TaskLocal mockScoresVM la instancia de scoresVM
        //Los tests solamente se podrán ejecutar al cabo de la inicialización del VM y cuando esté inyectado.
        try await Self.$mockScoresVM.withValue(scoresVM) {
            try await function()
        }
        if FileManager.default.fileExists(atPath: RemoveFilesTrait.urlDoc.path()) {
            try FileManager.default.removeItem(at: RemoveFilesTrait.urlDoc)
        }
    }
}

extension Trait where Self == MockScoresVM {
    static var mockScoresVM: Self { Self() }
}

@Suite("ViewModel of Scores Tests", .mockScoresVM)

@MainActor
struct ScoresVMTest {
    let scoresVM = MockScoresVM.mockScoresVM!
    
    @Test("Creation of the VM")
    func creationVMTest() {
        #expect(scoresVM.scores.count > 0)
        #expect(scoresVM.scores.count == 12)
    }
    
    @Test("Get composers from the VM")
    func getComposersTest() {
        #expect(scoresVM.composers.count > 0)
        #expect(scoresVM.composers.count == 6)
    }
    
    @Test("Get favorites scores from the VM")
    func getFavoritesScoresTest() {
        scoresVM.scores[0].favorited.toggle()
        #expect(scoresVM.favorites.count > 0)
        #expect(scoresVM.favorites.count == 1)
        #expect(scoresVM.favoritesCount > 0)
        #expect(scoresVM.favoritesCount == 1)
    }
    
    @Test("Toogle favorite score")
    func toggleFavoriteScoreTest() async throws {
        let score = scoresVM.scores[0]
        scoresVM.toggleFavorite(score: score)
        
        try await Task.sleep(for: .seconds(1.5))
        
        #expect(scoresVM.favorites.count > 0)
        #expect(scoresVM.favorites.count == 1)
        #expect(scoresVM.favoritesCount > 0)
        #expect(scoresVM.favoritesCount == 1)
        
        let favScore = scoresVM.scores[0]
        #expect(scoresVM.favorites.count > 0)
        #expect(score.favorited != favScore.favorited)
    }
}
