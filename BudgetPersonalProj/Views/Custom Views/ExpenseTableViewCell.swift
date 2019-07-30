//
//  ExpenseTableViewCell.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class ExpenseTableViewCell: UITableViewCell {
    
    @IBOutlet weak var expenseNameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var frequencySegmentedControl: UISegmentedControl!
    @IBOutlet weak var occurencePicker: UIPickerView!
    @IBOutlet weak var addCellButton: UIButton!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func addCellButtonTapped(_ sender: UIButton) {
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
