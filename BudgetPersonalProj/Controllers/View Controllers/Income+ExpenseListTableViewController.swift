//
//  Income+ExpenseListTableViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 8/2/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class Income_ExpenseListTableViewController: UITableViewController {
    
    @IBOutlet weak var rollOverText: UITextField!
    
    var masterBudget: MasterBudget?
    var payPeriod: PayPeriod? {
        didSet {
            IncomeController.sharedInstance.fetchIncome(forPayPeriod: payPeriod!) { (income) in
                if let income = income {
                    self.payPeriod?.income = income
                    DispatchQueue.main.async {
                        self.loadViewIfNeeded()
                        self.rollOverText.text = String(self.payPeriod!.lastPayPeriodTotal)
                        self.tableView.reloadData()
                    }
                }
            }
            ExpenseController.sharedInstance.fetchExpense(forPayPeriod: payPeriod!) { (expenses) in
                if let expenses = expenses {
                    self.payPeriod?.expenses = expenses
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows: Int
        guard let payPeriod = payPeriod else {return 0}
        switch section {
        case 0:
            numberOfRows = payPeriod.income.count
        case 1:
            numberOfRows = payPeriod.expenses.count
        case 2:
            numberOfRows = 1
        default:
            numberOfRows = 0
        }
        return numberOfRows
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        guard let payPeriod = payPeriod
        else {return UITableViewCell()}
        switch indexPath.section {
        case 0:
            let income = payPeriod.income[indexPath.row]
            cell.textLabel?.text = income.name
            cell.detailTextLabel?.text = String(income.amount)
        case 1:
            let expense = payPeriod.expenses[indexPath.row]
            cell.textLabel?.text = expense.name
            cell.detailTextLabel?.text = String(expense.amount)
        case 2:
            cell.textLabel?.text = "Total:"
            cell.detailTextLabel?.text = String(payPeriod.payPeriodTotal)
        default:
            break
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        var sectionHeaderTitle: String
        switch section {
        case 0:
            sectionHeaderTitle = "Income"
        case 1:
            sectionHeaderTitle = "Expenses"
        case 2:
            sectionHeaderTitle = "Totals"
        default:
            sectionHeaderTitle = ""
        }
        return sectionHeaderTitle
    }

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
 

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

}
