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
    static let masterIncomeReferenceKey = "MasterIncomeReference"
    fileprivate static let nameKey = "Name"
    fileprivate static let payDateKey = "PayDate"
    fileprivate static let firstSpecificDayKey = "FirstSpecificDay"
    fileprivate static let secondSpecificDayKey = "SecondSpecificDay"
    fileprivate static let amountKey = "Amount"
}

class Income {
    
    // MARK: - Class Properties
    var name: String
    var payDate: Date?
    var firstSpecificDay: Int?
    var secondSpecificDay: Int?
    var amount: Double
    var recordID: CKRecord.ID
    weak var payPeriod: PayPeriod?
    weak var masterBudget: MasterBudget?
    weak var masterIncome: Income?
    
    var payPeriodReference: CKRecord.Reference? {
        guard let payPeriod = payPeriod else {return nil}
        return CKRecord.Reference(recordID: payPeriod.recordID, action: .deleteSelf)
    }
    
    var masterBudgetReference: CKRecord.Reference? {
        guard let masterBudget = masterBudget else {return nil}
        return CKRecord.Reference(recordID: masterBudget.recordID, action: .deleteSelf)
    }
    
    var masterIncomeReference: CKRecord.Reference? {
        guard let masterIncome = masterIncome else {return nil}
        return CKRecord.Reference(recordID: masterIncome.recordID, action: .deleteSelf)
    }
    
    // Designated Init
    init(name: String, payDate: Date?, firstSpecificDay: Int?, secondSpecificDay: Int?, amount: Double, payPeriod: PayPeriod?, masterBudget: MasterBudget?, masterIncome: Income?, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.payDate = payDate
        self.firstSpecificDay = firstSpecificDay
        self.secondSpecificDay = secondSpecificDay
        self.amount = amount
        self.recordID = recordID
        self.payPeriod = payPeriod
        self.masterBudget = masterBudget
        self.masterIncome = masterIncome
    }
    
    convenience init?(record: CKRecord, payPeriod: PayPeriod?, masterBudget: MasterBudget?, masterIncome: Income?) {
        guard let name = record[IncomeConstants.nameKey] as? String,
        let payDate = record[IncomeConstants.payDateKey] as? Date,
        let firstSpecificDay = record[IncomeConstants.firstSpecificDayKey] as? Int,
        let secondSpecificDay = record[IncomeConstants.secondSpecificDayKey] as? Int,
        let amount = record[IncomeConstants.amountKey] as? Double
        else {return nil}
        
        self.init(name: name, payDate: payDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: amount, payPeriod: payPeriod, masterBudget: masterBudget, masterIncome: masterIncome, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(income: Income) {
        self.init(recordType: IncomeConstants.recordType, recordID: income.recordID)
        self.setValue(income.payPeriodReference, forKey: IncomeConstants.payPeriodReferenceKey)
        self.setValue(income.masterBudgetReference, forKey: IncomeConstants.masterBudgetReferenceKey)
        self.setValue(income.masterIncome, forKey: IncomeConstants.masterIncomeReferenceKey)
        self.setValue(income.name, forKey: IncomeConstants.nameKey)
        self.setValue(income.payDate, forKey: IncomeConstants.payDateKey)
        self.setValue(income.firstSpecificDay, forKey: IncomeConstants.firstSpecificDayKey)
        self.setValue(income.secondSpecificDay, forKey: IncomeConstants.secondSpecificDayKey)
        self.setValue(income.amount, forKey: IncomeConstants.amountKey)
    }
}

extension Income: Equatable {
    static func == (lhs: Income, rhs: Income) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}
