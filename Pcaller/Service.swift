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

class Service {
    
    static let shared: Service = Service()

    var prefix = "*43"
    var selectedIndexSegment = SegmentIndex.firstName
    
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
    
    func showCallAction(vc: UIViewController, telephone: String) {
        
        let alert = UIAlertController(title: "Select an action", message: "Please Select an Action", preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Call regular", style: .default, handler: { (_) in
            print(self.dialNumber(number: telephone))
        }))
        
        alert.addAction(UIAlertAction(title: "Call with Private number", style: .destructive, handler: { (_) in
            print(self.dialNumber(number: telephone))
        }))
        
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { (_) in
            print("## User click Dismiss button")
        }))
        
        vc.present(alert, animated: true, completion: {
        })
    }
    
    func dialNumber(number : String) {
        
        if let url = URL(string: "tel://\(prefix)\(number)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
}
