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
    fileprivate static let incomeKey = "Income"
    fileprivate static let expensesKey = "Expenses"
}

class PayPeriod {
    
    var startDate: Date
    var endDate: Date
    var income: [Income]
    var expenses: [Expense]
    var recordID: CKRecord.ID
    weak var masterBudget : MasterBudget?
    
    var recordReference: CKRecord.Reference? {
        guard let masterBudget = masterBudget else {return nil}
        return CKRecord.Reference(recordID: masterBudget.recordID, action: .deleteSelf)
    }
    
    init(startDate: Date, endDate: Date, income: [Income] = [], expenses: [Expense] = [], masterBudget: MasterBudget, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.startDate = startDate
        self.endDate = endDate
        self.income = income
        self.expenses = expenses
        self.recordID = recordID
        self.masterBudget = masterBudget
    }
    
    convenience init?(record: CKRecord, masterBudget: MasterBudget) {
        guard let startDate = record[PayPeriodConstants.startDateKey] as? Date,
        let endDate = record[PayPeriodConstants.endDateKey] as? Date
            else {return nil}
        
        self.init(startDate: startDate, endDate: endDate, masterBudget: masterBudget, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(payPeriod: PayPeriod) {
        self.init(recordType: PayPeriodConstants.recordType, recordID: payPeriod.recordID)
        self.setValue(payPeriod.recordReference, forKey: PayPeriodConstants.recordReferenceKey)
        self.setValue(payPeriod.startDate, forKey: PayPeriodConstants.startDateKey)
        self.setValue(payPeriod.endDate, forKey: PayPeriodConstants.endDateKey)
        self.setValue(payPeriod.income, forKey: PayPeriodConstants.incomeKey)
        self.setValue(payPeriod.expenses, forKey: PayPeriodConstants.expensesKey)
    }
}

extension PayPeriod: Equatable {
    static func == (lhs: PayPeriod, rhs: PayPeriod) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
