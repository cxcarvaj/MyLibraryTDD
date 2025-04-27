//
//  Repository.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

protocol NetworkDataRepository: Sendable, NetworkInteractor {
    func getEmployees() async throws -> [Employee]
    func getEmployee(id: Int) async throws -> Employee
    func updateEmployee(employee: Employee) async throws
}

struct Network: NetworkDataRepository {
    let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    func getEmployees() async throws -> [Employee] {
        try await getJSON(.get(.getEmployee), type: [EmployeeDTO].self).map(\.toEmployee)
    }
    
    func getEmployee(id: Int) async throws -> Employee {
        try await getJSON(.get(.getEmployeeById(id: id)), type: EmployeeDTO.self).toEmployee
    }
    
    func updateEmployee(employee: Employee) async throws {
        try await getStatus(.post(url: .employee, body: employee.toUpdate, method: .put))
    }
}
