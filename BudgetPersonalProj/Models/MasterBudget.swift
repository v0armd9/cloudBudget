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
    var payperiods: [PayPeriod]
    
    init(name: String, payperiods: [PayPeriod]) {
        self.name = name
        self.payperiods = payperiods
    }
}
