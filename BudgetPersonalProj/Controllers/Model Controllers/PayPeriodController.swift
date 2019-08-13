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
    func createAllPayPeriodsWith(lastPayDate: Date, payPeriodLength: Int, masterBudget: MasterBudget, completion: @escaping (Bool) -> Void) {
        var newStartDate = lastPayDate
        var newEndDate = Calendar.current.date(byAdding: .day, value: payPeriodLength, to: newStartDate)!
        let sixMonths = Calendar.current.date(byAdding: .day, value: 182, to: lastPayDate)!
        var createCounter = 0
        var appendCounter = 0
        while newEndDate <= sixMonths {
            createPayPeriod(withStartDate: newStartDate, endDate: newEndDate, masterBudget: masterBudget) { (payPeriod) in
                if let payPeriod = payPeriod {
                    masterBudget.payPeriods.append(payPeriod)
                    appendCounter += 1
                    if createCounter == appendCounter {
                        completion(true)
                    }
                }
            }
            newStartDate = Calendar.current.date(byAdding: .day, value: 1, to: newEndDate)!
            newEndDate = Calendar.current.date(byAdding: .day, value: payPeriodLength, to: newStartDate)!
            createCounter += 1
        }
    }
    
    func createPayPeriod(withStartDate startDate: Date, endDate: Date, masterBudget: MasterBudget, completion: @escaping (PayPeriod?) -> Void) {
        let newPayPeriod = PayPeriod(startDate: startDate, endDate: endDate, masterBudget: masterBudget)
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
    
    func createPayPeriodsForSpecificDaysIncome(firstDay: Int, secondDay: Int, startDate: Date, masterIncome: Income, masterBudget: MasterBudget) {
        let maximumDay: Int = [firstDay, secondDay].max() ?? firstDay
        let calendar = Calendar.current
        var endDate: Date
        let sixMonthsOut = calendar.date(byAdding: .day, value: 182, to: Date())!
        let firstTestDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        var currentTestDate = firstTestDate
        var isDone = false
        while !isDone {
            let dayNumber = calendar.dateComponents([Calendar.Component.day], from: currentTestDate).day!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            let nextDayNumber = calendar.dateComponents([Calendar.Component.day], from: nextDay).day!
            if dayNumber > nextDayNumber {
                if dayNumber <= maximumDay {
                    let newStartDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
                    self.createPayPeriod(withStartDate: startDate, endDate: currentTestDate, masterBudget: masterBudget) { (payPeriod) in
                        if let payPeriod = payPeriod {
                            IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: payPeriod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: masterIncome.amount, payPeriod: payPeriod, masterIncome: masterIncome, completion: { (income) in
                                if let income = income {
                                    payPeriod.income.append(income)
                                }
                            })
                            masterBudget.payPeriods.append(payPeriod)
                        }
                    }
                    if currentTestDate < sixMonthsOut {
                        self.createPayPeriodsForSpecificDaysIncome(firstDay: firstDay, secondDay: secondDay, startDate: newStartDate, masterIncome: masterIncome, masterBudget: masterBudget)
                        isDone = true
                    } else {
                        isDone = true
                    }
                } else {
                    currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
                }
            } else if dayNumber == firstDay || dayNumber == secondDay {
                endDate = calendar.date(byAdding: .day, value: -1, to: currentTestDate)!
                self.createPayPeriod(withStartDate: startDate, endDate: endDate, masterBudget: masterBudget) { (payPeriod) in
                    if let payPeriod = payPeriod {
                        IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: payPeriod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: masterIncome.amount, payPeriod: payPeriod, masterIncome: masterIncome, completion: { (income) in
                            if let income = income {
                                payPeriod.income.append(income)
                            }
                        })
                        masterBudget.payPeriods.append(payPeriod)
                    }
                }
                if endDate < sixMonthsOut {
                    self.createPayPeriodsForSpecificDaysIncome(firstDay: firstDay, secondDay: secondDay, startDate: currentTestDate, masterIncome: masterIncome, masterBudget: masterBudget)
                    isDone = true
                } else {
                    isDone = true
                }
            } else {
                currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            }
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
    
    func updatePayPeriodWith(masterBudget: MasterBudget, payPeriod: PayPeriod, totalFromLast: Double, totalForThisPayPeriod: Double, completion: @escaping(Bool) -> Void) {
        payPeriod.lastPayPeriodTotal = totalFromLast
        payPeriod.payPeriodTotal = totalForThisPayPeriod
        payPeriod.masterBudget = masterBudget
        let recordToSave = CKRecord(payPeriod: payPeriod)
        
        CKContainer.default().privateCloudDatabase.fetch(withRecordID: payPeriod.recordID) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(false)
                return
            }
            
            let operation = CKModifyRecordsOperation(recordsToSave: [recordToSave], recordIDsToDelete: nil)

            operation.savePolicy = .changedKeys
            operation.queuePriority = .high
            operation.qualityOfService = .userInitiated
            operation.modifyRecordsCompletionBlock = { (records, recordID, error) in
                if let error = error {
                    print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                    completion(false)
                    return
                }
                
                completion(true)
            }
            CKContainer.default().privateCloudDatabase.add(operation)
        }
    }
}
