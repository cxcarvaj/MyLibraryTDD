// The Swift Programming Language
// https://docs.swift.org/swift-book

// Paso 1: Se crea la firma de la función y se retorna un valor de un caso que nunca voy a llegar a probar
// Paso 2: Crear el test que pruebe la función, nos dará error. (RED)
// Paso 3: Implementar la funcionalidad de dicha función
// Paso 4: Correr los tests y ver que todo pase (GREEN)
// Paso 5: Refactorizar y mejorar en caso de ser necesario (BLUE)
// Sigue el ciclo
func addsTwoNumbers(_ a: Int, _ b: Int) -> Int {
    a + b
}

// Para que un Test esté en RED, *TODOS* los expects deberían fallar
func addsTwoNumbersPositive(_ a: Int, _ b: Int) -> Int? {
    guard a > 0 && b > 0 else { return nil }
    
    return a + b
}

enum AddErrors: Error {
    case firstNumberShouldBePositive
    case secondNumberShouldBePositive
    case allNumbersShouldBePositive
    case overflow
    case unknown
}

func addsTwoNumbersThrowing(_ a: Int, _ b: Int) throws(AddErrors) -> Int? {
    guard !(a < 0 && b < 0) else { throw .allNumbersShouldBePositive }
    guard a >= 0 else { throw .firstNumberShouldBePositive }
    guard b >= 0 else { throw .secondNumberShouldBePositive }
    guard !a.addingReportingOverflow(b).overflow else { throw .overflow }
    guard !b.addingReportingOverflow(a).overflow else { throw .overflow }
    
    return a + b
}
