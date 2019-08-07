//
//  ExpenseController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/30/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

class ExpenseController {
    
    static let sharedInstance = ExpenseController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // Create Functions
    func createExpenseWith(name: String, billDate: Date, monthly: Int?, daysBetweenBills: Int?, amount: Double, payPeriod: PayPeriod, masterExpense: Expense, completion: @escaping (Expense?) -> Void) {
        let newExpense = Expense(name: name, billDate: billDate, monthly: monthly, daysBetweenBills: daysBetweenBills, amount: amount, payPeriod: payPeriod, masterBudget: nil, masterExpense: masterExpense)
        payPeriod.expenses.append(newExpense)
        let record = CKRecord(expense: newExpense)
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else {completion(nil); return}
            let expense = Expense(record: record, payPeriod: payPeriod, masterBudget: nil, masterExpense: masterExpense)
            completion(expense)
        }
    }
    
    func createMasterExpenseWith(name: String, billDate: Date, monthly: Int?, daysBetweenBills: Int?, amount: Double, masterBudget: MasterBudget, completion: @escaping (Expense?) -> Void) {
        let newMasterExpense = Expense(name: name, billDate: billDate, monthly: monthly, daysBetweenBills: daysBetweenBills, amount: amount, payPeriod: nil, masterBudget: masterBudget, masterExpense: nil)
        let record = CKRecord(expense: newMasterExpense)
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else {completion(nil); return}
            let expense = Expense(record: record, payPeriod: nil, masterBudget: masterBudget, masterExpense: nil)
            completion(expense)
        }
    }
}
