//
//  File.swift
//  Pcaller
//
//  Created by Oran Levi on 22/10/2022.
//

import CoreData

@objc(HistoryData)

class HistoryData: NSManagedObject {
    
    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var telephone: String
    @NSManaged var time: String
    @NSManaged var callHidden: NSNumber?
    
    var firstAndLastNameCallHistory: String {
        return "\(firstName)  \(lastName)"
    }
    
    var lastAndFirstCallHistory: String {
        return "\(lastName)  \(firstName)"
    }
    
}
