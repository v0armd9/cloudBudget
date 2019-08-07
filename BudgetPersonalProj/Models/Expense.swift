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
    static let masterExpenseReferenceKey = "MasterExpenseReference"
    fileprivate static let nameKey = "Name"
    fileprivate static let billDateKey = "BillDate"
    fileprivate static let monthlyKey = "Monthly"
    fileprivate static let daysBetweenBillsKey = "DaysBetweenBills"
    fileprivate static let biWeeklyKey = "BiWeekly"
    fileprivate static let amountKey = "Amount"
}

class Expense {
    
    var name: String
    var billDate: Date
    var monthly: Int?
    var daysBetweenBills: Int?
    var amount: Double
    var recordID: CKRecord.ID
    weak var payPeriod: PayPeriod?
    weak var masterBudget: MasterBudget?
    weak var masterExpense: Expense?
    
    var payPeriodReference: CKRecord.Reference? {
        guard let payPeriod = payPeriod else {return nil}
        return CKRecord.Reference(recordID: payPeriod.recordID, action: .deleteSelf)
    }
    
    var masterBudgetReference: CKRecord.Reference? {
        guard let masterBudget = masterBudget else {return nil}
        return CKRecord.Reference(recordID: masterBudget.recordID, action: .deleteSelf)
    }
    
    var masterExpenseReference: CKRecord.Reference? {
        guard let masterExpense = masterExpense else {return nil}
        return CKRecord.Reference(recordID: masterExpense.recordID, action: .deleteSelf)
    }
    
    init(name: String, billDate: Date, monthly: Int?, daysBetweenBills: Int?, amount: Double, payPeriod: PayPeriod?, masterBudget: MasterBudget?, masterExpense: Expense?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.billDate = billDate
        self.monthly = monthly
        self.daysBetweenBills = daysBetweenBills
        self.amount = amount
        self.recordID = recordID
        self.payPeriod = payPeriod
        self.masterBudget = masterBudget
        self.masterExpense = masterExpense
    }
    
    convenience init?(record: CKRecord, payPeriod: PayPeriod?, masterBudget: MasterBudget?, masterExpense: Expense?) {
        guard let name = record[ExpenseConstants.nameKey] as? String,
            let billDate = record[ExpenseConstants.billDateKey] as? Date,
            let amount = record[ExpenseConstants.amountKey] as? Double
        else {return nil}
        let monthly = record[ExpenseConstants.monthlyKey] as? Int
        let daysBetweenBills = record[ExpenseConstants.daysBetweenBillsKey] as? Int
        
        self.init(name: name,billDate: billDate, monthly: monthly, daysBetweenBills: daysBetweenBills, amount: amount, payPeriod: payPeriod, masterBudget: masterBudget, masterExpense: masterExpense, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(expense: Expense) {
        self.init(recordType: ExpenseConstants.recordType, recordID: expense.recordID)
        self.setValue(expense.payPeriodReference, forKey: ExpenseConstants.payPeriodReferenceKey)
        self.setValue(expense.masterBudgetReference, forKey: ExpenseConstants.masterBudgetReferenceKey)
        self.setValue(expense.masterExpenseReference, forKey: ExpenseConstants.masterExpenseReferenceKey)
        self.setValue(expense.name, forKey: ExpenseConstants.nameKey)
        self.setValue(expense.billDate, forKey: ExpenseConstants.billDateKey)
        self.setValue(expense.monthly, forKey: ExpenseConstants.monthlyKey)
        self.setValue(expense.daysBetweenBills, forKey: ExpenseConstants.daysBetweenBillsKey)
        self.setValue(expense.amount, forKey: ExpenseConstants.amountKey)
    }
}

extension Expense: Equatable {
    static func == (lhs: Expense, rhs: Expense) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}


