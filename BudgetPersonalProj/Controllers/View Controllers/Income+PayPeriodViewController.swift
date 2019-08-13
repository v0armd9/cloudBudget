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
    
    var masterBudget: MasterBudget?
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
            else {return}
        if timeFrameControl.selectedSegmentIndex == 0 {
            
        } else if timeFrameControl.selectedSegmentIndex == 1 {
            
        } else if timeFrameControl.selectedSegmentIndex == 2 {
            IncomeController.sharedInstance.createMasterIncomeWith(name: name, paydate: datePicker.date, firstSpecificDay: firstSelectedDay, secondSpecificDay: secondSelectedDay, amount: amount, masterBudget: masterBudget) { (income) in
                if let income = income {
                    PayPeriodController.sharedInstance.createPayPeriodsForSpecificDaysIncome(firstDay: self.firstSelectedDay, secondDay: self.secondSelectedDay, startDate: self.datePicker.date, masterIncome: income, masterBudget: masterBudget, completion: { (success)  in
                        if success {
                            
                        }
                    })
                    
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        guard let masterBudget = masterBudget  else {navigationController?.popToRootViewController(animated: true); return}
        MasterBudgetController.sharedInstance.delete(masterBudget: masterBudget) { (success) in
            if success {
                self.navigationController?.popToRootViewController(animated: true)
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
        nameTextField.attributedPlaceholder = NSAttributedString(string: "Name your income...", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
        amountTextField.attributedPlaceholder = NSAttributedString(string: "Enter an amount...", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
        navigationItem.title = masterBudget?.name
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
