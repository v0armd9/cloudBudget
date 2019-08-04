//
//  PayPeriodListTableViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class PayPeriodListTableViewController: UITableViewController {
    
    var budget: MasterBudget?

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let budget = budget {
            PayPeriodController.sharedInstance.fetchPayperiods(forMasterBudget: budget) { (payperiods) in
                if let payperiods = payperiods {
                    budget.payPeriods = payperiods
                    budget.payPeriods.sort(by: { $0.startDate < $1.startDate})
                    DispatchQueue.main.async {
                        self.tableView.reloadData()                        
                    }
                }
            }
        }
        tableView.reloadData()
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {        return budget?.payPeriods.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "payPeriodCell", for: indexPath)
        
        guard let payperiod = budget?.payPeriods[indexPath.row] else {return UITableViewCell()}
        
        cell.textLabel?.text = "\(payperiod.startDate.dateToFormattedString()) - \(payperiod.endDate.dateToFormattedString())"

        return cell
    }


    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */


    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayPeriodDetailView" {
            guard let indexPath = tableView.indexPathForSelectedRow,
                let destinationVC = segue.destination as? Income_ExpenseListTableViewController,
                let payperiod = budget?.payPeriods[indexPath.row]
            else {return}
            destinationVC.masterBudget = budget
            destinationVC.payPeriod = payperiod
            
        }
    }

}
