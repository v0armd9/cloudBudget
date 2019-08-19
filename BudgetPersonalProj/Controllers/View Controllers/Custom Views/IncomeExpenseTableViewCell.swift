//
//  IncomeExpenseTableViewCell.swift
//  BudgetPersonalProj
//
//  Created by Darin Armstrong on 8/19/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class IncomeExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var dayNumberLabel: UILabel!
    @IBOutlet weak var amountLebel: UILabel!
    @IBOutlet weak var isDoneButton: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }


}
