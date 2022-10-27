//
//  Service.swift
//  Pcaller
//
//  Created by Oran Levi on 17/10/2022.
//

import UIKit
import CoreData

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
    static var saveToHistory = true
    
    var historyList = [HistoryData](){
        didSet {
            historyList = historyList.sorted(by: {  $0.time > $1.time })
           }
    }

    static var firstNameHistory = ""
    static var lastNameHistory = ""
    static var telephoneHistory = ""
    
//MARK: - Alert
    
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
            let telephone = telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.dialNumber(number: telephone, prefixNumber: false)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone)
        }))
        
        alert.addAction(UIAlertAction(title: "Call with Private number", style: .destructive, handler: { (_) in
            let telephone = telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.dialNumber(number: telephone, prefixNumber: true)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("## User click Dismiss button")
        }))
        
        vc.present(alert, animated: true, completion: {
        })
    }
    
    func showAlert(vc: UIViewController,title: String, message: String, completion: @escaping () -> Void) {

        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        // Create OK button with action handler
        let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            completion()
        })
        // Create Cancel button with action handlder
        let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
            print("Cancel button tapped")
        }
        //Add OK and Cancel button to an Alert object
        dialogMessage.addAction(ok)
        dialogMessage.addAction(cancel)
        // Present alert message to user
        vc.present(dialogMessage, animated: true, completion: nil)
    }
    
//MARK: - Dialer func
    
    func dialNumber(number : String, prefixNumber: Bool) {
        
           
        
//            let number = number.removeCharacters(from: CharacterSet.decimalDigits.inverted)
        
//        Service.callFromContacts = false
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
    
//MARK: - CoreData
    
    func saveHistoryData(firstName: String, lastName: String, telephone: String){
        print(Service.saveToHistory)
        if Service.saveToHistory == false {
            return
        }
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "HistoryData", in: context)
        let newHistory = HistoryData(entity: entity!, insertInto: context)
     
        let date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let dateString = df.string(from: date)
        print(dateString)
        
        newHistory.firstName = firstName
        newHistory.lastName = lastName
        newHistory.telephone = telephone
        newHistory.time = dateString
        
        do {
            try context.save()
            historyList.append(newHistory)
            print(historyList.count)
        } catch {
            print("## context save error")
        }
    }
    
    func retrieveData() {
        historyList = []
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryData")
            do {
                let results: NSArray = try context.fetch(request) as NSArray
                for result in results {
                    let history = result as! HistoryData
                    historyList.append(history)
                }
            } catch {
                print("## Fetch Failed")
            }
        }
    
    func DeleteAllData(entity: String){

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let DelAllReqVar = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: entity))
        do {
            try managedContext.execute(DelAllReqVar)
        }
        catch {
            print(error)
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
