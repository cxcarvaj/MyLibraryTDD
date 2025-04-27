//
//  Test.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Foundation
import Testing
@testable import MyLibraryTDD

@Suite("Test of employees")
@MainActor
struct EmployeeTest {
    let network: Network
    let vm: EmployeeVM
    
    init() async {
        // 1. Configuramos la sesión con nuestro mock
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [BetterNetworkMockInterface.self]
        let session = URLSession(configuration: config)
        self.network = Network(session: session)
        self.vm = EmployeeVM(repository: self.network)
        
        // 2. Configuramos las respuestas mock para cada endpoint
        await setupMockResponses()
        
        // 3. Cargamos datos iniciales
        await vm.getEmployees()
    }
    
    /// Configura todas las respuestas mock necesarias para los tests
    private func setupMockResponses() async {
        do {
            // Configurar mock para listado de empleados
            try await setupEmployeeListMock()
            
            // Configurar mock para empleado individual
            try await setupSingleEmployeeMock()
            
            // Configurar mock para actualización de empleado
            try await setupEmployeeUpdateMock()
        } catch {
            print("Error setting up mock responses: \(error)")
        }
    }
    
    /// Configura el mock para el endpoint de listado de empleados
    private func setupEmployeeListMock() async throws {
        // Asumimos que tienes un archivo JSON de prueba con 24 empleados
        let employeesURL = Bundle.module.url(
            forResource: "EmpleadosTesting",
            withExtension: "json"
        )!
        
        // Registramos la respuesta para el endpoint de listado
        // Esto mapeará a tu .getEmployee endpoint
        let endpoint = URL.getEmployee
        try await BetterNetworkMockInterface.registerFile(
            url: endpoint,
            fileURL: employeesURL
        )
    }
    
    /// Configura el mock para el endpoint de empleado individual
    private func setupSingleEmployeeMock() async throws {
        // Crear un empleado de prueba con ID 189
        let testEmployee = EmployeeDTO.test
        
        // Registramos la respuesta para el endpoint de empleado individual
        // Esto mapeará a tu .getEmployeeById(id: 189) endpoint
        let endpoint = URL.getEmployeeById(id: 189)
        try await BetterNetworkMockInterface.register(
            url: endpoint,
            object: testEmployee
        )
    }
    
    /// Configura el mock para el endpoint de actualización de empleado
    private func setupEmployeeUpdateMock() async throws {
        // 1. Mock para PUT
//        let updateEndpoint = URL.employee
//        await BetterNetworkMockInterface.register(
//            url: updateEndpoint,
//            method: "PUT",
//            statusCode: 200,
//            data: nil
//        )
//        
        // 2. Mock para GET posterior con el empleado actualizado
        let employeeId = EmployeeDTO.test.id
        let getEndpoint = URL.getEmployeeById(id: employeeId)
        
        // Empleado con apellido actualizado
        let updatedEmployee = EmployeeDTO(
            id: EmployeeDTO.test.id,
            firstName: EmployeeDTO.test.firstName,
            lastName: "Updated LastName",
            username: EmployeeDTO.test.username,
            email: EmployeeDTO.test.email,
            address: EmployeeDTO.test.address,
            zipcode: EmployeeDTO.test.zipcode,
            avatar: EmployeeDTO.test.avatar,
            department: EmployeeDTO.test.department,
            gender: EmployeeDTO.test.gender
        )
        
        try await BetterNetworkMockInterface.register(
            url: getEndpoint,
            object: updatedEmployee
        )
    }
    
    @Test("NetworkMockInterface test")
    func testNetwork() async throws {
        await #expect(throws: Never.self) {
            try await network.getJSON(.get(.getEmployee), type: [EmployeeDTO].self)
        }
    }
    
    @Test("Fetch employees test using NetworkMockInterface")
    func getEmployeesWithNetworkMockInterface() async throws {
        let employees = try await network.getJSON(.get(.getEmployee), type: [EmployeeDTO].self).map(\.toEmployee)
        
        #expect(employees.count == 24)
    }
    
    @Test("Fetch employee by Id test using NetworkMockInterface")
    func getEmployeeWithNetworkMockInterface() async throws {
        let employee = try await network.getJSON(.get(.getEmployeeById(id: 189)), type: EmployeeDTO.self)
        #expect(employee.id == 189)
    }
    
    @Test("Fetch employees test")
    func getEmployees() async throws {
        let employees = try await network.getEmployees()
        
        #expect(employees.count == 24)
    }
    
    @Test("Fetch employee by Id test")
    func getEmployeeById() async throws {
        let employee = try await network.getEmployee(id: 189)
        #expect(employee.id == 189)
    }
    
    @Test("Get employees test with ViewModel")
    func getEmployeesVM() async throws {
        let newCount = vm.employees.count
        #expect(newCount == 24)
    }
    
    @Test("Get employees by Department test with ViewModel")
    func getEmployeeByDptVM() async throws {
        let dpt = try #require(Department.allCases.randomElement())
        let employeesByDpt = vm.getEmployeeByDpt(dpt: dpt)
        
        #expect(employeesByDpt.count == 2)
    }
    
    @Test("Update employee test with ViewModel")
    func updateEmployeeVM() async throws {
        let employee = try #require(vm.employees.first)
        let updatedEmployee = Employee(id: employee.id,
                                       name: employee.name,
                                       lastName: "Updated LastName",
                                       username: employee.username,
                                       email:
                                        employee.email,
                                       address: employee.address,
                                       postalCode: employee.postalCode,
                                       avatarURL: employee.avatarURL,
                                       department: employee.department,
                                       gender: employee.gender)

        await vm.updateEmployee(updatedEmployee)
        let newUpdatedEmployee = try #require(vm.employees.first { $0.id == employee.id })
        #expect(employee.lastName != newUpdatedEmployee.lastName)
        #expect(employee != newUpdatedEmployee)
    }
}

