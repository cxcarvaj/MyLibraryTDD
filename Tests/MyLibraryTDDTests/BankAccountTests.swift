//
//  BankAccountTests.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 22/4/25.
//

import Testing
import Foundation
@testable import MyLibraryTDD

// Los tests se ejecutan al mismo tiempo. Pero es bueno saber que la instancia de `BankAccount` se destruye al finalizar la ejecución de cada test.

@Suite("Test for bank accounts")
struct BankAccountTests {
    let bankAccount = BankAccount(nameAccount: "Carlos")
    
    let otherBankAccount = BankAccount(nameAccount: "Lily")
    
    static let amounts: [Decimal] = [1000, 100, 10, 10000, -100, -1000, -10]
    
    @Test("Validates the name of the account and the balance to 0")
    func testBankAccount() {
        #expect(bankAccount.nameAccount == "Carlos")
        #expect(bankAccount.balance == 0)
    }

    @Test("Validates that the deposit is made correctly")
    func testDeposit() {
        let amount: Decimal = 1000
        bankAccount.deposit(amount: amount)
        #expect(bankAccount.balance == amount)
    }
    
    @Test("Validates negative deposit")
    func testDepositNegative() {
        let amount: Decimal = -1000
        bankAccount.deposit(amount: amount)
        #expect(bankAccount.balance == 0)
    }
    
    @Test("Validates different values of deposit", arguments: BankAccountTests.amounts)
    func testDepositDifferentValues(amount: Decimal) {
        bankAccount.deposit(amount: amount)
        if amount > 0 {
            #expect(bankAccount.balance == amount)
        } else {
            #expect(bankAccount.balance == 0)
        }
    }
    
    @Test("Validates transfers between accounts")
    func testTransfer() throws {
        let deposit: Decimal = 1000
        let transfer: Decimal = 500
        bankAccount.deposit(amount: deposit)
        
        try bankAccount.transfer(amount: transfer, account: otherBankAccount)
        
        #expect(bankAccount.balance == deposit - transfer)
        
        #expect(otherBankAccount.balance == transfer)
    }
    
    @Test("Validates transfers between accounts without funds")
    func testTransferWithoutFunds() throws {
        let deposit: Decimal = 1000
        let transfer: Decimal = 1500
        bankAccount.deposit(amount: deposit)
    
        #expect(throws: BankErrors.insufficientFunds) {
            try bankAccount.transfer(amount: transfer, account: otherBankAccount)
        }
        
//        #expect(bankAccount.balance == deposit)
//        
//        #expect(otherBankAccount.balance == 0)
    }
    
    @Test("Validates transfers between accounts with negative values")
    func testTransferWithNegatives() throws {
        let deposit: Decimal = -500
        
        #expect(throws: BankErrors.negativeAmount) {
            try bankAccount.transfer(amount: deposit, account: otherBankAccount)
        }
        
//        #expect(bankAccount.balance == 0)
    }
    
    @Test("Validates withdrawals")
    func testWithdraw() throws {
        let deposit: Decimal = 2000
        bankAccount.deposit(amount: deposit)
        let withdrawal: Decimal = 1000
        try bankAccount.withdraw(amount: withdrawal)

        #expect(bankAccount.balance == deposit - withdrawal)
    }
    
    @Test("Validates withdrawals with negative values")
    func testWithdrawWithNegatives() {
        let withdrawal: Decimal = -500
        #expect(throws: BankErrors.negativeAmount) {
            try bankAccount.withdraw(amount: withdrawal)
        }
//        #expect(bankAccount.balance == 0)
    }
    
    @Test("Validates withdrawals without funds")
    func testWithdrawWithoutFunds() {
        let withdrawal: Decimal = 1000
        #expect(throws: BankErrors.insufficientFunds) {
            try bankAccount.withdraw(amount: withdrawal)
        }
//        bankAccount.withdraw(amount: withdrawal)
//        #expect(bankAccount.balance == 0)
    }
}

