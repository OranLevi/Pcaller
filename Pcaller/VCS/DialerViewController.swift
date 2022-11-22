//
//  ViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 16/10/2022.
//

import UIKit
import StoreKit
import KeychainSwift

class DialerViewController: UIViewController {
    
    @IBOutlet weak var hideMyNumberSwitch: UISwitch!
    @IBOutlet weak var saveToHistorySwitch: UISwitch!
    @IBOutlet weak var numberDisplayLabel: UILabel!
    @IBOutlet weak var oneButton: UIButton!
    @IBOutlet weak var twoButton: UIButton!
    @IBOutlet weak var threeButton: UIButton!
    @IBOutlet weak var fourButton: UIButton!
    @IBOutlet weak var fiveButton: UIButton!
    @IBOutlet weak var sixButton: UIButton!
    @IBOutlet weak var sevenButton: UIButton!
    @IBOutlet weak var eightButton: UIButton!
    @IBOutlet weak var nineButton: UIButton!
    @IBOutlet weak var zeroButton: UIButton!
    @IBOutlet weak var asteriskButton: UIButton!
    @IBOutlet weak var laderButton: UIButton!
    @IBOutlet weak var trialVersionLabel: UILabel!
    
    var numberDisplay = ""
    var service = Service.shared
    let keychain = KeychainSwift()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadiusButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupLabel()
        setupSwitches()
    }
    
    override func viewDidLayoutSubviews() {
        setupLabel()
        print("## Update Calls left Label")
    }
    
    func setupLabel() {
        Service.numberAttempts = 0
        if (keychain.get("userBuy") != nil) == true {
            trialVersionLabel.isHidden = true
            return
        }
        trialVersionLabel.text = """
Trial Version \(Service.numberAttempts ?? 0) Call left
"""
    }
    
    func setupSwitches(){
        
        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == nil {
            hideMyNumberSwitch.isOn = true
        } else {
            hideMyNumberSwitch.isOn = false
        }
        
        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == nil {
            saveToHistorySwitch.isOn = true
            Service.saveToHistory = true
        } else {
            saveToHistorySwitch.isOn = false
            Service.saveToHistory = false
        }
    }
    
    func setupCornerRadiusButton(){
        let cornerRadiusButton = 9
        oneButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        twoButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        threeButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        fourButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        fiveButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        sixButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        sevenButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        eightButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        nineButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        zeroButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        asteriskButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
        laderButton.layer.cornerRadius = CGFloat(cornerRadiusButton)
    }
    
    func addNumberToDisplay(addNumber: String){
        numberDisplay += addNumber
        numberDisplayLabel.text = numberDisplay
    }
    
    @IBAction func oneTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "1")
    }
    
    @IBAction func twoTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "2")
    }
    
    @IBAction func threeTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "3")
    }
    
    @IBAction func fourTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "4")
    }
    
    @IBAction func fiveTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "5")
    }
    
    @IBAction func sixTabButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "6")
    }
    
    @IBAction func sevenTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "7")
    }
    
    @IBAction func eightTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "8")
    }
    
    @IBAction func nineTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "9")
    }
    
    @IBAction func zeroTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "0")
    }
    
    @IBAction func asteriskTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "*")
    }
    
    @IBAction func ladderTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "#")
    }
    
    @IBAction func deleteTapButton(_ sender: Any) {
        
        if numberDisplay != "" {
            numberDisplay.removeLast()
            numberDisplayLabel.text = numberDisplay
        } else {
            print("## Number Display empty")
        }
        
        if numberDisplay.last == "-"{
            numberDisplay.removeLast()
            numberDisplayLabel.text = numberDisplay
        }
        print(numberDisplay)
    }
    
    @IBAction func saveToHistorySwitch(_ sender: Any) {
        if saveToHistorySwitch.isOn {
            Service.saveToHistory = true
            print(Service.saveToHistory)
        } else {
            Service.saveToHistory = false
            print(Service.saveToHistory)
        }
    }
    
    @IBAction func dialerTabButton(_ sender: Any) {
        if numberDisplayLabel.text!.isEmpty  {
            service.showAlert(vc: self, title: "Error", message: "You are not enter valid number", textTitleOk: "OK", cancelButton: false, style: .default) {
                print("## Valid number")
            }
            return
        }
        if self.hideMyNumberSwitch.isOn {
            self.service.dialNumber(number: self.numberDisplay, prefixNumber: true, vc: self)
            self.service.setupCallerId(firstName: "", lastName: "", telephone: self.numberDisplayLabel.text ?? "??")
        }
        else {
            self.service.dialNumber(number: self.numberDisplay, prefixNumber: false, vc: self)
            self.service.setupCallerId(firstName: "", lastName: "", telephone: self.numberDisplayLabel.text ?? "??")
        }
    }
}



