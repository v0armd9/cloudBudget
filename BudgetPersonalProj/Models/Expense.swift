//
//  Expense.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

struct ExpenseConstants {
    static let recordType = "Expense"
    static let payPeriodReferenceKey = "PayPeriodReference"
    static let masterBudgetReferenceKey = "MasterBudgetReference"
    fileprivate static let nameKey = "Name"
    fileprivate static let dueDateKey = "DueDate"
    fileprivate static let amountKey = "Amount"
}

class Expense {
    
    var name: String
    var dueDate: Date
    var amount: Double
    var recordID: CKRecord.ID
    weak var payPeriod: PayPeriod?
    weak var masterBudget: MasterBudget?
    
    var payPeriodReference: CKRecord.Reference? {
        guard let payPeriod = payPeriod else {return nil}
        return CKRecord.Reference(recordID: payPeriod.recordID, action: .deleteSelf)
    }
    
    var masterBudgetReference: CKRecord.Reference? {
        guard let masterBudget = masterBudget else {return nil}
        return CKRecord.Reference(recordID: masterBudget.recordID, action: .deleteSelf)
    }
    
    init(name: String, dueDate: Date, amount: Double, payPeriod: PayPeriod?, masterBudget: MasterBudget?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.dueDate = dueDate
        self.amount = amount
        self.recordID = recordID
        self.payPeriod = payPeriod
        self.masterBudget = masterBudget
    }
    
    convenience init?(record: CKRecord, payPeriod: PayPeriod?, masterBudget: MasterBudget?) {
        guard let name = record[ExpenseConstants.nameKey] as? String,
        let dueDate = record[ExpenseConstants.dueDateKey] as? Date,
        let amount = record[ExpenseConstants.amountKey] as? Double
            else {return nil}
        
        self.init(name: name, dueDate: dueDate, amount: amount, payPeriod: payPeriod, masterBudget: masterBudget, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(expense: Expense) {
        self.init(recordType: ExpenseConstants.recordType, recordID: expense.recordID)
        self.setValue(expense.payPeriodReference, forKey: ExpenseConstants.payPeriodReferenceKey)
        self.setValue(expense.masterBudgetReference, forKey: ExpenseConstants.masterBudgetReferenceKey)
        self.setValue(expense.name, forKey: ExpenseConstants.nameKey)
        self.setValue(expense.dueDate, forKey: ExpenseConstants.dueDateKey)
        self.setValue(expense.amount, forKey: ExpenseConstants.amountKey)
    }
}

extension Expense: Equatable {
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}


