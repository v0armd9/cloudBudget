//
//  NewBudgetViewController.swift
//  BudgetPersonalProj
//
//  Created by Darin Armstrong on 8/12/19.
//  Copyright © 2019 Darin Marcus Armstrong. All rights reserved.
//

import UIKit

class NewBudgetViewController: UIViewController, CAAnimationDelegate, UITextFieldDelegate {

    @IBOutlet weak var createButton: UIButton!
    @IBOutlet weak var budgetNameTextField: UITextField!
    
    var newBudget: MasterBudget?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        createGradientView()
        budgetNameTextField.delegate = self
        createButton.layer.cornerRadius = createButton.frame.height/2
        createButton.layer.borderWidth = 0.5
        createButton.layer.borderColor = UIColor.white.cgColor
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientView()
    }
    
    @IBAction func nextButtonTapped(_ sender: UIButton) {
        guard let name = budgetNameTextField.text, name != ""
            else {presentNoNameAlert(); return}
        self.createButton.setTitle("Generating Budget", for: .normal)
        self.createButton.isEnabled = false
        
        MasterBudgetController.sharedInstance.createBudgetWith(name: name) { (masterBudget) in
            if let masterBudget = masterBudget {
                self.newBudget = masterBudget
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "toIncomeView", sender: sender)
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIBarButtonItem) {
        navigationController?.popToRootViewController(animated: true)
    }
    
    
    let gradient = CAGradientLayer()
    var gradientSet = [[CGColor]]()
    var currentGradient: Int = 0
    
    let color1 = #colorLiteral(red: 0.1294117647, green: 0.1294117647, blue: 0.1294117647, alpha: 1).cgColor
    let color2 = #colorLiteral(red: 0.1803921569, green: 0.2352941176, blue: 0.231372549, alpha: 1).cgColor
    let color3 = #colorLiteral(red: 0.631372549, green: 0.9725490196, blue: 0.8039215686, alpha: 1).cgColor
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return textField.endEditing(false)
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.placeholder = ""
    }
    
    func createGradientView() {
        gradientSet.append([color1, color2])
        gradientSet.append([color2, color3])
        gradientSet.append([color3, color1])
        
        gradient.frame = self.view.bounds
        gradient.colors = gradientSet[currentGradient]
        gradient.startPoint = CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 1)
        gradient.drawsAsynchronously = true
        self.view.layer.insertSublayer(gradient, at: 0)
        animateGradient()
    }
    
    func animateGradient() {
        if currentGradient < gradientSet.count - 1 {
            currentGradient += 1
        } else {
            currentGradient = 0
        }
        
        let gradientChangeAnimation = CABasicAnimation(keyPath: "colors")
        gradientChangeAnimation.duration = 5.0
        gradientChangeAnimation.toValue = gradientSet[currentGradient]
        gradientChangeAnimation.fillMode = CAMediaTimingFillMode.forwards
        gradientChangeAnimation.isRemovedOnCompletion = false
        gradientChangeAnimation.delegate = self
        gradient.add(gradientChangeAnimation, forKey: "gradientChangeAnimation")
        
    }
    func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        if flag {
            gradient.colors = gradientSet[currentGradient]
            animateGradient()
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toIncomeView" {
            guard let destinationVC = segue.destination as? Income_PayPeriodViewController,
            let masterBudget = newBudget
            else {return}
            destinationVC.masterBudget = masterBudget
        }
    }
}

extension NewBudgetViewController {
    func presentNoNameAlert() {
        let title = NSAttributedString(string: "Please enter a name", attributes: [NSAttributedString.Key.foregroundColor: UIColor(named: "Mint")!])
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
