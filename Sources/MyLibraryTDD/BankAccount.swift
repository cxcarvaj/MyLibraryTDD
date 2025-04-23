//
//  BankAccount.swift
//  MyLibraryTDD
//
//  Created by Carlos Xavier Carvajal Villegas on 22/4/25.
//

import Foundation

enum BankErrors: Error {
    case insufficientFunds
    case negativeAmount
    case general
}

final class BankAccount {
    let nameAccount: String
    private(set) var balance: Decimal = 0
    
    init(nameAccount: String) {
        self.nameAccount = nameAccount
    }
    
    func deposit(amount: Decimal) {
        guard amount > 0 else { return }
        balance += amount
    }
    
    func transfer(amount: Decimal, account: BankAccount) throws(BankErrors) {
        try withdraw(amount: amount)
        account.deposit(amount: amount)
    }
    
    func withdraw(amount: Decimal) throws(BankErrors) {
        guard amount > 0 else { throw .negativeAmount }
        guard amount <= balance else { throw .insufficientFunds }
        balance -= amount
        
    }
    
}
