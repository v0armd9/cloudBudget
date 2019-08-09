//
//  PayPeriod.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

struct PayPeriodConstants {
    static let recordType = "PayPeriod"
    static let recordReferenceKey = "RecordReference"
    fileprivate static let startDateKey = "StartDate"
    fileprivate static let endDateKey = "EndDate"
    fileprivate static let lastPayPeriodTotalKey = "LastPayPeriodTotal"
    fileprivate static let incomeKey = "Income"
    fileprivate static let expensesKey = "Expenses"
    fileprivate static let payPeriodTotalKey = "PayPeriodTotal"
}

class PayPeriod {
    
    var startDate: Date
    var endDate: Date
    var lastPayPeriodTotal: Double
    var income: [Income]
    var expenses: [Expense]
    var payPeriodTotal: Double
    var recordID: CKRecord.ID
    weak var masterBudget : MasterBudget?
    
    var recordReference: CKRecord.Reference? {
        guard let masterBudget = masterBudget else {return nil}
        return CKRecord.Reference(recordID: masterBudget.recordID, action: .deleteSelf)
    }
    
    init(startDate: Date, endDate: Date,lastPayPeriodTotal: Double = 0, income: [Income] = [], expenses: [Expense] = [], payPeriodTotal: Double = 0, masterBudget: MasterBudget, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.startDate = startDate
        self.endDate = endDate
        self.lastPayPeriodTotal = lastPayPeriodTotal
        self.income = income
        self.expenses = expenses
        self.payPeriodTotal = payPeriodTotal
        self.recordID = recordID
        self.masterBudget = masterBudget
    }
    
    convenience init?(record: CKRecord, masterBudget: MasterBudget) {
        guard let startDate = record[PayPeriodConstants.startDateKey] as? Date,
        let endDate = record[PayPeriodConstants.endDateKey] as? Date,
        let lastPayPeriodTotal = record[PayPeriodConstants.lastPayPeriodTotalKey] as? Double,
        let payPeriodTotal = record[PayPeriodConstants.payPeriodTotalKey] as? Double
            else {return nil}
        
        self.init(startDate: startDate, endDate: endDate, lastPayPeriodTotal: lastPayPeriodTotal, payPeriodTotal: payPeriodTotal, masterBudget: masterBudget, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(payPeriod: PayPeriod) {
        self.init(recordType: PayPeriodConstants.recordType, recordID: payPeriod.recordID)
        self.setValue(payPeriod.recordReference, forKey: PayPeriodConstants.recordReferenceKey)
        self.setValue(payPeriod.startDate, forKey: PayPeriodConstants.startDateKey)
        self.setValue(payPeriod.endDate, forKey: PayPeriodConstants.endDateKey)
        self.setValue(payPeriod.lastPayPeriodTotal, forKey: PayPeriodConstants.lastPayPeriodTotalKey)
        self.setValue(payPeriod.payPeriodTotal, forKey: PayPeriodConstants.payPeriodTotalKey)
//        self.setValue(payPeriod.income, forKey: PayPeriodConstants.incomeKey)
//        self.setValue(payPeriod.expenses, forKey: PayPeriodConstants.expensesKey)
    }
}

extension PayPeriod: Equatable {
    static func == (lhs: PayPeriod, rhs: PayPeriod) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
