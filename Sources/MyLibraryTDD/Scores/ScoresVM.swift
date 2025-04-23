//
//  ScoresVM.swift
//  ScoreAppSwiftUI
//
//  Created by Carlos Xavier Carvajal Villegas on 25/3/25.
//

import SwiftUI

enum SortedBy: String, CaseIterable, Identifiable {
    case byID = "Order by Default"
    case ascending = "Order by Title ascending"
    case descending = "Order by Title descending"
    
    var id: Self { self }
}

@MainActor
final class ScoresVM: ObservableObject {
    
    private let repository: DataRepository
    
    @Published var scores: [Score] {
        didSet {
            try? repository.saveScores(scores)
        }
    }
    
    @Published var searchText = ""
    @Published var orderBy: SortedBy = .byID
    
    var scoresByComposers: [[Score]] {
        let groupedScores = groupScoresByComposer()
        let sortedScores = sortGroupedScores(groupedScores)
        return filterAndSortScores(sortedScores)
    }
    
    var favoritesCount: Int {
        scores.filter { $0.favorited }.count
    }
    
    var favorites: [Score] {
        scores.filter { $0.favorited }
    }
    
    var scoresByComposerIsEmpty: Bool {
        scoresByComposers.flatMap { $0 }.isEmpty && !searchText.isEmpty
    }
    
    var composers: [String] {
        Set(scores.map(\.composer)).sorted()
    }

    // Agrupa los scores por compositor
    private func groupScoresByComposer() -> [String: [Score]] {
        return Dictionary(grouping: scores, by: \.composer)
    }

    // Ordena los scores agrupados por el nombre del compositor
    private func sortGroupedScores(_ groupedScores: [String: [Score]]) -> [[Score]] {
        return groupedScores.values
            .sorted { ($0.first?.composer ?? "") < ($1.first?.composer ?? "") }
    }

    // Filtra y ordena los scores según la búsqueda y el criterio de orden
    private func filterAndSortScores(_ scores: [[Score]]) -> [[Score]] {
        return scores.map { scoreGroup in
            let filteredScores = filterScores(scoreGroup)
            return sortScores(filteredScores)
        }
    }
    
    // Filtra los scores según la búsqueda
    private func filterScores(_ scores: [Score]) -> [Score] {
        return scores.filter { score in
            if searchText.isEmpty {
                return true
            } else {
                return score.title.range(of: searchText, options: [.caseInsensitive, .diacriticInsensitive, .anchored]) != nil
            }
        }
    }
    
    // Ordena los scores según el criterio establecido
    private func sortScores(_ scores: [Score]) -> [Score] {
        return scores.sorted {
            switch orderBy {
                case .byID:
                    return $0.id < $1.id
                case .ascending:
                    return $0.title < $1.title
                case .descending:
                    return $0.title > $1.title
            }
        }
    }
    
    
    init(repository: DataRepository = Repository()) {
        self.repository = repository
        
        do {
            self.scores = try repository.getScores()
        } catch {
            self.scores = []
            print("error loading scores: \(error)")
        }
    }
    
    func deleteScores(indexSet: IndexSet) {
        scores.remove(atOffsets: indexSet)
    }
    
    func moveScores(from: IndexSet, to: Int) {
        scores.move(fromOffsets: from, toOffset: to)
    }
    
    func deleteScoreRow(score: Score) {
        if let index = scores.firstIndex(of: score) {
            scores.remove(at: index)
        }
    }
    
    func toggleFavorite(score: Score) {
        if let index = scores.firstIndex(of: score) {
            Task { @MainActor [index] in
                try await Task.sleep(for: .seconds(1))
                scores[index].favorited.toggle()
            }
        }
    }
    
    func updateScore(score: Score) {
        if let index = scores.firstIndex(where: { $0.id == score.id }) {
            scores[index] = score
        }
    }
    
    
}
