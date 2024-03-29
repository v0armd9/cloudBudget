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
    @IBOutlet weak var timeFrameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var customDateLabel: UILabel!
    @IBOutlet weak var secondCustomDateLabel: UILabel!
    @IBOutlet weak var cancelButton: UIBarButtonItem!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    var masterBudget: MasterBudget?
    var masterIncome: Income?
    var suplementalIncome: [Income]?
    var incomeForTableView:[Income] = []
    var expensesForTableView: [Expense] = []
    var componentCountForCustomPicker = 1
    var customPickerData = ["1","2", "3", "4", "5","6", "7", "8", "9","10", "11", "12", "13","14", "15", "16", "17","18", "19", "20", "21","22", "23", "24", "25","26", "27", "28", "29", "30", "31"]
    var firstSelectedDay: Int?
    var secondSelectedDay: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateViewsForRecordType()
        updateViewsForTimeFrame()
        customDayPicker.delegate = self
        customDayPicker.dataSource = self
    }
    
    @IBAction func saveButtonTapped(_ sender: UIBarButtonItem) {
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
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        if masterBudget == nil {
            navigationController?.popViewController(animated: true)
        } else if let masterBudget = masterBudget {
            MasterBudgetController.sharedInstance.delete(masterBudget: masterBudget) { (success) in
                if success {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }
        }
    }
    
    
    @IBAction func addButtonTapped(_ sender: UIButton) {
        // Check if we have a master
        if masterBudget != nil {
            checkForRecordType()
        } else {
            generateNewMasterBudget()
        }
    }
    
    @IBAction func recordTypeControlValueChanged(_ sender: UISegmentedControl) {
        updateViewsForRecordType()
    }
    
    @IBAction func timeFrameControlValueChanged(_ sender: UISegmentedControl) {
        updateViewsForTimeFrame()
    }
    
    
    func updateViewsForRecordType() {
        if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
            timeframeSegmentedControl.selectedSegmentIndex = 0
            recordNameTextField.placeholder = "Give your income a name..."
            timeFrameLabel.text = "How often are you paid?"
            dateLabel.text = "When was your last paycheck?"
            addButton.setTitle("Add Income", for: .normal)
            updateViewsForTimeFrame()
        } else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
            if masterIncome != nil {
                timeframeSegmentedControl.selectedSegmentIndex = 0
                recordNameTextField.placeholder = "Give your expense a name..."
                timeFrameLabel.text = "How often are you billed?"
                dateLabel.text = "When was your last bill?"
                addButton.setTitle("Add Expense", for: .normal)
                updateViewsForTimeFrame()
            } else {
                recordTypeSegmentedControl.selectedSegmentIndex = 0
                updateViewsForRecordType()
                askForPrimary()
            }
        }
    }
    
    func updateViewsForTimeFrame() {
        if timeframeSegmentedControl.selectedSegmentIndex == 0 {
            if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
                customDayPicker.isHidden = true
                customDateLabel.isHidden = true
                secondCustomDateLabel.isHidden = true
            } else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
                customDayPicker.isHidden = true
                customDateLabel.isHidden = true
                secondCustomDateLabel.isHidden = true
            }
        } else if timeframeSegmentedControl.selectedSegmentIndex == 1 {
            if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
                customDayPicker.isHidden = true
                customDateLabel.isHidden = true
                secondCustomDateLabel.isHidden = true
            } else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
                customDayPicker.isHidden = true
                customDateLabel.isHidden = true
                secondCustomDateLabel.isHidden = true
            }
        } else if timeframeSegmentedControl.selectedSegmentIndex == 2 {
            if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
                customDayPicker.isHidden = false
                customDateLabel.isHidden = false
                secondCustomDateLabel.isHidden = false
                customDateLabel.text = "Choose First Pay Date"
                secondCustomDateLabel.text = "Choose Second Pay Date"
                componentCountForCustomPicker = 2
                customDayPicker.reloadAllComponents()
                
            }
            else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
                customDayPicker.isHidden = false
                customDateLabel.isHidden = false
                secondCustomDateLabel.isHidden = true
                customDateLabel.text = "Choose Recurring Bill Date"
                componentCountForCustomPicker = 1
                customDayPicker.reloadAllComponents()

            }
        }
    }
    
    func generateNewMasterBudget() {
        guard let name = budgetNameTextField.text, name != "" else {return}
        // Generate a master budget
        MasterBudgetController.sharedInstance.createBudgetWith(name: name) { (masterBudget) in
            if let masterBudget = masterBudget {
                self.masterBudget = masterBudget
                DispatchQueue.main.async {
                    self.checkForRecordType()
                }
            }
        }
    }
    
    func checkForRecordType() {
        // Check index for Income/expense, call specific helper function
        if recordTypeSegmentedControl.selectedSegmentIndex == 0 {
            // master income helper
            // payPeriod helper
            if masterIncome == nil {
                askForIncomePriority()
            }  else {
                if timeframeSegmentedControl.selectedSegmentIndex == 0 {
                    let timeFrame = 7
                    self.createIncomeWithPayDate(timeFrame: timeFrame, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                    
                }
                else if timeframeSegmentedControl.selectedSegmentIndex == 1 {
                    let timeFrame = 14
                    self.createIncomeWithPayDate(timeFrame: timeFrame, completion: { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    })
                }
                else if timeframeSegmentedControl.selectedSegmentIndex == 2 {
                    guard let firstDay = firstSelectedDay,
                        let secondDay = secondSelectedDay
                        else {return}
                    createIncomeWithSpecificDays(firstSpecificDay: firstDay, secondSpecificDay: secondDay) { (success) in
                        if success {
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
            // add income to payperiods
        } else if recordTypeSegmentedControl.selectedSegmentIndex == 1 {
            // expense helper
            if let name = recordNameTextField.text, let amountText = recordAmountTextField.text {
                if timeframeSegmentedControl.selectedSegmentIndex == 0 {
                    guard let amount = Double(amountText),
                    let masterBudget = masterBudget
                    else {return}
                    let timeFrame = 7
                    ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: nil, daysBetweenBills: timeFrame, amount: amount, masterBudget: masterBudget) { (expense) in
                        if let expense = expense {
                            self.createExpenseFrom(masterExpense: expense, withTimeFrame: timeFrame, andStartDate: expense.billDate)
                            DispatchQueue.main.async {
                                self.masterBudget?.masterExpenseList.append(expense)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                else if timeframeSegmentedControl.selectedSegmentIndex == 1 {
                    guard let amount = Double(amountText),
                        let masterBudget = masterBudget
                        else {return}
                    let timeFrame = 14
                    ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: nil, daysBetweenBills: timeFrame, amount: amount, masterBudget: masterBudget) { (expense) in
                        if let expense = expense {
                            self.createExpenseFrom(masterExpense: expense, withTimeFrame: timeFrame, andStartDate: expense.billDate)
                            DispatchQueue.main.async {
                                self.masterBudget?.masterExpenseList.append(expense)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                else if timeframeSegmentedControl.selectedSegmentIndex == 2 {
                    guard let amount = Double(amountText),
                    let monthlyDay = firstSelectedDay,
                    let masterBudget = masterBudget
                    else {return}
                    
                    ExpenseController.sharedInstance.createMasterExpenseWith(name: name, billDate: datePicker.date, monthly: monthlyDay, daysBetweenBills: nil, amount: amount, masterBudget: masterBudget) { (expense) in
                        if let expense = expense {
                            DispatchQueue.main.async {
                                masterBudget.masterExpenseList.append(expense)
                                self.createExpenseWithSpecificDayFrom(masterExpense: expense, startDate: expense.billDate)
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
            }
        }
    }
    
    func createIncomeWithPayDate(timeFrame: Int, completion: @escaping(Bool) -> Void) {
        let paydate = datePicker.date
        guard let name = recordNameTextField.text, name != "",
            let masterBudget = masterBudget,
            let amountText = recordAmountTextField.text,
            let amount = Double(amountText)
            else {completion(false); return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: paydate, firstSpecificDay: nil, secondSpecificDay: nil, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.incomeForTableView = masterBudget.masterIncomeList
                self.suplementalIncome?.append(income)
                self.createIncomeFrom(masterIncome: income, startDate: income.payDate!, timeframe: timeFrame)
                DispatchQueue.main.async {
                    self.budgetNameTextField.text = ""
                    self.recordNameTextField.text = ""
                    self.recordAmountTextField.text = ""
                }
            }
        }
        completion(true)
    }
    
    func createIncomeWithSpecificDays(firstSpecificDay: Int, secondSpecificDay: Int, completion: @escaping(Bool) -> Void) {
        let payDate = datePicker.date
        guard let name = recordNameTextField.text, name != "",
        let masterBudget = masterBudget,
        let amountText = recordAmountTextField.text,
        let amount = Double(amountText)
            else {completion(false); return}
        IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: payDate, firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, amount: amount, masterBudget: masterBudget) { (income) in
            if let income = income {
                masterBudget.masterIncomeList.append(income)
                self.incomeForTableView = masterBudget.masterIncomeList
                self.suplementalIncome?.append(income)
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
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
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
    
    func determinePayPeriodLengthForSpecificDaysIncome(firstSpecificDay: Int, secondSpecificDay: Int, startDate: Date, masterIncome: Income) {
        guard let masterBudget = masterBudget else {return}
        let maximumDay: Int = [firstSpecificDay, secondSpecificDay].max() ?? firstSpecificDay
        let calendar = Calendar.current
        var endDate: Date
        let sixMonthsFromStartDate = calendar.date(byAdding: .day, value: 182, to: Date())!
        let firstTestDate = calendar.date(byAdding: .day, value: 1, to: startDate)!
        var currentTestDate = firstTestDate
        var isDone = false
        while !isDone {
            let dayNumber = calendar.dateComponents([Calendar.Component.day], from: currentTestDate).day!
            print(dayNumber)
            print(currentTestDate)
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            let nextDayNumber = calendar.dateComponents([Calendar.Component.day], from: nextDay).day!
            if dayNumber > nextDayNumber {
                if dayNumber <= maximumDay {
                    let newStartDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
                    PayPeriodController.sharedInstance.createPayPeriod(withStartDate: startDate, endDate: currentTestDate, masterBudget: masterBudget) { (payPeriod) in
                        if let payPeriod = payPeriod {
                            print(payPeriod.recordID)
                            IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: payPeriod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: masterIncome.amount, payPeriod: payPeriod, masterIncome: masterIncome, completion: { (income) in
                                if let income = income {
                                    payPeriod.income.append(income)
                                }
                            })
                            masterBudget.payPeriods.append(payPeriod)
                        }
                    }
                    if currentTestDate < sixMonthsFromStartDate {
                        self.determinePayPeriodLengthForSpecificDaysIncome(firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, startDate: newStartDate, masterIncome: masterIncome)
                        isDone = true
                    } else {
                        isDone = true
                    }
                } else {
                    currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
                }
            } else if dayNumber == firstSpecificDay || dayNumber == secondSpecificDay {
                endDate = calendar.date(byAdding: .day, value: -1, to: currentTestDate)!
                PayPeriodController.sharedInstance.createPayPeriod(withStartDate: startDate, endDate: endDate, masterBudget: masterBudget) { (payperiod) in
                    if let payperiod = payperiod {
                        print(payperiod.recordID)
                        IncomeController.sharedInstance.createIncomeWith(name: masterIncome.name, payDate: payperiod.startDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: masterIncome.amount, payPeriod: payperiod, masterIncome: masterIncome, completion: { (income) in
                            if let income = income {
                                payperiod.income.append(income)
                            }
                        })
                        masterBudget.payPeriods.append(payperiod)
                    }
                }
                if endDate < sixMonthsFromStartDate {
                    self.determinePayPeriodLengthForSpecificDaysIncome(firstSpecificDay: firstSpecificDay, secondSpecificDay: secondSpecificDay, startDate: currentTestDate, masterIncome: masterIncome)
                    isDone = true
                } else {
                    isDone = true
                }
            } else {
                currentTestDate = calendar.date(byAdding: .day, value: 1, to: currentTestDate)!
            }
        }
    }
    
    func generatePayPeriods() {
        guard let masterBudget = masterBudget,
        let masterIncome = masterIncome
        else {return}
        let lastPayDate = datePicker.date
        var payPeriodLength: Int
        switch timeframeSegmentedControl.selectedSegmentIndex {
        case 0:
            payPeriodLength = 6
            PayPeriodController.sharedInstance.createAllPayPeriodsWith(lastPayDate: lastPayDate, payPeriodLength: payPeriodLength, masterBudget: masterBudget) { (success) in
                if success {
                    self.addPrimaryIncomeWithPayDateToPayPeriods(masterIncome: masterIncome, masterBudget: masterBudget)
                }
            }
        case 1:
            payPeriodLength = 13
            PayPeriodController.sharedInstance.createAllPayPeriodsWith(lastPayDate: lastPayDate, payPeriodLength: payPeriodLength, masterBudget: masterBudget) { (success) in
                if success {
                    self.addPrimaryIncomeWithPayDateToPayPeriods(masterIncome: masterIncome, masterBudget: masterBudget)
                }
            }
        case 2:
            if let firstDay = firstSelectedDay, let secondDay = secondSelectedDay {
                determinePayPeriodLengthForSpecificDaysIncome(firstSpecificDay: firstDay, secondSpecificDay: secondDay, startDate: lastPayDate, masterIncome: masterIncome)
            }
        default:
            return
        }
    }
    
    func addPrimaryIncomeWithPayDateToPayPeriods(masterIncome: Income, masterBudget: MasterBudget) {
        let payPeriods = masterBudget.payPeriods
        let name = masterIncome.name
        let amount = masterIncome.amount
        print(masterBudget.payPeriods.count)
        
        for payPeriod in payPeriods {
            let payDate = payPeriod.startDate
            IncomeController.sharedInstance.createIncomeWith(name: name, payDate: payDate, firstSpecificDay: nil, secondSpecificDay: nil, amount: amount, payPeriod: payPeriod, masterIncome: masterIncome) { (income) in
                if let income = income {
                    payPeriod.income.append(income)
                }
            }
        }
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
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
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
    
    func createExpenseFrom(masterExpense: Expense, withTimeFrame timeframe: Int, andStartDate startDate: Date) {
        var newStartDate = startDate
        let sixMonths = Calendar.current.date(byAdding: .day, value: 182, to: Date())!
        guard let masterBudget = masterBudget else {return}
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
                                self.tableView.reloadData()
                            }
                        }
                    }
                }
                newStartDate = Calendar.current.date(byAdding: .day, value: timeframe, to: newStartDate)!
            }
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
        guard let name = recordNameTextField.text,
        let amountText = recordAmountTextField.text,
        let amount = Double(amountText)
            else {return}
        for payPeriod in masterBudget.payPeriods {
            let payPeriodInterval = DateInterval(start: payPeriod.startDate, end: payPeriod.endDate)
            if payPeriodInterval.contains(startDate) {
                ExpenseController.sharedInstance.createExpenseWith(name: name, billDate: startDate, monthly: specificDay, daysBetweenBills: nil, amount: amount, payPeriod: payPeriod, masterExpense: masterExpense) { (expense) in
                    if let expense = expense {
                        DispatchQueue.main.async {
                            payPeriod.expenses.append(expense)
                            self.tableView.reloadData()
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
    
    

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard  let masterBudget = masterBudget else {return 0}
        var numberOfRows: Int
        switch section {
        case 0:
            numberOfRows = masterBudget.masterIncomeList.count
        case 1:
            numberOfRows = masterBudget.masterExpenseList.count
        default:
            return 0
        }
        return numberOfRows
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "recordCell", for: indexPath)
        guard let masterBudget = masterBudget else {return UITableViewCell()}
        switch indexPath.section {
        case 0:
            let income = masterBudget.masterIncomeList[indexPath.row]
            cell.textLabel?.text = income.name
            cell.detailTextLabel?.text = "\(income.amount)"
        case 1:
            let expense = masterBudget.masterExpenseList[indexPath.row]
            cell.textLabel?.text = expense.name
            cell.detailTextLabel?.text = "\(expense.amount)"
        default:
            return UITableViewCell()
        }
        return cell
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Income"
        case 1:
            return "Expenses"
        default:
            return ""
        }
    }

} // End of Class

extension CreateBudgetTableViewController {
    func askForIncomePriority(){
        let incomeTypeAlert = UIAlertController(title: "Is this your primary income?", message: "Please select whether this is primary or suplemental income", preferredStyle: .alert)
        
        let primaryAction = UIAlertAction(title: "Primary", style: .default) { (action) in
            let paydate = self.datePicker.date
            guard let name = self.recordNameTextField.text, name != "",
                let masterBudget = self.masterBudget,
                let amountText = self.recordAmountTextField.text,
                let amount = Double(amountText)
                else {return}
            IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: paydate, firstSpecificDay: nil, secondSpecificDay: nil, amount: amount, masterBudget: masterBudget) { (income) in
                if let income = income {
                    self.masterIncome = income
                    DispatchQueue.main.async {
                        self.navigationItem.title = self.budgetNameTextField.text
                        self.budgetNameTextField.isHidden = true
                        self.recordNameTextField.text = ""
                        self.recordAmountTextField.text = ""
                       // guard let masterIncome = self.masterIncome else {return}
                        masterBudget.masterIncomeList.append(income)
                        self.tableView.reloadData()
                        self.generatePayPeriods()
                        print(masterBudget.payPeriods.count)
                    }
                }
            }
            
            
        }
        let supplementalAction = UIAlertAction(title: "Supplemental", style: .default) { (action) in
            if self.masterIncome == nil{
                self.askForPrimary()
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

extension CreateBudgetTableViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return componentCountForCustomPicker
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return customPickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return customPickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
//        let indexpath = IndexPath(item: row, section: component)
//        firstSelectedDay = customPickerData[IndexPath]
        switch component{
        case 0:
            let firstDay = customPickerData[row]
            firstSelectedDay = Int(firstDay)
        case 1:
            let secondDay = customPickerData[row]
            secondSelectedDay = Int(secondDay)
        default:
            break
        }
    }
    
}

