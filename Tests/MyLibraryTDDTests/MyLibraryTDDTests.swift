import Testing
@testable import MyLibraryTDD

@Test func addsTwoNumbersTest() {
    #expect(addsTwoNumbers(5, 3) == 8)
    #expect(addsTwoNumbers(10, 20) == 30, "addsTwoNumbers failed, the result must be 30")
}

// Para que un Test esté en RED, *TODOS* los expects deberían fallar
@Test func addsTwoNumbersPositiveTest() {
    #expect(addsTwoNumbersPositive(5, 5) == 10)
    #expect(addsTwoNumbersPositive(-3, 3) == nil)
    #expect(addsTwoNumbersPositive(3, -3) == nil)
    #expect(addsTwoNumbersPositive(-3, -3) == nil)
}

@Test func addsTwoNumbersThrowingTest() throws {
    #expect(try addsTwoNumbersThrowing(4, 4) == 8)
    #expect(throws: AddErrors.firstNumberShouldBePositive) {
        try addsTwoNumbersThrowing(-3, 3)
    }
    #expect(throws: AddErrors.secondNumberShouldBePositive) {
        try addsTwoNumbersThrowing(3, -3)
    }
    #expect(throws: AddErrors.allNumbersShouldBePositive) {
        try addsTwoNumbersThrowing(-3, -3)
    }
    #expect(throws: AddErrors.overflow) {
        try addsTwoNumbersThrowing(.max, 3)
    }
}

