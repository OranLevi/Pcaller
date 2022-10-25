//
//  SettingTableViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 21/10/2022.
//

import UIKit
import CoreData

class SettingTableViewController: UITableViewController {
    
    var service = Service.shared
    
    var tapEditingPrefix = false
    var tapSavePrefix = false
    
    @IBOutlet weak var autoHideMyNumberSwitch: UISwitch!
    @IBOutlet weak var autoSaveToHistorySwitch: UISwitch!
    @IBOutlet weak var prefixText: UITextField!
    @IBOutlet weak var firstNameSwitch: UISwitch!
    @IBOutlet weak var lastNameSwitch: UISwitch!
    @IBOutlet weak var telephoneNameSwitch: UISwitch!
    @IBOutlet weak var editButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetting()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setupSwitches()
    }
    
    @IBAction func firstNameSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: firstNameSwitch)
        UserDefaults.standard.set(SegmentIndex.firstName.rawValue, forKey: "sortContacts")
    }
    
    @IBAction func lastNameSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: lastNameSwitch)
        UserDefaults.standard.set(SegmentIndex.lastName.rawValue, forKey: "sortContacts")
    }
    
    @IBAction func telephoneSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: telephoneNameSwitch)
        UserDefaults.standard.set(SegmentIndex.telephone.rawValue, forKey: "sortContacts")
    }
    
    func segmentSwitch(switchOn: UISwitch) {
        firstNameSwitch.isOn = false
        lastNameSwitch.isOn = false
        telephoneNameSwitch.isOn = false
        switchOn.isOn = true
    }
    
    func setupSwitches(){
        if UserDefaults.standard.integer(forKey: "sortContacts") == 0 {
            segmentSwitch(switchOn: firstNameSwitch)
        } else if UserDefaults.standard.integer(forKey: "sortContacts") == 1 {
            segmentSwitch(switchOn: lastNameSwitch)
        } else if UserDefaults.standard.integer(forKey: "sortContacts") == 2 {
            segmentSwitch(switchOn: telephoneNameSwitch)
        }
        
        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue) == nil  {
            autoHideMyNumberSwitch.isOn = true
        } else {
            autoHideMyNumberSwitch.isOn = false
        }

        if UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == "isOn" || UserDefaults.standard.string(forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue) == nil  {
            autoSaveToHistorySwitch.isOn = true
        } else {
            autoSaveToHistorySwitch.isOn = false
        }
        
        
    }
    
    @IBAction func editButton(_ sender: Any) {
        tapEditingPrefix = true
        if tapSavePrefix == true {
            print("## SAVE PREFIX")
            let replaced = service.textReplaced(text: prefixText.text ?? "", fromHashtag: true)
            UserDefaults.standard.set(replaced, forKey: "Prefix")
            editButton.setTitle("Edit", for: .normal)
            prefixText.isEnabled = false
            tapSavePrefix = false
            tapEditingPrefix = false
        
        }

        if tapEditingPrefix {
            prefixText.isEnabled = true
            editButton.setTitle("Save", for: .normal)
            tapSavePrefix = true
        }
    }
 
    @IBAction func SwitchAutoHideMyNumber(_ sender: Any) {
        if autoHideMyNumberSwitch.isOn {
            UserDefaults.standard.set("isOn", forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue)
        } else {
            UserDefaults.standard.set("isOff", forKey: NameAutoSwitchUserDefaults.hideMyNumber.rawValue)
        }
    }
    
    @IBAction func SwitchAutoSaveToHistory(_ sender: Any) {
        if autoSaveToHistorySwitch.isOn {
            UserDefaults.standard.set("isOn", forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue)
        } else {
            UserDefaults.standard.set("isOff", forKey: NameAutoSwitchUserDefaults.saveToHistory.rawValue)
        }
    }
    
    
    func startupSetting(){
        setupButton()
        prefixText.text = service.textReplaced(text: service.prefix, fromHashtag: false)
    }
    
    @IBAction func resetSettingButton(_ sender: Any) {
        
        service.showAlert(vc: self, title: "Confirm" , message: "Are you sure you want to reset Setting?") {
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
            self.startupSetting()
            self.autoSaveToHistorySwitch.isOn = true
            self.autoHideMyNumberSwitch.isOn = true
            
        }

        
    }
    
    
    @IBAction func clearAllButton(_ sender: Any) {
//        let dialogMessage = UIAlertController(title: "Confirm", message: "Are you sure you want to delete all Data (All Call History and App Setting)?", preferredStyle: .alert)
//        // Create OK button with action handler
//        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
//
//
//            if let appDomain = Bundle.main.bundleIdentifier {
//                UserDefaults.standard.removePersistentDomain(forName: appDomain)
//            }
//            self.startupSetting()
//            self.service.DeleteAllData(entity: "HistoryData")
//
//
//
//        })
//        // Create Cancel button with action handlder
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
//            print("Cancel button tapped")
//        }
//        //Add OK and Cancel button to an Alert object
//        dialogMessage.addAction(ok)
//        dialogMessage.addAction(cancel)
//        // Present alert message to user
//        self.present(dialogMessage, animated: true, completion: nil)
        service.showAlert(vc: self, title: "Confirm" , message: "Are you sure you want to delete all Data (All Call History and App Setting)?") {
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
            self.startupSetting()
            self.service.DeleteAllData(entity: "HistoryData")
        }
    }
    
    
    func setupButton(){
        
        if service.selectedIndexSegment == SegmentIndex.firstName{
            segmentSwitch(switchOn: firstNameSwitch)
        } else if service.selectedIndexSegment == SegmentIndex.lastName{
            segmentSwitch(switchOn: lastNameSwitch)
        } else if service.selectedIndexSegment == SegmentIndex.telephone{
            segmentSwitch(switchOn: telephoneNameSwitch)
        }
    }
    
    
}



