//
//  APIDTO.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

struct EmployeeUpdated: Codable {
    var id: Int
    var username: String?
    var firstName: String?
    var lastName: String?
    var email: String?
    var address: String?
    var avatar: String?
    var zipcode: String?
    var department: String?
    var gender: String?
}

extension Employee {
    var toUpdate: EmployeeUpdated {
        return EmployeeUpdated(id: id,
                               username: username,
                               firstName: name,
                               lastName: lastName,
                               email: email,
                               address: address,
                               avatar: avatarURL?.absoluteString,
                               zipcode: postalCode,
                               department: department.description.key,
                               gender: gender.description.key)
    }
}
