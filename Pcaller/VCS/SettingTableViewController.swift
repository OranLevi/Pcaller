//
//  SettingTableViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 21/10/2022.
//

import UIKit
import CoreData
import KeychainSwift

class SettingTableViewController: UITableViewController {
    
    var service = Service.shared
    
    var tapEditingPrefix = false
    var tapSavePrefix = false
    let keychain = KeychainSwift()

    @IBOutlet weak var autoHideMyNumberSwitch: UISwitch!
    @IBOutlet weak var autoSaveToHistorySwitch: UISwitch!
    @IBOutlet weak var prefixText: UITextField!
    @IBOutlet weak var firstNameSwitch: UISwitch!
    @IBOutlet weak var lastNameSwitch: UISwitch!
    @IBOutlet weak var telephoneNameSwitch: UISwitch!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var buyUnlimitedCallsButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        startupSetting()
        setupButton()
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
        
        service.showAlert(vc: self, title: "Confirm" , message: "Are you sure you want to reset Setting?", textTitleOk: "OK", cancelButton: true, style: .default) {
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
            self.startupSetting()
            self.setupButton()
            self.autoSaveToHistorySwitch.isOn = true
            self.autoHideMyNumberSwitch.isOn = true
            self.prefixText.text = "#31#"
        }
    }
    
    @IBAction func clearAllButton(_ sender: Any) {
        service.showAlert(vc: self, title: "Confirm" , message: "Are you sure you want to delete all Data (All Call History and App Setting)?", textTitleOk: "OK", cancelButton: true, style: .default) {
            if let appDomain = Bundle.main.bundleIdentifier {
                UserDefaults.standard.removePersistentDomain(forName: appDomain)
            }
            self.startupSetting()
            self.setupButton()
            self.service.deleteAllData(entity: "HistoryData")
            self.autoSaveToHistorySwitch.isOn = true
            self.autoHideMyNumberSwitch.isOn = true
            self.prefixText.text = "#31#"
        }
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
    
    func startupSetting() {
        setupButton()
        prefixText.text = service.textReplaced(text: UserDefaults.standard.string(forKey: "Prefix") ?? "%2331%23", fromHashtag: false)
    }
    
    func setupButton() {
    
        if Service.enableInAppPurchase == true {
            if #available(iOS 16.0, *) {
                buyUnlimitedCallsButton.isHidden = false
            } else {
                buyUnlimitedCallsButton.isEnabled = false
                buyUnlimitedCallsButton.tintColor = UIColor.clear
            }
        } else {
            if #available(iOS 16.0, *) {
                buyUnlimitedCallsButton.isHidden = true
            } else {
                buyUnlimitedCallsButton.isEnabled = false
                buyUnlimitedCallsButton.tintColor = UIColor.clear
            }
        }
        
        if (keychain.get("userBuy") != nil) == true {
            buyUnlimitedCallsButton.isEnabled = false
            buyUnlimitedCallsButton.title = "Purchased App"
        }
        
        
        if service.selectedIndexSegment == SegmentIndex.firstName{
            segmentSwitch(switchOn: firstNameSwitch)
        } else if service.selectedIndexSegment == SegmentIndex.lastName{
            segmentSwitch(switchOn: lastNameSwitch)
        } else if service.selectedIndexSegment == SegmentIndex.telephone{
            segmentSwitch(switchOn: telephoneNameSwitch)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
