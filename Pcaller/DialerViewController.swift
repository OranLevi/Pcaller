//
//  ViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 16/10/2022.
//

import UIKit

class DialerViewController: UIViewController {

    @IBOutlet weak var hideMyNumberSwitch: UISwitch!
    @IBOutlet weak var saveToLastSwitch: UISwitch!
    @IBOutlet weak var numberDisplayLabel: UILabel!
    
    var numberDisplay = ""

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func addNumberToDisplay(addNumber: String){
        numberDisplay += addNumber
//        addSpaceToNumber()
        numberDisplayLabel.text = numberDisplay
    }
    
//    func addSpaceToNumber(){
//        if numberDisplay.count == 3 {
//            numberDisplay.insert("-", at: numberDisplay.index(numberDisplay.startIndex, offsetBy: 3))
//
//        }
//
//        if numberDisplay.count == 7 {
//            numberDisplay.insert("-", at: numberDisplay.index(numberDisplay.startIndex, offsetBy: 7))
//
//        }
//
//    }
    
    @IBAction func oneTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "1")
        print(numberDisplay)
    }
    
    @IBAction func twoTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "2")
        print(numberDisplay)
    }
    
    @IBAction func threeTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "3")
        print(numberDisplay)
    }
    
    @IBAction func fourTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "4")
        print(numberDisplay)
    }
    
    @IBAction func fiveTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "5")
        print(numberDisplay)
    }
    
    @IBAction func sixTabButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "6")
        print(numberDisplay)
    }
    
    @IBAction func sevenTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "7")
        print(numberDisplay)
    }
    
    @IBAction func eightTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "8")
        print(numberDisplay)
    }
    
    @IBAction func nineTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "9")
        print(numberDisplay)
    }
    
    @IBAction func zeroTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "0")
        print(numberDisplay)
    }
    
    @IBAction func asteriskTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "*")
        print(numberDisplay)
    }
    
    @IBAction func ladderTapButton(_ sender: Any) {
        addNumberToDisplay(addNumber: "#")
        print(numberDisplay)
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
        
    }
    
}

