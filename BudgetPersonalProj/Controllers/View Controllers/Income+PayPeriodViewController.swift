//
//  Income+PayPeriodViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Armstrong on 8/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class Income_PayPeriodViewController: UIViewController {
    
    @IBOutlet weak var generatePayPeriodButton: UIButton!
    @IBOutlet weak var specificDaysPicker: UIPickerView!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeFrameControl: UISegmentedControl!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var amountTextField: UITextField!
    @IBOutlet weak var nextButton: UIBarButtonItem!
    @IBOutlet weak var successView: UIView!
    @IBOutlet weak var dateLabel: UILabel!
    
    var masterBudget: MasterBudget?
    var primaryIncome: Income?
    var firstSelectedDay: Int = 1
    var secondSelectedDay: Int = 1
    var customPickerData = ["1","2", "3", "4", "5","6", "7", "8", "9","10", "11", "12", "13","14", "15", "16", "17","18", "19", "20", "21","22", "23", "24", "25","26", "27", "28", "29", "30", "31"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        specificDaysPicker.delegate = self
        specificDaysPicker.dataSource = self
        specificDaysPicker.alpha = 0
        specificDaysPicker.isHidden = true
        setUpViews()
        
        
        // Do any additional setup after loading the view.
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUpViews()
    }
    
    @IBAction func generateButtonTapped(_ sender: UIButton) {
        guard let name = nameTextField.text,
        let amountText = amountTextField.text,
        let amount = Double(amountText),
        let masterBudget = masterBudget
            else {presentmissingFieldsAlert(); return}
        if primaryIncome != nil {
            if (primaryIncome?.payDate)! > datePicker.date {
                presentDateAlert()
                return
            }
        }
        generatePayPeriodButton.isEnabled = false
        nextButton.isEnabled = false
        if masterBudget.masterIncomeList.isEmpty{
            generatePayPeriodButton.setTitle("Generating Payperiods...", for: .normal)
        } else {
            generatePayPeriodButton.setTitle("Adding Income...", for: .normal)
            
        }
        if timeFrameControl.selectedSegmentIndex == 0 {
            if masterBudget.masterIncomeList.isEmpty {
                IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: datePicker.date, firstSpecificDay: firstSelectedDay, secondSpecificDay: secondSelectedDay, amount: amount, masterBudget: masterBudget) { (income) in
                    if let income = income {
                        masterBudget.masterIncomeList.append(income)
                        self.primaryIncome = income
                        DispatchQueue.main.async {
                            PayPeriodController.sharedInstance.createAllPayPeriodsWith(lastPayDate: self.datePicker.date, payPeriodLength: 7, masterBudget: masterBudget, completion: { (success) in
                                if success {
                                    for payPeriod in masterBudget.payPeriods {
                                        IncomeController.sharedInstance.createIncomeWith(name: income.name, payDate: payPeriod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: income.amount, payPeriod: payPeriod, masterIncome: income, completion: { (income) in
                                            if let income = income {
                                                payPeriod.income.append(income)
                                            }
                                        })
                                    }
                                    sleep(3)
                                    DispatchQueue.main.async {
                                        self.nextButton.isEnabled = true
                                        self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                                        self.generatePayPeriodButton.isEnabled = true
                                        self.setUpViewsAfterPrimary()
                                        self.showSuccess()
                                    }
                                }
                            })
                        }
                    }
                }
            } else {
                createIncomeWithPayDate(timeFrame: 7) { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.nextButton.isEnabled = true
                            self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                            self.generatePayPeriodButton.isEnabled = true
                            self.setUpViewsAfterPrimary()
                            self.showSuccess()
                        }
                    }
                }
            }
        } else if timeFrameControl.selectedSegmentIndex == 1 {
            if masterBudget.masterIncomeList.isEmpty {
                IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: datePicker.date, firstSpecificDay: firstSelectedDay, secondSpecificDay: secondSelectedDay, amount: amount, masterBudget: masterBudget) { (income) in
                    if let income = income {
                        masterBudget.masterIncomeList.append(income)
                        self.primaryIncome = income
                        DispatchQueue.main.async {
                            PayPeriodController.sharedInstance.createAllPayPeriodsWith(lastPayDate: self.datePicker.date, payPeriodLength: 14, masterBudget: masterBudget, completion: { (success) in
                                if success {
                                    for payPeriod in masterBudget.payPeriods {
                                        IncomeController.sharedInstance.createIncomeWith(name: income.name, payDate: payPeriod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: income.amount, payPeriod: payPeriod, masterIncome: income, completion: { (income) in
                                            if let income = income {
                                                payPeriod.income.append(income)
                                            }
                                        })
                                    }
                                    sleep(3)
                                    DispatchQueue.main.async {
                                        self.nextButton.isEnabled = true
                                        self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                                        self.generatePayPeriodButton.isEnabled = true
                                        self.setUpViewsAfterPrimary()
                                        self.showSuccess()
                                    }
                                }
                            })
                        }
                    }
                }
            } else {
                createIncomeWithPayDate(timeFrame: 14) { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.nextButton.isEnabled = true
                            self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                            self.generatePayPeriodButton.isEnabled = true
                            self.setUpViewsAfterPrimary()
                            self.showSuccess()
                        }
                    }
                }
            }
        } else if timeFrameControl.selectedSegmentIndex == 2 {
            if masterBudget.masterIncomeList.isEmpty{
                IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: datePicker.date, firstSpecificDay: firstSelectedDay, secondSpecificDay: secondSelectedDay, amount: amount, masterBudget: masterBudget) { (income) in
                    if let income = income {
                        masterBudget.masterIncomeList.append(income)
                        self.primaryIncome = income
                        DispatchQueue.main.async {
                            PayPeriodController.sharedInstance.createPayPeriodsForSpecificDaysIncome(firstDay: self.firstSelectedDay, secondDay: self.secondSelectedDay, startDate: self.datePicker.date, masterIncome: income, masterBudget: masterBudget, completion: { (success)  in
                                if success {
                                    sleep(3)
                                    DispatchQueue.main.async {
                                        self.nextButton.isEnabled = true
                                        self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                                        self.generatePayPeriodButton.isEnabled = true
                                        self.setUpViewsAfterPrimary()
                                        self.showSuccess()
                                    }
                                }
                            })
                        }
                    }
                }
            } else {
                createIncomeWithSpecificDays(firstSpecificDay: firstSelectedDay, secondSpecificDay: secondSelectedDay) { (success) in
                    if success {
                        DispatchQueue.main.async {
                            self.nextButton.isEnabled = true
                            self.generatePayPeriodButton.setTitle("Add Income", for: .normal)
                            self.generatePayPeriodButton.isEnabled = true
                            self.setUpViewsAfterPrimary()
                            self.showSuccess()
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        guard let masterBudget = masterBudget  else {navigationController?.popToRootViewController(animated: true); return}
        MasterBudgetController.sharedInstance.delete(masterBudget: masterBudget) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)                    
                }
            }
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: UIBarButtonItem) {
    }
    
    @IBAction func timeFrameControlValueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            UIView.animate(withDuration: 0.3, animations: {
                self.timeFrameControl.isEnabled = false
                self.specificDaysPicker.alpha = 0
                self.specificDaysPicker.isHidden = true
            }, completion: { (true) in
                if true {
                    self.timeFrameControl.isEnabled = true
                }
            })
        } else if sender.selectedSegmentIndex == 1 {
            UIView.animate(withDuration: 0.3, animations: {
                    self.timeFrameControl.isEnabled = false
                    self.specificDaysPicker.alpha = 0
                    self.specificDaysPicker.isHidden = true
            }, completion: { (true) in
                if true {
                    self.timeFrameControl.isEnabled = true
                }
            })

        } else if sender.selectedSegmentIndex == 2 {
            UIView.animate(withDuration: 0.3, animations: {
                self.timeFrameControl.isEnabled = false
                self.specificDaysPicker.alpha = 1
                self.specificDaysPicker.isHidden = false
            }, completion: { (true) in
                if true {
                    self.timeFrameControl.isEnabled = true
                }
            })
        }
    }
    
    
    
    func setUpViews() {
        datePicker.setValue(#colorLiteral(red: 0.631372549, green: 0.9725490196, blue: 0.8039215686, alpha: 1), forKeyPath: "textColor")
        generatePayPeriodButton.layer.cornerRadius = generatePayPeriodButton.frame.height/2
        generatePayPeriodButton.layer.borderWidth = 0.5
        generatePayPeriodButton.layer.borderColor = #colorLiteral(red: 0.631372549, green: 0.9725490196, blue: 0.8039215686, alpha: 1)
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name your income...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mint!])
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Enter an amount...", attributes: [NSAttributedString.Key.foregroundColor: UIColor.mint!])
        dateLabel.text = "When was your last payday?"
        navigationItem.title = masterBudget?.name
        nextButton.isEnabled = false
        successView.isHidden = true
        
    }
    
    func setUpViewsAfterPrimary() {
        nameTextField.text = ""
        amountTextField.text = ""
        datePicker.setDate(Date(), animated: true)
        timeFrameControl.selectedSegmentIndex = 0
        dateLabel.text = "When is your next payday?"
    }
    
    func createIncomeWithPayDate(timeFrame: Int, completion: @escaping(Bool) -> Void) {
        let paydate = datePicker.date
        guard let name = nameTextField.text, name != "",
            let masterBudget = masterBudget,
            let amountText = amountTextField.text,
            let amount = Double(amountText)
            else {completion(false); return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: paydate, firstSpecificDay: nil, secondSpecificDay: nil, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.createIncomeFrom(masterIncome: income, startDate: income.payDate!, timeframe: timeFrame)
            }
        }
        completion(true)
    }
    
    func createIncomeFrom(masterIncome: Income, startDate: Date, timeframe: Int) {
        guard let masterBudget = masterBudget else {return}
        let startDate = startDate
        let calendar = Calendar.current
        let sixMonthsFromDate = calendar.date(byAdding: .day, value: 182, to: Date())!
        var isDone = false
        for payPeriod in masterBudget.payPeriods {
            let payPeriodInterval = DateInterval(start: payPeriod.startDate, end: payPeriod.endDate)
            if payPeriodInterval.contains(startDate) {
                IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: masterIncome.amount, payPeriod: payPeriod, masterIncome: masterIncome) { (income) in
                    if let income = income {
                        payPeriod.income.append(income)
                    }
                }
            }
        }
        while !isDone {
            if startDate < sixMonthsFromDate {
                let newStartDate = calendar.date(byAdding: .day, value: timeframe, to: startDate)!
                self.createIncomeFrom(masterIncome: masterIncome, startDate: newStartDate, timeframe: timeframe)
                isDone = true
                
            } else {
                isDone = true
            }
        }
    }
    
    func createIncomeWithSpecificDays(firstSpecificDay: Int, secondSpecificDay: Int, completion: @escaping(Bool) -> Void) {
        let payDate = datePicker.date
        guard let name = nameTextField.text, name != "",
            let masterBudget = masterBudget,
            let amountText = amountTextField.text,
            let amount = Double(amountText)
            else {completion(false); return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: payDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.createIncomeFrom(masterIncome: income, startDate: income.payDate!, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay)
            }
        }
    }
    
    func createIncomeFrom(masterIncome: Income, startDate: Date, firstSpecificDay: Int, secondSpecificDay: Int) {
        guard let masterBudget = masterBudget else {return}
        let calendar = Calendar.current
        let maximumDay: Int = [firstSpecificDay, secondSpecificDay].max() ?? firstSpecificDay
        let sixMonthsFromStartDate = calendar.date(byAdding: .day, value: 182, to: Date())!
        let firstTestDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        var currentTestDate = firstTestDate
        var isDone = false
        for payPeriod in masterBudget.payPeriods {
            let payPeriodInterval = DateInterval(start: payPeriod.startDate, end: payPeriod.endDate)
            if payPeriodInterval.contains(startDate) {
                IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: startDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: masterIncome.amount, payPeriod: payPeriod, masterIncome: masterIncome) { (income) in
                    if let income = income {
                        payPeriod.income.append(income)
                    }
                }
            }
        }
        while !isDone {
            let dayNumber = calendar.dateComponents([Calendar.Component.day], from: currentTestDate).day!
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            let nextDayNumber = calendar.dateComponents([Calendar.Component.day], from: nextDay).day!
            if dayNumber > nextDayNumber {
                if dayNumber <= maximumDay {
                    if currentTestDate < sixMonthsFromStartDate {
                        self.createIncomeFrom(masterIncome: masterIncome, startDate: currentTestDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay)
                        isDone = true
                    } else {
                        isDone = true
                    }
                } else {
                    currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
                }
            } else if dayNumber == firstSpecificDay || dayNumber == secondSpecificDay {
                if currentTestDate < sixMonthsFromStartDate {
                    self.createIncomeFrom(masterIncome: masterIncome, startDate: currentTestDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay)
                    isDone = true
                } else {
                    isDone = true
                }
            } else {
                currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            }
        }
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
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toExpenseView" {
            guard let masterBudget = self.masterBudget,
                let primaryIncome = self.primaryIncome,
            let destinationVC = segue.destination as? ExpenseViewController
                else {return}
            destinationVC.masterBudget = masterBudget
            destinationVC.primaryIncome = primaryIncome
        }
    }
}

extension Income_PayPeriodViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let titleData = customPickerData[row]
        let title = NSAttributedString(string: titleData, attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
        return title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //        let indexpath = IndexPath(item: row, section: component)
        //        firstSelectedDay = customPickerData[IndexPath]
        switch component{
        case 0:
            let firstDay = customPickerData[row]
            firstSelectedDay = Int(firstDay) ?? 1
        case 1:
            let secondDay = customPickerData[row]
            secondSelectedDay = Int(secondDay) ?? 1
        default:
            break
        }
    }
}

extension Income_PayPeriodViewController {
    func presentDateAlert() {
        let title = NSAttributedString(string: "Please enter a future payment date.", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
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
