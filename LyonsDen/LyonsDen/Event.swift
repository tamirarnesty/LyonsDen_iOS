//
//  Event.swift
//  Calendar v1
//
//  Created by Inal Gotov on 2016-07-14.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation

class Event {
    var title:String
    var description:String
    var startDate:NSDate?
    var endDate:NSDate?
    var location:String
    private var dateCreator:NSDateComponents = NSDateComponents()
    
    init (calendar:NSCalendar) {
        self.title = ""
        self.description = ""
        self.startDate = nil
        self.endDate = nil
        self.location = ""
        self.dateCreator.calendar = calendar
    }
    
    func setTitle (newTitle:NSString) {
        self.title = newTitle as String
    }
    
    func setDescription (newDescription:NSString) {
        self.description = newDescription as String
    }
    
    func setStartDate (newDate:NSString) {
        if newDate.hasPrefix(":"){
            dateCreator.year = Int (newDate.substringWithRange(NSMakeRange(1, 4)))!
            dateCreator.month = Int (newDate.substringWithRange(NSMakeRange(5, 2)))!
            dateCreator.day = Int (newDate.substringWithRange(NSMakeRange(7, 2)))!
            dateCreator.hour = Int (newDate.substringWithRange(NSMakeRange(10, 2)))! - 4    // Minus 4 because it returns time in a different timezone (No clue as to why)
            dateCreator.minute = Int (newDate.substringWithRange(NSMakeRange(12, 2)))!
            dateCreator.second = Int (newDate.substringWithRange(NSMakeRange(14, 2)))!
            self.startDate = dateCreator.date!
        } else if newDate.hasPrefix(";") {
            dateCreator.year = Int (newDate.substringWithRange(NSMakeRange(12, 4)))!
            dateCreator.month = Int (newDate.substringWithRange(NSMakeRange(16, 2)))!
            dateCreator.day = Int (newDate.substringWithRange(NSMakeRange(18, 2)))!
            dateCreator.hour = 00
            dateCreator.minute = 00
            dateCreator.second = 00
            self.startDate = dateCreator.date!
        }
    }
    
    func setEndDate (newDate:NSString) {
        if newDate.hasPrefix(":"){
            dateCreator.year = Int (newDate.substringWithRange(NSMakeRange(1, 4)))!
            dateCreator.month = Int (newDate.substringWithRange(NSMakeRange(5, 2)))!
            dateCreator.day = Int (newDate.substringWithRange(NSMakeRange(7, 2)))!
            dateCreator.hour = Int (newDate.substringWithRange(NSMakeRange(10, 2)))! - 4    // Minus 4 because it returns time in a different timezone (No clue as to why)
            dateCreator.minute = Int (newDate.substringWithRange(NSMakeRange(12, 2)))!
            dateCreator.second = Int (newDate.substringWithRange(NSMakeRange(14, 2)))!
            self.startDate = dateCreator.date!
        } else if newDate.hasPrefix(";") {
            dateCreator.year = Int (newDate.substringWithRange(NSMakeRange(12, 4)))!
            dateCreator.month = Int (newDate.substringWithRange(NSMakeRange(16, 2)))!
            dateCreator.day = Int (newDate.substringWithRange(NSMakeRange(18, 2)))!
            dateCreator.hour = 00
            dateCreator.minute = 00
            dateCreator.second = 00
            self.startDate = dateCreator.date!
        }
    }
    
    func setLocation (newLocation:NSString) {
        self.location = newLocation as String
    }
}