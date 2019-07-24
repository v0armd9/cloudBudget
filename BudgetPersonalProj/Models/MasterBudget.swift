//
//  MasterBudget.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

class MasterBudget {
    
    var name: String
    var payperiods: [PayPeriod]?
    var masterExpenseList: [Expense]?
    var masterIncomeList: [Income]?
    
    init(name: String, payperiods: [PayPeriod] = [], masterExpenseList: [Expense] = [], masterIncomeList: [Income] = []) {
        self.name = name
        self.payperiods = payperiods
    }
}


