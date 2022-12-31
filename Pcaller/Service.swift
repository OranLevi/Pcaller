//
//  Service.swift
//  Pcaller
//
//  Created by Oran Levi on 17/10/2022.
//

import UIKit
import CoreData
import KeychainSwift
import StoreKit

enum SegmentIndex: Int {
    case firstName = 0
    case lastName = 1
    case telephone = 2
}

enum SwitchesUserDefaults:String{
    case hideMyNumber = "AutoSwitchHideMyNumber"
    case saveToHistory = "AutoSwitchSaveToHistory"
}

class Service {
    
    static let shared: Service = Service()
    static var enableInAppPurchase = false
    
    // Appstore rating
    var timerToShowAppStoreRating : Timer?
    var userDefaultsAppRatingShowing =  UserDefaults.standard.bool(forKey: "AppRatingShowing")
    
    //* with %2A and # with %23
    var prefix = UserDefaults.standard.string(forKey: "Prefix") ?? "%2331%23"
    var selectedIndexSegment = SegmentIndex.firstName
    static var numberAttempts: Int? {
        didSet {
            switch Service().keychain.get("checkIfTrial") {
            case "2attempts": return numberAttempts = 2
            case "1attempts": return numberAttempts = 1
            case "0attempts": return numberAttempts = 0
            default: return numberAttempts = 3
            }
        }
    }
    
    var historyList = [HistoryData](){
        didSet {
            historyList = historyList.sorted(by: {  $0.time > $1.time })
        }
    }
    
    static var dialerSaveToHistory:Bool?
    
    let keychain = KeychainSwift()
    
    static var firstNameHistory = ""
    static var lastNameHistory = ""
    static var telephoneHistory = ""
    static var callHiddenHistory:NSNumber?
    
    
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
        alert.addAction(UIAlertAction(title: "Call normally", style: .default, handler: { (_) in
            let telephone = telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.dialNumber(number: telephone, prefixNumber: false, vc: vc)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone, callHidden: false)
        }))
        
        alert.addAction(UIAlertAction(title: "Call Private number", style: .destructive, handler: { (_) in
            let telephone = telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.dialNumber(number: telephone, prefixNumber: true, vc: vc)
            self.setupCallerId(firstName: firstName, lastName: lastName, telephone: telephone, callHidden: true)
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("## User click Dismiss button")
        }))
        
        vc.present(alert, animated: true, completion: {
        })
    }
    
    func showAlert(vc: UIViewController,title: String, message: String,textTitleOk: String, cancelButton: Bool, style: UIAlertAction.Style, completion: @escaping () -> Void) {
        
        let dialogMessage = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let ok = UIAlertAction(title: textTitleOk, style: style, handler: { (action) -> Void in
            completion()
        })
        if cancelButton == true {
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action) -> Void in
                print("Cancel button tapped")
            }
            dialogMessage.addAction(cancel)
        }
        
        
        dialogMessage.addAction(ok)
        
        vc.present(dialogMessage, animated: true, completion: nil)
    }
    
    func isTrial(){
        if  keychain.get("checkIfTrial") == nil{
            keychain.set("3attempts", forKey: "checkIfTrial")
        }
        
        switch keychain.get("checkIfTrial") {
        case "3attempts": keychain.set("2attempts", forKey: "checkIfTrial")
        case "2attempts": keychain.set("1attempts", forKey: "checkIfTrial")
        case "1attempts": keychain.set("0attempts", forKey: "checkIfTrial")
        default:
            break
        }
    }
    
    
    //MARK: - Dialer func
    
    func dialNumber(number : String, prefixNumber: Bool, vc: UIViewController) {
        
        prefix = UserDefaults.standard.string(forKey: "Prefix") ?? "%2331%23"
        
        if prefixNumber == false {
            prefix = ""
        }
        
        if let url = URL(string: "tel://\(prefix)\(number)"), UIApplication.shared.canOpenURL(url) {
            print("## user dial : \(url)")
            if Service.enableInAppPurchase == true {
                if keychain.get("userBuy") == nil {
                    
                    if keychain.get("checkIfTrial") == "0attempts" {
                        print("## end trial")
                        showAlert(vc: vc, title: "Trial Version", message: "Trial version has ended please buy the full version", textTitleOk: "OK", cancelButton: false, style: .default) {
                            print("## Trial version end Click Ok")
                        }
                        return
                    }
                }
            }
            
            UIApplication.shared.open(url)
        }
        
    }
    
    func firstTimeLoad() {
        if UserDefaults.standard.string(forKey: SwitchesUserDefaults.saveToHistory.rawValue) == nil {
            UserDefaults.standard.set("isOn", forKey: SwitchesUserDefaults.saveToHistory.rawValue)
        }
    }
    
    //MARK: - CoreData
    
    func saveHistoryData(firstName: String, lastName: String, telephone: String, callHidden: NSNumber?){
        let userDefaultsSaveToHistory = UserDefaults.standard.string(forKey: SwitchesUserDefaults.saveToHistory.rawValue)
        let dialerHistory = Service.dialerSaveToHistory
        
        if userDefaultsSaveToHistory == "isOff" && dialerHistory == nil {
            return
        }
        
        if userDefaultsSaveToHistory == "isOff" && dialerHistory == false {
            return
        }
        
        if userDefaultsSaveToHistory == "isOn" && dialerHistory == false {
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
        newHistory.callHidden = callHidden
        
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
    
    func deleteAllData(entity: String){
        
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
    
    func setupCallerId(firstName: String, lastName: String, telephone: String, callHidden: NSNumber?){
        Service.firstNameHistory = firstName
        Service.lastNameHistory = lastName
        Service.telephoneHistory = telephone
        Service.callHiddenHistory = callHidden
    }
    
    //MARK: - AppStore Rating
    
    func startTimerAppStoreRating() {
        guard userDefaultsAppRatingShowing == false else { return }
        guard historyList.count >= 4 else { return }
        guard timerToShowAppStoreRating == nil else { return }
        
        timerToShowAppStoreRating =  Timer.scheduledTimer(
            timeInterval: TimeInterval(2),
            target      : self,
            selector    : #selector(appStoreRating),
            userInfo    : nil,
            repeats     : false)
    }
    
    @objc func appStoreRating() {
        print("## Start AppStore Rating")
        
        var rootViewController = UIApplication.shared.windows.first?.rootViewController
        
        if let navigationController = rootViewController as? UINavigationController {
            rootViewController = navigationController.viewControllers.first
        }
        if let tabBarController = rootViewController as? UITabBarController {
            rootViewController = tabBarController.selectedViewController
        }
        
        let alert = UIAlertController(title: "Feedback", message: "Are you enjoying the app?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes, i love it!", style: .default, handler: { (_) in
            print("## Yes, i love it!")
            
            if #available(iOS 14.0, *) {
                if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
                    SKStoreReviewController.requestReview(in: scene)
                }
            }
        }))
        
        alert.addAction(UIAlertAction(title: "No, I did not like!", style: .default, handler: { (_) in
            print("## No, I did not like!")
            
            ContactUsViewController.urlWeb = URL(string: WebViewUrls.ratingApp.rawValue)!
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let secondViewController = storyboard.instantiateViewController(withIdentifier: "ContactUsNav") as! UINavigationController
                rootViewController?.present(secondViewController, animated: true, completion: nil)

        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .destructive, handler: { (_) in
            print("## Dismiss")
        }))
        rootViewController?.present(alert, animated: true, completion: nil)
        
        UserDefaults.standard.set(true, forKey: "AppRatingShowing")
        self.userDefaultsAppRatingShowing = true
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

extension StringProtocol {
    func containsCharactersInSequence<S: StringProtocol>(
        _ string: S,
        options: String.CompareOptions = []
    ) -> (result: Bool, ranges: [Range<Index>]) {
        var found = 0
        var startIndex = self.startIndex
        var index = string.startIndex
        var ranges: [Range<Index>] = []
        while index < string.endIndex,
            let range = self[startIndex...]
                .range(
                    of: string[index...index],
                    options: options
                ) {
            ranges.append(range)
            startIndex = range.upperBound
            string.formIndex(after: &index)
            found += 1
        }
        return (found == string.count, ranges)
    }
}
