//
//  MasterBudgetController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation
import CloudKit

class MasterBudgetController {
    
    // Shared Instance
    static let sharedInstance = MasterBudgetController()
    
    // Local Source of Truth
    var budgets: [MasterBudget] = []
    
    let privateDB = CKContainer.default().privateCloudDatabase
    
    // CRUD: - Functions
    
    // Create Function
    func createBudgetWith(name: String, completion: @escaping (MasterBudget?) -> Void) {
        let newBudget = MasterBudget(name: name)
        let record = CKRecord(masterBudget: newBudget)
        
        privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            
            guard let record = record,
                let masterBudget = MasterBudget(record: record) else {completion(nil); return}
            self.budgets.append(newBudget)
            completion(masterBudget)
        }
    }
    
    // Read Function
    func fetchBudgets(completion: @escaping([MasterBudget]?) -> Void) {
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: MasterBudgetConstants.recordType, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(nil)
                return
            }
            
            guard let records = records else {completion(nil); return}
            let budgets = records.compactMap{ MasterBudget(record: $0) }
            self.budgets = budgets
            completion(budgets)
        }
    }
    
    // Delete Functions
    func delete(masterBudget: MasterBudget, completion: @escaping(Bool) -> Void) {
        guard let index = budgets.firstIndex(of: masterBudget) else {return}
        budgets.remove(at: index)
        
        deleteFromCloud(recordID: masterBudget.recordID, database: privateDB) { (success) in
            completion(success ? true : false)
        }
    }
    
    private func deleteFromCloud(recordID: CKRecord.ID, database: CKDatabase, completion: @escaping(Bool) -> Void) {
        database.delete(withRecordID: recordID) { (_, error) in
            if let error = error {
                print("Error in \(#function): \(error.localizedDescription) /n---/n \(error)")
                completion(false)
            }
            completion(true)
        }
    }
    
}// End of class
