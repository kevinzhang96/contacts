//
//  CTTableViewController.swift
//  Community
//
//  Created by Kevin Zhang on 12/22/17.
//

import Contacts
import UIKit

class CTTableViewController: UITableViewController {

    var contacts: [CNContact]! = nil

    func retrieveContacts() {
        let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey, CNContactFamilyNameKey] as [CNKeyDescriptor]
        let containerId = CNContactStore().defaultContainerIdentifier()
        let predicate = CNContact.predicateForContactsInContainer(withIdentifier: containerId)
        contacts = try! CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
        contacts.sort { (a, b) -> Bool in
            return (a.givenName + " " + a.familyName) < (b.givenName + " " + b.familyName)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.retrieveContacts()
        super.viewWillAppear(animated)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Reload", style: .done, target: self, action: #selector(self.reload))
    }
    
    @objc
    func reload() {
        self.retrieveContacts()
        self.tableView.reloadData()
    }
    
    @objc
    func deleteContact(sender: UITapGestureRecognizer) {
        for contact in contacts {
            if contact.hashValue == sender.view!.superview!.tag {
                let alert = UIAlertController(title: "Confirmation", message: "Are you sure you want to delete this contact?", preferredStyle: .alert)
                let confirm = UIAlertAction(title: "Confirm", style: .default, handler: { (action) in
                    let req = CNSaveRequest()
                    req.delete(contact.mutableCopy() as! CNMutableContact)
                    try! CNContactStore().execute(req)
                })
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alert.addAction(confirm)
                alert.addAction(cancel)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        let label = UILabel()
        label.text = contacts[indexPath.row].givenName + " " + contacts[indexPath.row].familyName
        label.textColor = UIColor.black
        
        label.sizeToFit()
        label.center = cell.center
        label.frame = CGRect(x: 15, y: (cell.frame.height - label.frame.height) / 2, width: cell.frame.width - 30, height: label.frame.height)
        cell.contentView.addSubview(label)
        
        cell.contentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(CTTableViewController.deleteContact)))
        cell.tag = contacts[indexPath.row].hashValue
        return cell
    }
}
