//
//  BetterNetworkMockInterface.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 23/4/25.
//

import Foundation
@testable import MyLibraryTDD

// MARK: - Tipos de soporte compartidos (ahora en ámbito global)
/// Descriptor de solicitud para identificar endpoints
struct RequestDescriptor: Hashable, Sendable {
    let url: URL
    let method: String
    
    func matches(request: URLRequest) -> Bool {
        guard let requestMethod = request.httpMethod,
              let requestUrl = request.url else {
            return false
        }
        
        // Basic matching (could be enhanced with pattern matching)
        if method == requestMethod {
            // Match by path components
            if requestUrl.path.contains(url.path) {
                return true
            }
        }
        
        return false
    }
}

/// Respuesta simulada para pruebas
struct MockResponse: Sendable {
    let statusCode: Int
    let data: Data?
    let headers: [String: String]?
}

// Actor para gestionar el estado compartido de las respuestas mock
actor MockResponseStore {
    /// Mapping of request descriptors to mock responses
    private(set) var responses: [RequestDescriptor: MockResponse] = [:]
    
    /// Default mock response if no specific configuration is found
    private(set) var defaultResponse: MockResponse?
    
    /// Reset all configurations
    func reset() {
        responses = [:]
        defaultResponse = nil
    }
    
    /// Register a mock response for a specific endpoint
    func register(descriptor: RequestDescriptor, response: MockResponse) {
        responses[descriptor] = response
    }
    
    /// Get response for request
    func response(for request: URLRequest) -> MockResponse? {
        guard let url = request.url, let method = request.httpMethod else {
            return defaultResponse
        }
        
        let descriptor = RequestDescriptor(url: url, method: method)
        
        // Try exact match
        if let response = responses[descriptor] {
            return response
        }
        
        // Try pattern match
        if let matchingDescriptor = responses.keys.first(where: { $0.matches(request: request) }) {
            return responses[matchingDescriptor]
        }
        
        return defaultResponse
    }
    
    /// Set default response
    func setDefaultResponse(_ response: MockResponse) {
        defaultResponse = response
    }
}

/// A Sendable URLProtocol for testing network requests with Swift 6 concurrency
final class BetterNetworkMockInterface: URLProtocol, @unchecked Sendable {
    
    // MARK: - Shared Store
    
    /// Shared store for mock responses
    private static let store = MockResponseStore()
    
    // MARK: - Configuration
    
    /// Reset all configurations
    static func resetMocks() async {
        await store.reset()
    }
    
    /// Register a mock response for a specific endpoint
    static func register(url: URL, method: String = "GET", statusCode: Int = 200,
                         data: Data?, headers: [String: String]? = nil) async {
        let descriptor = RequestDescriptor(url: url, method: method)
        let response = MockResponse(statusCode: statusCode, data: data, headers: headers)
        await store.register(descriptor: descriptor, response: response)
    }
    
    /// Set default mock response
    static func setDefaultResponse(statusCode: Int = 200, data: Data? = nil,
                                  headers: [String: String]? = nil) async {
        let response = MockResponse(statusCode: statusCode, data: data, headers: headers)
        await store.setDefaultResponse(response)
    }
    
    // MARK: - Instance properties
    
    // These are instance-specific and don't need to be shared
    private let serialQueue = DispatchQueue(label: "com.networkmock.serialqueue")
    
    // Use local URLs for test files
    var employeesTestFile: URL {
        Bundle.module.url(
            forResource: "EmpleadosTesting",
            withExtension: "json"
        )!
    }

    var employeeTestFile: URL {
        URL.cachesDirectory.appendingPathComponent("empleadoTest.json")
    }
    
    // MARK: - URLProtocol Implementation
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        serialQueue.async { [weak self] in
            guard let self = self else { return }
            
            Task {
                guard let url = self.request.url else {
                    self.sendError(.badURL)
                    return
                }
                
                // Get mock response from store
                if let mockResponse = await Self.store.response(for: self.request) {
                    self.sendMockResponse(url: url, mockResponse: mockResponse)
                    return
                }
                
                // Handle specific endpoints (your existing logic)
                if url.lastPathComponent == "getEmpleados" {
                    self.handleGetEmployees()
                } else if url.deletingLastPathComponent().lastPathComponent == "getEmpleado" {
                    self.handleGetEmployee()
                } else if url.lastPathComponent == "empleado" && self.request.httpMethod == "PUT" {
                    self.handleUpdateEmployee()
                } else {
                    // Default error if no handler found
                    self.sendError(.badServerResponse)
                }
            }
        }
    }
    
    override func stopLoading() {
        // No resources to clean up
    }
    
    // MARK: - Request Handlers
    
    private func handleGetEmployees() {
        do {
            let data = try Data(contentsOf: employeesTestFile)
            sendSuccessResponse(with: data)
        } catch {
            sendError(.cannotLoadFromNetwork)
        }
    }
    
    private func handleGetEmployee() {
        if let employeeDTO = loadEmployeeDTOTest() {
            do {
                let jsonData = try JSONEncoder().encode(employeeDTO)
                sendSuccessResponse(with: jsonData)
                try? FileManager.default.removeItem(at: employeeTestFile)
            } catch {
                sendError(.cannotParseResponse)
            }
        } else {
            let testEmployee = EmployeeDTO.test
            do {
                let jsonData = try JSONEncoder().encode(testEmployee)
                sendSuccessResponse(with: jsonData)
            } catch {
                sendError(.cannotParseResponse)
            }
        }
    }
    
    private func handleUpdateEmployee() {
        let bodyData = extractRequestBody()
        
        guard let body = bodyData,
              let employeeUpdated = try? JSONDecoder().decode(
                EmployeeUpdated.self,
                from: body
              ),
              let lastName = employeeUpdated.lastName
        else {
            sendError(.badServerResponse)
            return
        }

        let testEmployee = EmployeeDTO.test
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
        sendSuccessResponse(with: nil)
    }
    
    // MARK: - Helper Methods
    
    private func sendSuccessResponse(with data: Data?) {
        guard let url = request.url,
              let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json; charset=utf-8"]
              ) else {
            sendError(.badServerResponse)
            return
        }
        
        if let data = data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func sendMockResponse(url: URL, mockResponse: MockResponse) {
        let headers = mockResponse.headers ?? ["Content-Type": "application/json; charset=utf-8"]
        
        guard let response = HTTPURLResponse(
            url: url,
            statusCode: mockResponse.statusCode,
            httpVersion: nil,
            headerFields: headers
        ) else {
            sendError(.badServerResponse)
            return
        }
        
        if let data = mockResponse.data {
            client?.urlProtocol(self, didLoad: data)
        }
        
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }
    
    private func sendError(_ code: URLError.Code) {
        client?.urlProtocol(self, didFailWithError: URLError(code))
    }
    
    private func extractRequestBody() -> Data? {
        if let httpBody = request.httpBody {
            return httpBody
        } else if let stream = request.httpBodyStream,
                  let contentLengthString = request.allHTTPHeaderFields?["Content-Length"],
                  let contentLength = Int(contentLengthString) {
            return readBodyStream(stream, bufferSize: contentLength)
        }
        return nil
    }
    
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

// MARK: - Setup/Teardown Methods
extension BetterNetworkMockInterface {
    /// Basic example of how to install the mock for testing
    static func setupForTesting() {
        URLProtocol.registerClass(BetterNetworkMockInterface.self)
    }
    
    /// Remove the mock when done testing
    static func tearDown() async {
        URLProtocol.unregisterClass(BetterNetworkMockInterface.self)
        await resetMocks()
    }
}

// MARK: - Convenience Methods for Registration
extension BetterNetworkMockInterface {
    /// Register a mock JSON response
    static func registerJSON(url: URL, method: String = "GET", statusCode: Int = 200,
                            json: Any) async throws {
        let data = try JSONSerialization.data(withJSONObject: json)
        await register(url: url, method: method, statusCode: statusCode, data: data)
    }
    
    /// Register a mock file response
    static func registerFile(url: URL, method: String = "GET", statusCode: Int = 200,
                            fileURL: URL) async throws {
        let data = try Data(contentsOf: fileURL)
        await register(url: url, method: method, statusCode: statusCode, data: data)
    }
    
    /// Register a codable object as response
    static func register<T: Encodable & Sendable>(url: URL, method: String = "GET",
                                           statusCode: Int = 200,
                                           object: T) async throws {
        let data = try JSONEncoder().encode(object)
        await register(url: url, method: method, statusCode: statusCode, data: data)
    }
}

// MARK: - Implementación básica didáctica
extension BetterNetworkMockInterface {
    /**
     Implementación básica para fines didácticos.
     
     Esta implementación muestra la forma más simple de crear un mock de URLProtocol
     que sirve un archivo de prueba para todas las solicitudes. Es útil para entender
     los conceptos básicos antes de avanzar a implementaciones más sofisticadas.
     
     Ejemplo de uso:
     ```
     let mockURL = Bundle.module.url(forResource: "MockData", withExtension: "json")!
     BetterNetworkMockInterface.setupBasicMock(withFile: mockURL)
     ```
     */
    static func setupBasicMock(withFile testFile: URL) {
        // Se registra la clase como interceptor
        URLProtocol.registerClass(BetterNetworkMockInterface.self)
        
        // Se configura una respuesta predeterminada basada en el archivo
        Task {
            do {
                let data = try Data(contentsOf: testFile)
                await setDefaultResponse(
                    statusCode: 200,
                    data: data,
                    headers: ["Content-Type": "application/json; charset=utf-8"]
                )
            } catch {
                print("Error loading test file: \(error)")
            }
        }
    }
    
    /**
     Implementación básica original para fines didácticos.
     Esta versión es similar a la que estaba comentada en el código original.
     
     Este método es equivalente al método `startLoading()` comentado en tu
     implementación original y sirve como referencia didáctica.
     */
    func basicStartLoadingImplementation() {
        // Esta es la implementación más simple posible
        guard let url = request.url,
              let data = try? Data(contentsOf: employeesTestFile),
              let response = HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json; charset=utf-8"]
              ) else {
            client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
            return
        }
        
        client?.urlProtocol(self, didLoad: data)
        client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        client?.urlProtocolDidFinishLoading(self)
    }
}
