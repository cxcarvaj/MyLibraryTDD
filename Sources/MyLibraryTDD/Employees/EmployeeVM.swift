//
//  EmployeeVM.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import SwiftUI

@Observable @MainActor
final class EmployeeVM {
    let repository: NetworkDataRepository
    
    var employees: [Employee] = []
    
    var showAlert = false
    var errorMsg = ""
    
    init(repository: NetworkDataRepository = Network()) {
        self.repository = repository
        Task {
            await getEmployees()
        }
    }
    
    func getEmployees() async {
        do {
            employees = try await repository.getEmployees()
        } catch {
            errorMsg = error.localizedDescription
            showAlert.toggle()
            print("Error: \(error)")
        }
    }
    
    func getEmployeeByDpt(dpt: Department) -> [Employee] {
         employees.filter { $0.department == dpt }
     }
    
    func updateEmployee(_ employee: Employee) async {
        do {
            try await repository.updateEmployee(employee: employee)
            if let index = employees.firstIndex(where: { $0.id == employee.id }) {
                employees[index] = try await repository.getEmployee(id: employee.id)
            }
        } catch {
            errorMsg = error.localizedDescription
            showAlert.toggle()
            print("Error: \(error)")
        }
    }
}
