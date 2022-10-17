//
//  ContactsViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 16/10/2022.
//

import UIKit
import Contacts

class ContactsViewController: UIViewController {
    
    @IBOutlet weak var contactsTableView: UITableView!
    
    struct FetchedContact {
        var firstName: String
        var lastName: String
        var telephone: String
    }
    
    var contacts = [FetchedContact]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        contactsTableView.dataSource = self
        contactsTableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        fetchContacts()
    }
    
    
    private func fetchContacts() {
        // 1.
        let store = CNContactStore()
        store.requestAccess(for: .contacts) { (granted, error) in
            if let error = error {
                print("failed to request access", error)
                self.messageAccess()
                return
            }
            if granted {
                // 2.
                let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
                let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
                do {
                    // 3.
                   
                    try store.enumerateContacts(with: request, usingBlock: { (contact, stopPointer) in
                        self.contacts.append(FetchedContact(firstName: contact.givenName, lastName: contact.familyName, telephone: contact.phoneNumbers.first?.value.stringValue ?? ""))
                    })
                    DispatchQueue.main.async {
                        self.contactsTableView.reloadData()
                    }
                } catch let error {
                    print("Failed to enumerate contact", error)
                }
            } else {
                print("access denied")
            }
        }
    }
    
    func messageAccess(){
        DispatchQueue.main.async {
            let alertController = UIAlertController (title: "Title", message: "Go to Settings?", preferredStyle: .alert)
            
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        print(contacts.count)
        return contacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        

        let cell = tableView.dequeueReusableCell(withIdentifier: "Contacts", for: indexPath) as! ContactsTableViewCell
        
        let item = contacts[indexPath.row]
        cell.firstNameLabel.text = item.firstName
        cell.lastNameLabel.text = item.lastName
        cell.telephoneLabel.text = item.telephone
        
        return cell
    }
}

extension ContactsViewController: UITableViewDelegate{
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let callAction = UIContextualAction(style: .destructive, title: "Call Private", handler: { (action, view, success) in
          
            
            
            
      })
        callAction.backgroundColor = .systemGreen
//        callAction.image = UIImage(systemName: "phone.circle")
    
      return UISwipeActionsConfiguration(actions: [callAction])
    }
}
