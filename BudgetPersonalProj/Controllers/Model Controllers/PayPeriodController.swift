//
//  PayPeriodController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/30/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

class PayPeriodController {
    
    static let sharedInstance = PayPeriodController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // CRUD: - Functions
    
    //Create Function
    func createAllPayPeriodsWith(lastPayDate: Date, payPeriodLength: Int, masterBudget: MasterBudget) {
        var newStartDate = lastPayDate
        var newEndDate = Calendar.current.date(byAdding: .day, value: payPeriodLength, to: newStartDate)!
        let sixMonths = Calendar.current.date(byAdding: .day, value: 182, to: lastPayDate)!
        
        while newEndDate <= sixMonths {
            createPayPeriod(withStartDate: newStartDate, endDate: newEndDate, masterBudget: masterBudget) { (payPeriod) in
                if let payPeriod = payPeriod {
                    masterBudget.payPeriods.append(payPeriod)
                }
            }
            newStartDate = Calendar.current.date(byAdding: .day, value: 1, to: newEndDate)!
            newEndDate = Calendar.current.date(byAdding: .day, value: payPeriodLength, to: newStartDate)!        }
    }
    
    func createPayPeriod(withStartDate startDate: Date, endDate: Date, masterBudget: MasterBudget, completion: @escaping (PayPeriod?) -> Void) {
        let newPayPeriod = PayPeriod(startDate: startDate, endDate: endDate, masterBudget: masterBudget)
        masterBudget.payPeriods.append(newPayPeriod)
        let record = CKRecord(payPeriod: newPayPeriod)
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else {completion(nil); return}
            let payPeriod = PayPeriod(record: record, masterBudget: masterBudget)
            completion(payPeriod)
        }
    }
    
    // Read Function
    func fetchPayperiods(forMasterBudget masterBudget: MasterBudget, completion: @escaping ([PayPeriod]?) -> Void) {
        let masterBudgetReference = masterBudget.recordID
        let masterBudgetPredicate = NSPredicate(format: "%K == %@", PayPeriodConstants.recordReferenceKey, masterBudgetReference)
        let payPeriodIDs = masterBudget.payPeriods.compactMap({ $0.recordID})
        let avoidDuplicatesPredicate = NSPredicate(format: "NOT(recordID IN %@)", payPeriodIDs)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [masterBudgetPredicate, avoidDuplicatesPredicate])
        let query = CKQuery(recordType: PayPeriodConstants.recordType, predicate: compoundPredicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let payPeriods = records.compactMap{ PayPeriod(record: $0, masterBudget: masterBudget)}
            masterBudget.payPeriods.append(contentsOf: payPeriods)
            completion(payPeriods)
        }
    }
    
}
