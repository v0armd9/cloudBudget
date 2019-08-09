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
    
    func fetchExpense(forPayPeriod payPeriod: PayPeriod, completion: @escaping([Expense]?) -> Void) {
        let payPeriodReference = payPeriod.recordID
        let payPeriodPredicate = NSPredicate(format: "%K == %@", ExpenseConstants.payPeriodReferenceKey, payPeriodReference)
        let expenseIDs = payPeriod.expenses.compactMap( {$0.recordID} )
        let avoidDuplicatesPredicate = NSPredicate(format: "NOT(recordID IN %@)", expenseIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [payPeriodPredicate, avoidDuplicatesPredicate])
        let query = CKQuery(recordType: ExpenseConstants.recordType, predicate: compoundPredicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let expenses = records.compactMap { Expense(record: $0, payPeriod: payPeriod, masterBudget: nil, masterExpense: nil)}
            payPeriod.expenses.append(contentsOf: expenses)
            completion(expenses)
        }
    }
}
