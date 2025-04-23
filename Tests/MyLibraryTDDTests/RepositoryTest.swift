//
//  RepositoryTest.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//
import Foundation
@testable import MyLibraryTDD

struct RepositoryTest: DataRepository {
    var url: URL {
        Bundle.module.url(forResource: "scoresdatatest",
                        withExtension: "json")!
    }
    
    var urlDoc: URL {
        URL.documentsDirectory.appending(path: "scoresdatatest").appendingPathExtension("json")
    }
}
