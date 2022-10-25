//
//  Service.swift
//  Pcaller
//
//  Created by Oran Levi on 17/10/2022.
//

import UIKit

enum SegmentIndex: Int {
    case firstName = 0
    case lastName = 1
    case telephone = 2
}

enum NameAutoSwitchUserDefaults:String{
    case hideMyNumber = "AutoSwitchHideMyNumber"
    case saveToHistory = "AutoSwitchSaveToHistory"
}


class Service {
    
    static let shared: Service = Service()
    
    //* with %2A and # with %23
    var prefix = UserDefaults.standard.string(forKey: "Prefix") ?? "%2331%23"
    var selectedIndexSegment = SegmentIndex.firstName
    var saveToHistory = true

    static var firstNameHistory = ""
    static var lastNameHistory = ""
    static var telephoneHistory = ""
    
    func messageAccess(vc: UIViewController){
        DispatchQueue.main.async {
            
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 300, height: 400))
            label.center = vc.view.center
            label.textAlignment = .center
            label.numberOfLines = 3
            label.text = "You must allow access to contacts to perform fast actions and private speed dialing"
            vc.view.addSubview(label)
            
            let alertController = UIAlertController (title: "Alert", message: "You must allow access to contacts to perform fast actions and private speed dialing", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            vc.present(alertController, animated: true, completion: nil)
        }
    }
    
    func showCallAction(vc: UIViewController, telephone: String, firstName: String, lastName: String) {
        
        let alert = UIAlertController(title: "Select an action", message: "Please Select an Action", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Call regular", style: .default, handler: { (_) in
            self.dialNumber(number: telephone, prefixNumber: false)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone)
        }))
        
        alert.addAction(UIAlertAction(title: "Call with Private number", style: .destructive, handler: { (_) in
            print(self.dialNumber(number: telephone, prefixNumber: true))
            self.dialNumber(number: telephone, prefixNumber: true)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("## User click Dismiss button")
        }))
        
        vc.present(alert, animated: true, completion: {
        })
    }
    
    func dialNumber(number : String, prefixNumber: Bool) {
        
        let number = number.removeCharacters(from: CharacterSet.decimalDigits.inverted)
        prefix = UserDefaults.standard.string(forKey: "Prefix") ?? "%2331%23"
        if prefixNumber == false {
            prefix = ""
        }
        if let url = URL(string: "tel://\(prefix)\(number)"), UIApplication.shared.canOpenURL(url) {
            print(url)
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func textReplaced(text: String, fromHashtag: Bool) -> String{
        if fromHashtag == false {
            let replaced = text.replacingOccurrences(of: "%2A", with: "*")
            let replaced2 = replaced.replacingOccurrences(of: "%23", with: "#")
            return replaced2
        } else {
            let replaced = text.replacingOccurrences(of: "*", with: "%2A")
            let replaced2 = replaced.replacingOccurrences(of: "#", with: "%23")
            return replaced2
        }
    }
    
    func setupCallerId(firstName: String, lastName: String, telephone: String){
        Service.firstNameHistory = firstName
        Service.lastNameHistory = lastName
        Service.telephoneHistory = telephone
    }
}

extension String {

    func removeCharacters(from forbiddenChars: CharacterSet) -> String {
        let passed = self.unicodeScalars.filter { !forbiddenChars.contains($0) }
        return String(String.UnicodeScalarView(passed))
    }

    func removeCharacters(from: String) -> String {
        return removeCharacters(from: CharacterSet(charactersIn: from))
    }
}
