//
//  SettingTableViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 21/10/2022.
//

import UIKit

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
    
    @IBAction func resetSettingButton(_ sender: Any) {
        if let appDomain = Bundle.main.bundleIdentifier {
       UserDefaults.standard.removePersistentDomain(forName: appDomain)
        }
        startupSetting()
    }
    
    func startupSetting(){
        setupButton()
        prefixText.text = service.textReplaced(text: service.prefix, fromHashtag: false)
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



