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
    
    var historyList = [HistoryData]()
    var service = Service.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        callHistoryTableView.dataSource = self
        callHistoryTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        retrieveData()
        callHistoryTableView.reloadData()

    }
   
    
    func saveHistoryData(firstName: String, lastName: String, telephone: String){

        if service.saveToHistory == false {
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
    
}

extension CallHistoryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(historyList.count)
        return historyList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistory", for: indexPath) as! CallHistoryTableViewCell
        
        let thisHistory: HistoryData
        thisHistory = historyList[indexPath.row]
        
        cell.firstAndLastNameLabel.text = "\(thisHistory.firstName) \(thisHistory.lastName)"
        cell.telePhone.text = thisHistory.telephone
        cell.timeDateLabel.text = thisHistory.time
        return cell
    }
}
extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = self.historyList[indexPath.row]
        CallHistoryViewController().saveHistoryData(firstName: item.firstName, lastName: item.lastName, telephone: item.telephone)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
            let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, boolValue) in
                
                _ = tableView.cellForRow(at: indexPath)! as UITableViewCell
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
                _ = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryData")
                context.delete(self.historyList[indexPath.row])
                self.historyList.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
                   do {
                       try context.save()
                   } catch {
                       print ("## error")
                   }
            }
        let call = UIContextualAction(style: .normal, title: "Call Private") {  (contextualAction, view, boolValue) in
            let item = self.historyList[indexPath.row]

        }
      
        call.backgroundColor = UIColor.systemGreen

            let swipeActions = UISwipeActionsConfiguration(actions: [call, delete])
        
            return swipeActions
        }
}
