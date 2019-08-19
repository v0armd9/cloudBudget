//
//  ExpenseViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Armstrong on 8/19/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class ExpenseViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var timeFrameSegmentedControl: UISegmentedControl!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var customDayPicker: UIPickerView!
    @IBOutlet weak var addExpenseButton: UIButton!
    @IBOutlet weak var successView: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpViews()
    }
    
    var masterBudget: MasterBudget? {
        didSet {
            loadViewIfNeeded()
            navigationController?.title = self.masterBudget?.name
        }
    }
    
    var primaryIncome: Income?
    var customPickerData = ["1","2", "3", "4", "5","6", "7", "8", "9","10", "11", "12", "13","14", "15", "16", "17","18", "19", "20", "21","22", "23", "24", "25","26", "27", "28", "29", "30", "31"]
    var firstSelectedDay: Int = 1
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        guard let masterBudget = masterBudget else {navigationController?.popToRootViewController(animated: true); return}
        MasterBudgetController.sharedInstance.delete(masterBudget: masterBudget) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func doneButtonTapped(_ sender: UIBarButtonItem) {
        if let masterBudget = masterBudget {
            masterBudget.payPeriods.sort(by: { $0.startDate < $1.startDate})
            var lastPayPeriodTotal = 0.0
            for payperiod in masterBudget.payPeriods {
                var incomeTotal = 0.0
                var expensesTotal = 0.0
                for income in payperiod.income {
                    incomeTotal += income.amount
                }
                for expense in payperiod.expenses {
                    expensesTotal += expense.amount
                    print(expensesTotal)
                }
                let thisPayPeriodTotal = lastPayPeriodTotal + incomeTotal - expensesTotal
                PayPeriodController.sharedInstance.updatePayPeriodWith(masterBudget: masterBudget, payPeriod: payperiod, totalFromLast: lastPayPeriodTotal, totalForThisPayPeriod: thisPayPeriodTotal) { (success) in
                    if success {
                        print("successfully updated totals for payperiod: \(payperiod.recordID)")
                    }
                }
                lastPayPeriodTotal = thisPayPeriodTotal
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func addExpenseButtonTapped(_ sender: UIButton) {
        guard nameTextField.text != "", amountTextField.text != "" else {presentmissingFieldsAlert(); return}
        guard primaryIncome!.payDate! < datePicker.date else {presentDateAlert(); return}
        addExpenseButton.setTitle("Adding Expense", for: .normal)
        if let name = nameTextField.text, let amountText = amountTextField.text {
            if timeFrameSegmentedControl.selectedSegmentIndex == 0 {
                guard let amount = Double(amountText),
                    let masterBudget = masterBudget
                    else {return}
                let timeFrame = 7
                ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: nil, daysBetweenBills: timeFrame, amount: amount, masterBudget: masterBudget) { (expense) in
                    if let expense = expense {
                        self.createExpenseFrom(masterExpense: expense, withTimeFrame: timeFrame, andStartDate: expense.billDate)
                        DispatchQueue.main.async {
                            self.masterBudget?.masterExpenseList.append(expense)
                            self.showSuccess()
                        }
                        DispatchQueue.main.async {
                            self.showSuccess()
                        }
                    }
                }
            }
            else if timeFrameSegmentedControl.selectedSegmentIndex == 1 {
                guard let amount = Double(amountText),
                    let masterBudget = masterBudget
                    else {return}
                let timeFrame = 14
                ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: nil, daysBetweenBills: timeFrame, amount: amount, masterBudget: masterBudget) { (expense) in
                    if let expense = expense {
                        self.createExpenseFrom(masterExpense: expense, withTimeFrame: timeFrame, andStartDate: expense.billDate)
                        DispatchQueue.main.async {
                            self.masterBudget?.masterExpenseList.append(expense)
                        }
                        DispatchQueue.main.async {
                            self.showSuccess()
                        }
                    }
                }
            }
            else if timeFrameSegmentedControl.selectedSegmentIndex == 2 {
                guard let amount = Double(amountText),
                    let masterBudget = masterBudget
                    else {return}
                
                ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: firstSelectedDay, daysBetweenBills: nil, amount: amount, masterBudget: masterBudget) { (expense) in
                    if let expense = expense {
                        DispatchQueue.main.async {
                            masterBudget.masterExpenseList.append(expense)
                            self.createExpenseWithSpecificDayFrom(masterExpense: expense, startDate: expense.billDate)
                            self.showSuccess()
                        }
                    }
                }
            }
        }
    }
    
    func setUpViews() {
        datePicker.setValue(#colorLiteral(red: 0.631372549, green: 0.9725490196, blue: 0.8039215686, alpha: 1), forKeyPath: "textColor")
        addExpenseButton.layer.cornerRadius = addExpenseButton.frame.height/2
        addExpenseButton.layer.borderWidth = 0.5
        addExpenseButton.layer.borderColor = #colorLiteral(red: 0.631372549, green: 0.9725490196, blue: 0.8039215686, alpha: 1)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name this expense...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mint!])
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Enter an amount...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mint!])
        navigationItem.title = masterBudget?.name
        successView.isHidden = true
    }
    
    func showSuccess() {
        self.successView.isHidden = false
        self.successView.alpha = 1
        UIView.animate(withDuration: 2, animations: {
            self.successView.alpha = 0
        }) { (success) in
            if success {
                self.successView.isHidden = true
            }
            self.nameTextField.text = ""
            self.amountTextField.text = ""
            self.datePicker.setDate(Date(), animated: true)
            self.addExpenseButton.setTitle("Add Expense", for: .normal)
        }
    }
    
    func createExpenseWithSpecificDayFrom(masterExpense: Expense, startDate: Date) {
        guard let masterBudget = masterBudget else {return}
        let startDate = startDate
        let specificDay = masterExpense.monthly
        let calendar = Calendar.current
        let sixMonthsFromStartDate = calendar.date(byAdding: .day, value: 182, to: Date())!
        let firstTestDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        var currentTestDate = firstTestDate
        var isDone = false
        guard let name = nameTextField.text,
            let amountText = amountTextField.text,
            let amount = Double(amountText)
            else {return}
        masterBudget.payPeriods.sort(by: { $0.startDate < $1.startDate})
        print(masterBudget.payPeriods.count)
        for payPeriod in masterBudget.payPeriods {
            let payPeriodInterval = DateInterval(start: payPeriod.startDate, end: payPeriod.endDate)
            if payPeriodInterval.contains(startDate) {
                ExpenseController.sharedInstance.createExpenseWith(name: name, billDate: startDate, monthly: specificDay, daysBetweenBills: nil, amount: amount, payPeriod: payPeriod, masterExpense: masterExpense) { (expense) in
                    if let expense = expense {
                        DispatchQueue.main.async {
                            payPeriod.expenses.append(expense)
                        }
                    }
                }
            }
        }
        while !isDone {
            let dayNumber = calendar.dateComponents([Calendar.Component.day], from: currentTestDate).day!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            let nextDayNumber = calendar.dateComponents([Calendar.Component.day], from: nextDay).day!
            if dayNumber > nextDayNumber {
                if currentTestDate < sixMonthsFromStartDate {
                    self.createExpenseWithSpecificDayFrom(masterExpense: masterExpense, startDate: currentTestDate)
                    isDone = true
                } else {
                    isDone = true
                }
            } else if dayNumber == specificDay {
                if currentTestDate < sixMonthsFromStartDate {
                    self.createExpenseWithSpecificDayFrom(masterExpense: masterExpense, startDate: currentTestDate)
                    isDone = true
                } else {
                    isDone = true
                }
            } else {
                currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            }
        }
    }
    
    func createExpenseFrom(masterExpense: Expense, withTimeFrame timeframe: Int, andStartDate startDate: Date) {
        var newStartDate = startDate
        let sixMonths = Calendar.current.date(byAdding: .day, value: 182, to: Date())!
        guard let masterBudget = masterBudget else {return}
        var isDone = false
        masterBudget.payPeriods.sort(by: { $0.startDate < $1.startDate})
        for (index, payPeriod) in masterBudget.payPeriods.enumerated() {
            print("Pay period: \(index) \(payPeriod.startDate)")
            let dateInterval = DateInterval(start: payPeriod.startDate, end: payPeriod.endDate)
            if dateInterval.contains(newStartDate) {
                if newStartDate <= sixMonths {
                    print("expense created")
                    ExpenseController.sharedInstance.createExpenseWith(name: masterExpense.name, billDate: newStartDate, monthly: nil, daysBetweenBills: timeframe, amount: masterExpense.amount, payPeriod: payPeriod, masterExpense: masterExpense) { (expense) in
                        if let expense = expense {
                            DispatchQueue.main.async {
                                payPeriod.expenses.append(expense)
                            }
                        }
                    }
                }
            }
        }
        newStartDate = Calendar.current.date(byAdding: .day, value: timeframe, to: newStartDate)!
        while !isDone {
            if newStartDate < sixMonths {
                self.createExpenseFrom(masterExpense: masterExpense, withTimeFrame: timeframe, andStartDate: newStartDate)
                isDone = true
            } else {
                isDone = true
                showSuccess()
            }
        }
    }
    
    
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension ExpenseViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let firstDay = customPickerData[row]
        firstSelectedDay = Int(firstDay)!
    }
}

extension ExpenseViewController {
    func presentDateAlert() {
        let title = NSAttributedString(string: "Please enter a date greater than your last paydate", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
        let noNameAlert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .default)
        
        noNameAlert.setValue(title, forKey: "attributedTitle")
        
        noNameAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 0.1721063446, green: 0.1721063446, blue: 0.1721063446, alpha: 1)
        noNameAlert.view.backgroundColor = .clear
        noNameAlert.view.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        noNameAlert.addAction(okButton)
        
        present(noNameAlert, animated: true)
    }
    
    func presentmissingFieldsAlert() {
        let title = NSAttributedString(string: "Please fill out all fields", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
        let noNameAlert = UIAlertController(title: "", message: nil, preferredStyle: .alert)
        
        let okButton = UIAlertAction(title: "Ok", style: .default)
        
        noNameAlert.setValue(title, forKey: "attributedTitle")
        
        noNameAlert.view.subviews.first?.subviews.first?.subviews.first?.backgroundColor = #colorLiteral(red: 0.1721063446, green: 0.1721063446, blue: 0.1721063446, alpha: 1)
        noNameAlert.view.backgroundColor = .clear
        noNameAlert.view.tintColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        noNameAlert.addAction(okButton)
        
        present(noNameAlert, animated: true)
    }
}
