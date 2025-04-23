//
//  JSONLoader.swift
//  ScoresAppUIKit
//
//  Created by Carlos Xavier Carvajal Villegas on 10/3/25.
//

import Foundation

protocol JSONLoader {}

extension JSONLoader {
    func load<T>(url: URL, type: T.Type) throws -> T where T: Codable {
//        throw NSError(domain: "", code: 0, userInfo: nil)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode(type, from: data)
    }
    
    func save<T>(url: URL, data: T) throws where T: Codable {
//        throw NSError(domain: "", code: 0, userInfo: nil)
        let jsonData = try JSONEncoder().encode(data)
        try jsonData.write(to: url, options: [.atomic, .completeFileProtection])
    }
}
