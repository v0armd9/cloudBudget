//
//  CreateBudgetTableViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class CreateBudgetTableViewController: UITableViewController {
    
    @IBOutlet weak var budgetNameTextField: UITextField!
    @IBOutlet weak var recordTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var recordNameTextField: UITextField!
    @IBOutlet weak var recordAmountTextField: UITextField!
    @IBOutlet weak var timeframeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var customDayPicker: UIPickerView!
    @IBOutlet weak var addButton: UIButton!
    
    var masterBudget: MasterBudget?
    var masterIncome: Income?
    var suplementalIncome: [Income]?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // Check if we have a master
        if masterBudget == masterBudget {
           checkForRecordType()
        } else {
            generateNewMasterBudget()
        }
    }
    
    func checkForRecordType() {
        // Check index for Income/expense, call specific helper function
        if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
            // master income helper
            createMasterIncome()
            // payPeriod helper
            generatePayPeriods()
            // add income to payperiods
        } else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
            // expense helper
        }
    }
    
    func createMasterIncome(completion: @escaping(Bool) -> Void) {
        let paydate = datePicker.date
        guard let name = recordNameTextField.text, name != "",
            let masterBudget = masterBudget,
            let amountText = recordAmountTextField.text,
            let amount = Double(amountText)
            else {completion(false); return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: paydate, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.masterIncome = income
            }
        }
        completion(true)
    }
    
    func createIncome() {
        let paydate = datePicker.date
        guard let name = recordNameTextField.text, name != "",
            let masterBudget = masterBudget,
            let amountText = recordAmountTextField.text,
            let amount = Double(amountText)
            else {return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: paydate, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.suplementalIncome?.append(income)
            }
        }
    }
    
    func generatePayPeriods() {
        guard let masterBudget = masterBudget else {return}
        let lastPayDate = datePicker.date
        var payPeriodLength: Double
        switch timeframeSegmentedControl.selectedSegmentIndex {
        case 0:
            payPeriodLength = 6
        case 1:
            payPeriodLength = 13
        default:
            return
        }
        PayPeriodController.sharedInstance.createAllPayPeriodsWith(lastPayDate: lastPayDate, payPeriodLength: payPeriodLength, masterBudget: masterBudget)
        
    }
    
    func addPrimaryIncomeToPayPeriods() {
        guard let payPeriods = masterBudget?.payPeriods,
        let name = recordNameTextField.text,
        let amountText = recordAmountTextField.text,
        let masterIncome = masterIncome,
        let amount = Double(amountText)
            else {return}
        for payPeriod in payPeriods {
            let payDate = payPeriod.startDate
            IncomeController.sharedInstance.createIncomeWith(name: name, payDate: payDate, amount: amount, payPeriod: payPeriod, masterIncome: masterIncome, completion: <#T##(Income?) -> Void#>)
        }
    }
    
    func addSupplementalIncomeToPayPeriods() {
        
    }
    

    func generateNewMasterBudget() {
        guard let name = budgetNameTextField.text, name != "" else {return}
      // Generate a master budget
        MasterBudgetController.sharedInstance.createBudgetWith(name: name) { (masterBudget) in
            if let masterBudget = masterBudget {
                self.masterBudget = masterBudget
                self.checkForRecordType()
            }
        }
        // in the completion, we need check the Index for income/expense
        
    }
    
    
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        // Configure the cell...

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }

} // End of Class

extension CreateBudgetTableViewController {
    func askForIncomePriority(){
        let incomeTypeAlert = UIAlertController(title: "Is this your primary income?", message: "Please select whether this is primary or suplemental income", preferredStyle: .alert)
        
        let primaryAction = UIAlertAction(title: "Primary", style: .default) { (action) in
            self.createMasterIncome(completion: { (success) in
                if success {
                    self.generatePayPeriods()
                }
            })
            
        }
        let supplementalAction = UIAlertAction(title: "Supplemental", style: .default) { (action) in
            if self.masterIncome == nil{
                self.askForPrimary()
            } else {
                self.createIncome()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default)
        
        incomeTypeAlert.addAction(primaryAction)
        incomeTypeAlert.addAction(supplementalAction)
        incomeTypeAlert.addAction(cancelAction)
        
        present(incomeTypeAlert, animated: true)
    }
    
    func askForPrimary() {
        let askForPrimaryAlert = UIAlertController(title: "Please add Primary Income", message: "We need your main source of income first, please start with that.", preferredStyle: .alert)
        
        let okButtonAction = UIAlertAction(title: "OK", style: .cancel)
        
        askForPrimaryAlert.addAction(okButtonAction)
        
        present(askForPrimaryAlert, animated: true)
    }
}
