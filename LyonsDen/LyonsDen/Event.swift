//
//  Event.swift
//  Calendar v1
//
//  Created by Inal Gotov on 2016-07-14.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation

class Event: Hashable {
    var title:String
    var description:String
    var startDate:Date?
    var endDate:Date?
    var location:String
    fileprivate var dateCreator:DateComponents = DateComponents()
    
    var hashValue: Int {
        get {
            if title == "" && description == "" && startDate == nil && endDate == nil && location == "" {
                return -1
            } else {
                return (title + description + (startDate?.description)! + (endDate?.description)! + location).hashValue
            }
        }
    }
    
    init (calendar:Calendar) {
        self.title = ""
        self.description = ""
        self.startDate = nil
        self.endDate = nil
        self.location = ""
        self.dateCreator.calendar = calendar
    }
    
    func setTitle (_ newTitle:NSString) {
        self.title = newTitle as String
    }
    
    func setDescription (_ newDescription:NSString) {
        self.description = newDescription as String
    }
    
    func setStartDate (_ newDate:NSString) {
        if newDate.hasPrefix(":"){      // Example :20130410T230000Z
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(1, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(5, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(7, 2)))!
            dateCreator.hour = Int (newDate.substring(with: NSMakeRange(10, 2)))! - 4 // Minus 4 because it returns time in a different timezone (No clue as to why)
            dateCreator.minute = Int (newDate.substring(with: NSMakeRange(12, 2)))!
            dateCreator.second = Int (newDate.substring(with: NSMakeRange(14, 2)))!
            
            startDate = dateCreator.date!
        } else if newDate.hasPrefix(";TZID") {      // Example ;TZID=America/Toronto:20120928T100000
            let firstLocation = newDate.range(of: "=").location + 1
            dateCreator.timeZone = TimeZone(identifier: newDate.substring(with: NSMakeRange(firstLocation, newDate.range(of: ":").location - firstLocation)))
            
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(22, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(26, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(28, 2)))!
            dateCreator.hour = Int (newDate.substring(with: NSMakeRange(31, 2)))! - 4
            dateCreator.minute = Int (newDate.substring(with: NSMakeRange(33, 2)))!
            dateCreator.second = Int (newDate.substring(with: NSMakeRange(35, 2)))!
            
            startDate = dateCreator.date!
        } else if newDate.hasPrefix(";") {      // Example ;VALUE=DATE:20170609
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(12, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(16, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(18, 2)))!
            dateCreator.hour = 00 - 4
            dateCreator.minute = 00
            dateCreator.second = 00
            
            startDate = dateCreator.date!
        } else if newDate == "" {
            dateCreator.year = 1970
            dateCreator.month = 01
            dateCreator.day = 01
            dateCreator.hour = 00
            dateCreator.minute = 00
            dateCreator.second = 00
            
            startDate = dateCreator.date!
        } else {
            fatalError("Failed to prase \(newDate)")
        }
    }
    
    func setEndDate (_ newDate:NSString) {
        if newDate.hasPrefix(":"){      // Example :20130410T230000Z
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(1, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(5, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(7, 2)))!
            dateCreator.hour = Int (newDate.substring(with: NSMakeRange(10, 2)))! - 4 // Minus 4 because it returns time in a different timezone (No clue as to why)
            dateCreator.minute = Int (newDate.substring(with: NSMakeRange(12, 2)))!
            dateCreator.second = Int (newDate.substring(with: NSMakeRange(14, 2)))!
            
            endDate = dateCreator.date!
        } else if newDate.hasPrefix(";TZID") {      // Example ;TZID=America/Toronto:20120928T100000
            let firstLocation = newDate.range(of: "=").location + 1
            dateCreator.timeZone = TimeZone(identifier: newDate.substring(with: NSMakeRange(firstLocation, newDate.range(of: ":").location - firstLocation)))
            
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(22, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(26, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(28, 2)))!
            dateCreator.hour = Int (newDate.substring(with: NSMakeRange(31, 2)))! - 4
            dateCreator.minute = Int (newDate.substring(with: NSMakeRange(33, 2)))!
            dateCreator.second = Int (newDate.substring(with: NSMakeRange(35, 2)))!
            
            endDate = dateCreator.date!
        } else if newDate.hasPrefix(";") {      // Example ;VALUE=DATE:20170609
            dateCreator.year = Int (newDate.substring(with: NSMakeRange(12, 4)))!
            dateCreator.month = Int (newDate.substring(with: NSMakeRange(16, 2)))!
            dateCreator.day = Int (newDate.substring(with: NSMakeRange(18, 2)))!
            dateCreator.hour = 00 - 4
            dateCreator.minute = 00
            dateCreator.second = 00
            
            endDate = dateCreator.date!
        } else if newDate == "" {
            dateCreator.year = 1970
            dateCreator.month = 01
            dateCreator.day = 01
            dateCreator.hour = 00
            dateCreator.minute = 00
            dateCreator.second = 00
            
            endDate = dateCreator.date!
        } else {
            fatalError("Failed to prase \(newDate)")
        }
    }
    
    func setLocation (_ newLocation:NSString) {
        self.location = newLocation as String
    }
}

func == (lhs: Event, rhs: Event) -> Bool {
    if (lhs.hashValue == rhs.hashValue) {
        return true
    } else if (lhs.title == rhs.title) && (lhs.description == rhs.description) && (lhs.startDate == rhs.startDate) && (lhs.endDate == rhs.endDate) && (lhs.location == rhs.location) {
        return true
    }
    return false
}
