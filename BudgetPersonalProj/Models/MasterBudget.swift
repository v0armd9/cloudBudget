//
//  MasterBudget.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

struct MasterBudgetConstants {
    static let recordType = "MasterBudget"
    fileprivate static let nameKey = "Name"
    fileprivate static let payPeriods = "PayPeriods"
    fileprivate static let masterExpenseKey = "MasterExpenseList"
    fileprivate static let masterIncomeKey = "MasterIncomeList"
}

class MasterBudget {
    
    var name: String
    var payPeriods: [PayPeriod]
    var masterExpenseList: [Expense]
    var masterIncomeList: [Income]
    var recordID: CKRecord.ID
    
    init(name: String, payperiods: [PayPeriod] = [], masterExpenseList: [Expense] = [], masterIncomeList: [Income] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.name = name
        self.payPeriods = payperiods
        self.masterExpenseList = masterExpenseList
        self.masterIncomeList = masterIncomeList
        self.recordID = recordID
    }
    
    convenience init?(record: CKRecord) {
        guard let name = record[MasterBudgetConstants.nameKey] as? String
            else {return nil}
        
        self.init(name: name, recordID: record.recordID)
    }
}

extension CKRecord {
    convenience init(masterBudget: MasterBudget) {
        self.init(recordType: MasterBudgetConstants.recordType, recordID: masterBudget.recordID)
        self.setValue(masterBudget.name, forKey: MasterBudgetConstants.nameKey)
    }
}

extension MasterBudget: Equatable {
    static func == (lhs: MasterBudget, rhs: MasterBudget) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}


