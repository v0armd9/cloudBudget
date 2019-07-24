//
//  Expense.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

class Expense {
    
    var name: String
    var dueDate: Date
    var amount: Double
    
    init(name: String, dueDate: Date, amount: Double) {
        self.name = name
        self.dueDate = dueDate
        self.amount = amount
    }
}


