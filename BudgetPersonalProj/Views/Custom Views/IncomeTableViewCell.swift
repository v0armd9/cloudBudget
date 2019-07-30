//
//  IncomeTableViewCell.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class IncomeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var frequencyLabel: UILabel!
    @IBOutlet weak var incomeName: UITextField!
    @IBOutlet weak var incomeAmount: UITextField!
    @IBOutlet weak var daysOfMonthPicker: UIPickerView!
    @IBOutlet weak var lastPayDatePicker: UIDatePicker!
    @IBOutlet weak var payFrequencySegmentedControl: UISegmentedControl!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
