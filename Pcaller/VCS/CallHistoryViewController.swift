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
    @IBOutlet weak var emptyLabel: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var service = Service.shared
    var filteredData = [HistoryData]()
    
    var isSearching = false
    
    var realArray: [HistoryData]{
        if isSearching {
            return filteredData
        } else {
            return service.historyList
        }
    }
    
    var firstAndLastName: [HistoryData] {
        return service.historyList
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        callHistoryTableView.dataSource = self
        callHistoryTableView.delegate = self
        searchBar.delegate = self
        setupView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        service.retrieveData()
        callHistoryTableView.reloadData()
        checkIfHistoryEmpty()
        service.startTimerAppStoreRating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        service.timerToShowAppStoreRating?.invalidate()
        service.timerToShowAppStoreRating = nil
    }
    
    func setupView() {
        searchBar.backgroundImage = UIImage()
        
    }
    func checkIfHistoryEmpty(){
        if service.historyList.count == 0 {
            emptyLabel.isHidden = false
        } else {
            emptyLabel.isHidden = true
            
        }
    }
    
}

extension CallHistoryViewController: UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CallHistory", for: indexPath) as! CallHistoryTableViewCell
        
        let thisHistory: HistoryData
        thisHistory = realArray[indexPath.row]
        cell.firstAndLastNameLabel.text = "\(thisHistory.firstName) \(thisHistory.lastName)"
        cell.telePhone.text = thisHistory.telephone
        cell.timeDateLabel.text = thisHistory.time
        
        if thisHistory.callHidden == true {
            cell.callHiddenLabel.text = "Hidden"
            cell.callHiddenLabel.textColor = .systemRed
        } else if thisHistory.callHidden == false {
            cell.callHiddenLabel.text = "Normally"
            cell.callHiddenLabel.textColor = .black
        }else if thisHistory.callHidden == nil{
            cell.callHiddenLabel.text = ""
            cell.callHiddenLabel.textColor = .black
        }
        
        return cell
    }
}

extension CallHistoryViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        callHistoryTableView.deselectRow(at: indexPath, animated: true)
        let item = realArray[indexPath.row]
        service.showCallAction(vc: self, telephone: item.telephone, firstName: item.firstName, lastName: item.lastName)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") {  (contextualAction, view, success) in
            
            _ = tableView.cellForRow(at: indexPath)! as UITableViewCell
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context: NSManagedObjectContext = appDelegate.persistentContainer.viewContext
            _ = NSFetchRequest<NSFetchRequestResult>(entityName: "HistoryData")
            context.delete(self.realArray[indexPath.row])
            if self.isSearching {
                self.filteredData.remove(at: indexPath.row)
                self.service.retrieveData()
            } else {
                self.service.historyList.remove(at: indexPath.row)
            }
            tableView.deleteRows(at: [indexPath], with: .fade)
            do {
                try context.save()
            } catch {
                print ("## error")
            }
            self.checkIfHistoryEmpty()
        }
        let call = UIContextualAction(style: .normal, title: "Call Private") {  (contextualAction, view, success) in
            let item = self.realArray[indexPath.row]
            let telephone = item.telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.service.dialNumber(number: telephone, prefixNumber: true, vc: self)
            self.service.setupCallerId(firstName: item.firstName, lastName: item.lastName, telephone: item.telephone, callHidden: true)
            success(true)
        }
        
        call.backgroundColor = UIColor.systemGreen
        
        let swipeActions = UISwipeActionsConfiguration(actions: [call, delete])
        
        return swipeActions
    }
}

extension CallHistoryViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        if searchBar.text == "" {
            isSearching = false
        } else {
            isSearching = true
            filteredData = service.historyList.filter {
                $0.telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted).containsCharactersInSequence(
                    searchText, options: [.caseInsensitive, .diacriticInsensitive,]).result ||
                 $0.firstAndLastNameCallHistory.containsCharactersInSequence(
                    searchText, options: [.caseInsensitive, .diacriticInsensitive,]).result ||
                $0.lastAndFirstCallHistory.containsCharactersInSequence(
                   searchText, options: [.caseInsensitive, .diacriticInsensitive,]).result
            }
        }
        callHistoryTableView.reloadData()
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        isSearching = false
        callHistoryTableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = false
        searchBar.resignFirstResponder()
    }
}
