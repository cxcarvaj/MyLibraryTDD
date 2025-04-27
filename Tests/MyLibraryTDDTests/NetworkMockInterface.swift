//
//  NetworkMockInterface.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Foundation

@testable import MyLibraryTDD

final class NetworkMockInterface: URLProtocol {

    var employeesTestFile: URL {
        Bundle.module.url(
            forResource: "EmpleadosTesting",
            withExtension: "json"
        )!
    }

    var employeeTestFile: URL {
        URL.cachesDirectory.appendingPathComponent("empleadoTest.json")
    }

    override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest
    {
        request
    }

    //    override func startLoading() {
    //        guard let url = request.url,
    //              let data = try? Data(contentsOf: testFile),
    //              let response = HTTPURLResponse(url: url,
    //                                             statusCode: 200,
    //                                             httpVersion: nil,
    //                                             headerFields: ["Content-Type": "application/json; charset=utf-8"]) else {
    //            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
    //            return
    //        }
    //        client?.urlProtocol(self, didLoad: data)
    //        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    //        client?.urlProtocolDidFinishLoading(self)
    //
    //    }

    // Si tuviese que probar varios endpoints deberia hacer lo siguiente (o similar):
    var testEmployee = EmployeeDTO.test

    override func startLoading() {
        guard let url = request.url,
            let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: [
                    "Content-Type": "application/json; charset=utf-8"
                ]
            )
        else {
            client?.urlProtocol(
                self,
                didFailWithError: URLError(.badServerResponse)
            )
            return
        }
        if url.lastPathComponent == "getEmpleados" {
            guard let data = try? Data(contentsOf: employeesTestFile) else {
                client?.urlProtocol(
                    self,
                    didFailWithError: URLError(.badServerResponse)
                )
                return
            }
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }
        if url.deletingLastPathComponent().lastPathComponent == "getEmpleado" {
            if let employeeDTO = loadEmployeeDTOTest() {
                guard let jsonData = try? JSONEncoder().encode(employeeDTO) else {
                    client?.urlProtocol(
                        self,
                        didFailWithError: URLError(.badServerResponse)
                    )
                    return
                }
                client?.urlProtocol(self, didLoad: jsonData)
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )
                try? FileManager.default.removeItem(at: employeeTestFile)
            } else {
                guard let jsonData = try? JSONEncoder().encode(testEmployee)
                else {
                    client?.urlProtocol(
                        self,
                        didFailWithError: URLError(.badServerResponse)
                    )
                    return
                }
                client?.urlProtocol(self, didLoad: jsonData)
                client?.urlProtocol(
                    self,
                    didReceive: response,
                    cacheStoragePolicy: .notAllowed
                )
            }
        }
        if url.lastPathComponent == "empleado" && request.httpMethod == "PUT" {
            let bodyData: Data?

            if let httpBody = request.httpBody {
                bodyData = httpBody
            } else if let stream = request.httpBodyStream,
                let contentLengthString = request.allHTTPHeaderFields?[
                    "Content-Length"
                ],
                let contentLength = Int(contentLengthString)
            {
                bodyData = readBodyStream(stream, bufferSize: contentLength)
            } else {
                bodyData = nil
            }

            guard let body = bodyData,
                let employeeUpdated = try? JSONDecoder().decode(
                    EmployeeUpdated.self,
                    from: body
                ),
                let lastName = employeeUpdated.lastName
            else {
                client?.urlProtocol(
                    self,
                    didFailWithError: URLError(.badServerResponse)
                )
                return
            }
            let updatedEmployeeData = EmployeeDTO(
                id: testEmployee.id,
                firstName: testEmployee.firstName,
                lastName: lastName,
                username: testEmployee.username,
                email: testEmployee.email,
                address: testEmployee.address,
                zipcode: testEmployee.zipcode,
                avatar: testEmployee.avatar,
                department: testEmployee.department,
                gender: testEmployee.gender
            )
            saveEmployeeTest(updatedEmployeeData)
            client?.urlProtocol(
                self,
                didReceive: response,
                cacheStoragePolicy: .notAllowed
            )
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    private func loadEmployeeDTOTest() -> EmployeeDTO? {
        guard let data = try? Data(contentsOf: employeeTestFile),
            let employee = try? JSONDecoder().decode(
                EmployeeDTO.self,
                from: data
            )
        else {
            return nil
        }
        return employee
    }

    private func saveEmployeeTest(_ employee: EmployeeDTO) {
        if let data = try? JSONEncoder().encode(employee) {
            try? data.write(to: employeeTestFile)
        }
    }

    func readBodyStream(_ inputStream: InputStream, bufferSize: Int) -> Data? {
        inputStream.open()
        defer { inputStream.close() }

        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var data = Data()

        while inputStream.hasBytesAvailable {
            let read = inputStream.read(&buffer, maxLength: bufferSize)
            if read > 0 {
                data.append(buffer, count: read)
            } else {
                break
            }
        }

        return data
    }
}
