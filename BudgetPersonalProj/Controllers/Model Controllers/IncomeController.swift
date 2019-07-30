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
    
    func createIncomeWith(name: String, payDate: Date, amount: Double)
    
}
