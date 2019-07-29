//
//  Income.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

// incomeConstants
struct IncomeConstants {
    static let recordType = "Income"
    static let payPeriodReferenceKey = "PayPeriodReference"
    static let masterBudgetReferenceKey = "MasterBudgetReference"
    fileprivate static let nameKey = "Name"
    fileprivate static let payDateKey = "PayDate"
    fileprivate static let amountKey = "Amount"
}

class Income {
    
    // MARK: - Class Properties
    var name: String
    var payDate: Date
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
    
    // Designated Init
    init(name: String, payDate: Date, amount: Double, payPeriod: PayPeriod?, masterBudget: MasterBudget?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.payDate = payDate
        self.amount = amount
        self.recordID = recordID
        self.payPeriod = payPeriod
        self.masterBudget = masterBudget
    }
    
    convenience init?(record: CKRecord, payPeriod: PayPeriod?, masterBudget: MasterBudget?) {
        guard let name = record[IncomeConstants.nameKey] as? String,
        let payDate = record[IncomeConstants.payDateKey] as? Date,
        let amount = record[IncomeConstants.amountKey] as? Double
        else {return nil}
        
        self.init(name: name, payDate: payDate, amount: amount, payPeriod: payPeriod, masterBudget: masterBudget, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(income: Income) {
        self.init(recordType: IncomeConstants.recordType, recordID: income.recordID)
        self.setValue(income.payPeriodReference, forKey: IncomeConstants.payPeriodReferenceKey)
        self.setValue(income.masterBudgetReference, forKey: IncomeConstants.masterBudgetReferenceKey)
        self.setValue(income.name, forKey: IncomeConstants.nameKey)
        self.setValue(income.payDate, forKey: IncomeConstants.payDateKey)
        self.setValue(income.amount, forKey: IncomeConstants.amountKey)
    }
}

extension Income: Equatable {
    static func == (lhs: Income, rhs: Income) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
