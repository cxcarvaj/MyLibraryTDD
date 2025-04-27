//
//  Employee.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

struct Employee: Identifiable, Hashable {
    let id: Int
    let name: String
    let lastName: String
    let username: String
    let email: String
    let address: String
    let postalCode: String
    let avatarURL: URL?
    let department: Department
    let gender: Gender

    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}

extension EmployeeDTO {
    var toEmployee: Employee {
        Employee(
            id: id,
            name: firstName,
            lastName: lastName,
            username: username,
            email: email,
            address: address,
            postalCode: zipcode,
            avatarURL: avatar.flatMap { URL(string: $0) },
            department: Department(rawValue: department.id) ?? .unknown,
            gender: Gender(rawValue: gender.id) ?? .unknown
        )
    }
}

extension Employee {
    static let test = Employee(
        id: 1,
        name: "Julio César",
        lastName: "Fernández Muñoz",
        username: "jcfmunoz",
        email: "jcfmunoz@icloud.com",
        address: "Mi Casa",
        postalCode: "Mi CP",
        avatarURL: URL(
            string:
                "https://pbs.twimg.com/profile_images/1017076264644022272/tetffw3o_400x400.jpg"
        ),
        department: .engineering,
        gender: .male
    )
}
