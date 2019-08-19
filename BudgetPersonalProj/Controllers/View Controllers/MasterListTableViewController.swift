//
//  MasterListTableViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Marcus Armstrong on 7/29/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit
import CloudKit

class MasterListTableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        performFullSync(completion: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        performFullSync(completion: nil)
    }
    
    func performFullSync(completion:((Bool) -> Void)?) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        MasterBudgetController.sharedInstance.fetchBudgets { (budgets) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                completion?(budgets != nil)
            }
        }
    }
    
    
    func checkForiCloud(){
        
    }

    @IBAction func addButtonTapped(_ sender: UIBarButtonItem) {
        presentNewBudgetAlert()
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return MasterBudgetController.sharedInstance.budgets.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MasterBudgetCell", for: indexPath)
        let budget = MasterBudgetController.sharedInstance.budgets[indexPath.row]
        
        cell.textLabel?.text = budget.name
        cell.textLabel?.textColor = UIColor.mint

        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let budgetList = MasterBudgetController.sharedInstance.budgets
            let budget = budgetList[indexPath.row]
            MasterBudgetController.sharedInstance.delete(masterBudget: budget) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            }
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toPayPeriodList" {
            guard let indexPath = tableView.indexPathForSelectedRow,
            let destinationVC = segue.destination as? PayPeriodListTableViewController
            else {return}
            let budget = MasterBudgetController.sharedInstance.budgets[indexPath.row]
            destinationVC.budget = budget
        }
    }
}

extension MasterListTableViewController {
    func presentNewBudgetAlert() {
        let addAlert = UIAlertController(title: "Create a Budget", message: "Enter a name", preferredStyle: .alert)
        
        addAlert.addTextField { (textfield) in
            textfield.placeholder = "Name your budget..."
        }
        
        addAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        addAlert.addAction(UIAlertAction(title: "Create", style: .default, handler: { [weak addAlert] (_) in
            guard let textfield = addAlert?.textFields?[0], let nameText = textfield.text else {return}
            
            MasterBudgetController.sharedInstance.createBudgetWith(name: nameText, completion: { (budget) in
                if budget != nil {
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
            })
        }))
        
        self.present(addAlert, animated: true, completion: nil)
        tableView.reloadData()
    }
}
