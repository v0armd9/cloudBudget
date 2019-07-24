//
//  Income.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/23/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

class Income {
    
    var name: String
    var payDate: Date
    var amount: Double
    
    init(name: String, payDate: Date, amount: Double) {
        self.name = name
        self.payDate = payDate
        self.amount = amount
    }
    
    
    
}
