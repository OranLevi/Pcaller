//
//  ContactsViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 16/10/2022.
//

import UIKit
import Contacts

struct FetchedContact {
    var firstName: String
    var lastName: String
    var telephone: String
}

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var segmentFilter: UISegmentedControl!
    
    var accessContacts = false
    var isSearching = false
    var isSegmentedControl = false
    
    var contacts = [FetchedContact]()
    var filteredData = [FetchedContact]()
    var service = Service.shared
    
    var realArray: [FetchedContact] {
        if isSearching {
            return filteredData
        } else if isSegmentedControl {
            return filteredData
        } else {
            return contacts
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
        searchBar.delegate = self
        segmentFilter.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "sortContacts")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        segmentFilter.selectedSegmentIndex = UserDefaults.standard.integer(forKey: "sortContacts")
        if !(accessContacts){
            fetchContacts()
        }
    }
    
    @IBAction func segmentedControl(_ sender: UISegmentedControl) {
        isSegmentedControl = true
        switch segmentFilter.selectedSegmentIndex {
        case 0:
            filteredData = contacts.sorted { $0.firstName.lowercased() < $1.firstName.lowercased() }
        case 1:
            filteredData = contacts.sorted { $0.lastName.lowercased() < $1.lastName.lowercased() }
        case 2:
            filteredData = contacts.sorted { $0.telephone.lowercased() < $1.telephone.lowercased() }
        default:
            print("##")
        }
        contactsTableView.reloadData()
    }
    
    private func fetchContacts() {
        
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("## Failed to request access", error)
                self.service.messageAccess(vc: self)
                return
            }
            DispatchQueue.global(qos: .default).async {
                if granted {
                    
                    self.accessContacts = true
                    let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                    let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                    do {
                        try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                            
                            self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                        })
                        DispatchQueue.main.async {
                            self.contacts = self.contacts.sorted { $0.firstName.lowercased() < $1.firstName.lowercased() }
                            self.contactsTableView.reloadData()
                        }
                    } catch let error {
                        print("## Failed to enumerate contact", error)
                    }
                } else {
                    print("## Access denied")
                }
            }
        }
    }
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return realArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts", for: indexPath) as! ContactsTableViewCell
        
        let item = realArray[indexPath.row]
        cell.firstNameLabel.text = item.firstName
        cell.lastNameLabel.text = item.lastName
        cell.telephoneLabel.text = item.telephone
        
        return cell
    }
}

extension ContactsViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let item = realArray[indexPath.row]
        let callAction = UIContextualAction(style: .normal, title: "Call Private", handler: { (action, view, success) in
            let telephone = item.telephone.removeCharacters(from: CharacterSet.decimalDigits.inverted)
            self.service.dialNumber(number: telephone, prefixNumber: true)
            self.service.setupCallerId(firstName: item.firstName, lastName: item.lastName, telephone: item.telephone)
            success(true)
        })
        
        callAction.backgroundColor = .systemGreen
        let configuration = UISwipeActionsConfiguration(actions: [callAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        contactsTableView.deselectRow(at: indexPath, animated: true)
        let item = realArray[indexPath.row]
        service.showCallAction(vc: self, telephone: item.telephone, firstName: item.firstName, lastName: item.lastName)
    }
}

extension ContactsViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == "" {
            isSearching = false
            contactsTableView.reloadData()
        } else {
            isSearching = true
            filteredData = contacts.filter {name in
                return   name.firstName.contains(searchText.lowercased()) || name.lastName.contains(searchText.lowercased()) ||  name.telephone.contains(searchText.lowercased())
            }
            contactsTableView.reloadData()
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.showsCancelButton = true
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = nil
        searchBar.showsCancelButton = false
        searchBar.endEditing(true)
        isSearching = false
        contactsTableView.reloadData()
    }
}

