//
//  PayPeriod.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

class PayPeriod {
    
    var startDate: Date
    var endDate: Date
    var income: [Income]
    var expenses: [Expense]
    
    init(startDate: Date, endDate: Date, income: [Income], expenses: [Expense]) {
        self.startDate = startDate
        self.endDate = endDate
        self.income = income
        self.expenses = expenses
    }
    
}
