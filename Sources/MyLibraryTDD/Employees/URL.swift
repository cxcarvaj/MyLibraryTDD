//
//  URL.swift
//  EmployeesAPI
//
//  Created by Carlos Xavier Carvajal Villegas on 10/4/25.
//

import Foundation

#if DEBUG
let api = URL(string: "https://acacademy-employees-api.herokuapp.com/api")!
#else
let stag = URL(string: "https://empleados-api.herokuapp.com/api")!
let qa = URL(string: "https://empleados-api.herokuapp.com/api")!
let prod = URL(string: "https://empleados-api.herokuapp.com/api")!

let api = prod

#endif

extension URL {
    static let getEmployee = api.appending(path: "getEmpleados")
    static func getEmployeeById(id: Int) -> URL {
        api.appending(path: "getEmpleado").appending(path: "\(id)")
    }
    static let employee = api.appending(path: "empleado")
}
