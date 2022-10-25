//
//  ViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 16/10/2022.
//

import UIKit

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
    
    var numberDisplay = ""
    var service = Service.shared
   
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCornerRadiusButton()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSwitches()
    }
    
    func setupSwitches(){
        
        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == nil {
            hideMyNumberSwitch.isOn = true
        } else {
            hideMyNumberSwitch.isOn = false
        }
        
        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == nil {
            saveToHistorySwitch.isOn = true
        } else {
            saveToHistorySwitch.isOn = false
            service.saveToHistory = false
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
    
    @IBAction func dialerTabButton(_ sender: Any) {
        if hideMyNumberSwitch.isOn {
            service.dialNumber(number: numberDisplay, prefixNumber: true)
            self.service.setupCallerId(firstName: "", lastName: "", telephone: numberDisplayLabel.text ?? "??")
        }
        else {
            service.dialNumber(number: numberDisplay, prefixNumber: false)
            self.service.setupCallerId(firstName: "", lastName: "", telephone: numberDisplayLabel.text ?? "??")
        }
    }
}



