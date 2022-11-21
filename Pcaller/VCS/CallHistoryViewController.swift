//
//  CallHistoryViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 22/10/2022.
//

import UIKit
import CoreData

class CallHistoryViewController: UIViewController {
    
    @IBOutlet weak var callHistoryTableView: UITableView!
    
    var service = Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callHistoryTableView.dataSource = self
        callHistoryTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {

        service.retrieveData()
        callHistoryTableView.reloadData()
        
    }
}

extension CallHistoryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return service.historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistory", for: indexPath) as! CallHistoryTableViewCell
        
        let thisHistory: HistoryData
        thisHistory = service.historyList[indexPath.row]
        
        cell.firstAndLastNameLabel.text = "\(thisHistory.firstName) \(thisHistory.lastName)"
        cell.telePhone.text = thisHistory.telephone
        cell.timeDateLabel.text = thisHistory.time
        return cell
    }
}
extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callHistoryTableView.deselectRow(at: indexPath, animated: true)
        let item = service.historyList[indexPath.row]
        service.showCallAction(vc: self, telephone: item.telephone, firstName: item.firstName, lastName: item.lastName)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, success) in
            
            _ = tableView.cellForRow(at: indexPath)! as UITableViewCell
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            _ = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryData")
            context.delete(self.service.historyList[indexPath.row])
            self.service.historyList.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            do {
                try context.save()
            } catch {
                print ("## error")
            }
        }
        let call = UIContextualAction(style: .normal, title: "Call Private") {  (contextualAction, view, success) in
            let item = self.service.historyList[indexPath.row]
            let telephone = item.telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.service.dialNumber(number: telephone, prefixNumber: true, vc: self)
            self.service.setupCallerId(firstName: item.firstName, lastName: item.lastName, telephone: item.telephone)
            success(true)
        }
        
        call.backgroundColor = UIColor.systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [call, delete])
        
        return swipeActions
    }
}
