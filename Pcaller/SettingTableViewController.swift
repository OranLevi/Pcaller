//
//  SettingTableViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 21/10/2022.
//

import UIKit

class SettingTableViewController: UITableViewController {
    
    var service = Service.shared
    
    @IBOutlet weak var prefixText: UITextField!
    @IBOutlet weak var firstNameSwitch: UISwitch!
    @IBOutlet weak var lastNameSwitch: UISwitch!
    @IBOutlet weak var telephoneNameSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupButton()
    }
    
    @IBAction func firstNameSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: firstNameSwitch)
    }
    
    @IBAction func lastNameSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: lastNameSwitch)
    }
    
    @IBAction func telephoneSwitchAction(_ sender: Any) {
        segmentSwitch(switchOn: telephoneNameSwitch)
    }
    
    func segmentSwitch(switchOn: UISwitch) {
        firstNameSwitch.isOn = false
        lastNameSwitch.isOn = false
        telephoneNameSwitch.isOn = false
        switchOn.isOn = true
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



