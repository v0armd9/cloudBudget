//
//  DateExtension.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 8/3/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import Foundation

extension Date {
    func dateToFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .none
        
        return formatter.string(from: self)
    }
}
