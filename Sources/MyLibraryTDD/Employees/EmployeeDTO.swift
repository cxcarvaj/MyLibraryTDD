//
//  EmpleadoDTO.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

struct EmployeeDTO: Codable, Identifiable {
    let id: Int
    let firstName: String
    let lastName: String
    let username: String
    let email: String
    let address: String
    let zipcode: String
    let avatar: String?
    let department: DepartmentDTO
    let gender: GenderDTO
    
    struct DepartmentDTO: Codable {
        let id: Int
        let name: String
    }
    
    struct GenderDTO: Codable {
        let id: Int
        let gender: String
    }
}

extension EmployeeDTO {
    static let test = EmployeeDTO(
        id: 189,
        firstName: "Friedrick",
        lastName: "Hatrick",
        username: "fhatrick58",
        email: "fhatrick58@psu.edu",
        address: "5138 Susan Terrace",
        zipcode: "21051 CEDEX",
        avatar: "https://robohash.org/optioculpaquia.png",
        department: EmployeeDTO.DepartmentDTO(
            id: 8,
            name: "Research and Development"
        ),
        gender: EmployeeDTO.GenderDTO(id: 1, gender: "Male")
    )
}
