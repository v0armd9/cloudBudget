//
//  IncomeController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/30/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

class IncomeController {
    
    static let sharedInstance = IncomeController()
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // Create Functions
    func createIncomeWith(name: String, payDate: Date?, firstSpecificDay: Int?, secondSpecificDay: Int?, amount: Double, payPeriod: PayPeriod, masterIncome: Income, completion: @escaping (Income?) -> Void) {
        let newIncome = Income(name: name, payDate: payDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: amount, payPeriod: payPeriod, masterBudget: nil, masterIncome: masterIncome)
        let record = CKRecord(income: newIncome)
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else {completion(nil); return}
            let income = Income(record: record, payPeriod: payPeriod, masterBudget: nil, masterIncome: masterIncome)
            completion(income)
        }
    }
    
    func createMasterIncomeWith(name: String, paydate: Date?, firstSpecificDay: Int?, secondSpecificDay: Int?, amount: Double, masterBudget: MasterBudget, completion: @escaping (Income?) -> Void) {
        let newMasterIncome = Income(name: name, payDate: paydate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: amount, payPeriod: nil, masterBudget: masterBudget, masterIncome: nil)
        let record = CKRecord(income: newMasterIncome)
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let record = record else {completion(nil); return}
            let income = Income(record: record, payPeriod: nil, masterBudget: masterBudget, masterIncome: nil)
            completion(income)
        }
    }
    
    func fetchIncome(forPayPeriod payPeriod: PayPeriod, completion: @escaping([Income]?) -> Void) {
        let payPeriodReference = payPeriod.recordID
        let payPeriodPredicate = NSPredicate(format: "%K == %@", IncomeConstants.payPeriodReferenceKey, payPeriodReference)
//        let incomeIDs = payPeriod.income.compactMap( {$0.recordID} )
//        let avoidDuplicatesPredicate = NSPredicate(format: "NOT(recordID IN %@)", incomeIDs)
//        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [payPeriodPredicate, avoidDuplicatesPredicate])
        let query = CKQuery(recordType: IncomeConstants.recordType, predicate: payPeriodPredicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            guard let records = records else {completion(nil); return}
            let income = records.compactMap { Income(record: $0, payPeriod: payPeriod, masterBudget: nil, masterIncome: nil)}
//            payPeriod.income.append(contentsOf: income)
            completion(income)
        }
    }
    
}
