//
//  Enums.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

enum Department: Int, CaseIterable, Codable, Identifiable {
    case accounting = 1
    case businessDevelopment = 2
    case engineering = 3
    case humanResources = 4
    case legal = 5
    case marketing = 6
    case productManagement = 7
    case researchAndDevelopment = 8
    case sales = 9
    case services = 10
    case support = 11
    case training = 12
    case unknown
    
    var id: Self { self }

    var description: LocalizedStringResource {
        switch self {
        case .accounting: return "Accounting"
        case .businessDevelopment: return "Business Development"
        case .engineering: return "Engineering"
        case .humanResources: return "Human Resources"
        case .legal: return "Legal"
        case .marketing: return "Marketing"
        case .productManagement: return "Product Management"
        case .researchAndDevelopment: return "Research and Development"
        case .sales: return "Sales"
        case .services: return "Services"
        case .support: return "Support"
        case .training: return "Training"
        case .unknown: return "Unknown"
        }
    }
}

enum Gender: Int, CaseIterable, Codable, Identifiable {
    case male = 1
    case female = 2
    case unknown
    
    var id: Self { self }

    var description: LocalizedStringResource {
        switch self {
        case .male: return "Man"
        case .female: return "Woman"
        case .unknown: return "Unknown"
        }
    }
}
