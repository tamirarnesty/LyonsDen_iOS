//
//  CalendarViewController.swift
//  LyonsDen
//
//  The CalendarViewContrller will be used for controlling the calendar screen.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {
    // The Calendar View
    // The size doesnt matter, it will resize it self later.
    var calendarView:CalendarView = CalendarView(frame: CGRectZero)
    
    @IBOutlet weak var menuButton: UIBarButtonItem!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        calendarView.dataSource = self
        calendarView.delegate = self
        
        self.view.addSubview(calendarView)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        calendarView.setDisplayDate(NSDate(), animated: true)
        loadEventsIntoCalendar()
        calendarView.reloadData()
    }
    
    // Resize the Calendar to fit the screen.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width + 20.0
        self.calendarView.frame = CGRect(x: 16.0, y: 72.0, width: width, height: height)
    }
    
    // Set the start date that the calendar can view
    func startDate() -> NSDate? {
        // This should be changed
        
        let dateComponents = NSDateComponents()
        dateComponents.month = -5
        
        let today = NSDate()
        let threeMonthsAgo = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        return threeMonthsAgo
    }
    
    // Set the end date that the calendar can view
    func endDate() -> NSDate? {
        // This should be changed
        
        let dateComponents = NSDateComponents()
        
        dateComponents.year = 1;
        let today = NSDate()
        
        let oneYearsFromNow = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        
        return oneYearsFromNow
    }
    
    // Called before selecting a date (I think). Required to be implemented
    func calendar(calendar: CalendarView, canSelectDate date: NSDate) -> Bool {
        // Make a checker for whether this date has any events
        return true
    }
    
    // Called when a month is scrolled in the calendar. Required to be implemented
    func calendar(calendar: CalendarView, didScrollToMonth date: NSDate) {
        
    }
    
    // Called when a date is deselected. Required to be implemented
    func calendar(calendar: CalendarView, didDeselectDate date: NSDate) {
        
    }
    
    // Called when a date is selected. Required to be implemented
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [Event]) {
        if events.count > 0 {
            print (events[0].title)
        }
//        performSegueWithIdentifier("CalendarSegue", sender: nil)
//        self.calendarView.deselectDate(date)
    }
    
    // https://calendar.google.com/calendar/ical/yusuftazim204%40gmail.com/private-f2b3e6f282204329e487a76f4478cb33/basic.ics
    func loadEventsIntoCalendar() {
        // The link from which the calendar is downloaded
        let url = NSURL (string: "https://calendar.google.com/calendar/ical/yusuftazim204%40gmail.com/private-f2b3e6f282204329e487a76f4478cb33/basic.ics")!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            if let URlContent = data {  // If Data has been loaded
                
                // Calendar File parsing starts here!!!
                
                // The string that holds the contents of the calendar's events
                let webContent:NSString = NSString(data: URlContent, encoding: NSUTF8StringEncoding)!
                // An array of flags used for locating the event fields
                // [h][0] - The flag that marks the begining of a field, [h][1] - The flag that marks the end of a field
                let searchTitles:[[String]] = [["SUMMARY:", "TRANSP:"], ["DESCRIPTION:", "LAST-MODIFIED:"], ["DTSTART", "DTEND"], ["DTEND", "DTSTAMP"], ["LOCATION:", "SEQUENCE:"]]
                
                var events:[Event] = [Event]()
                
                var eventOperations:[(NSString) -> Void] {
                    if events.count != 0 {
                        return [events[events.count-1].setTitle, events[events.count-1].setDescription, events[events.count-1].setStartDate, events[events.count-1].setEndDate, events[events.count-1].setLocation]
                    } else {
                        return []
                    }
                }
                
                // The range of "webContent's" content that is currently being scanned
                // Must be decreased after each event is scanned
                var range:NSRange = NSMakeRange(0, webContent.length - 1)
                // Inside function that will be used to determine the 'difference' range between the begining and end flag ranges.
                let findDifference:(NSRange, NSRange) -> NSRange = {(first:NSRange, second:NSRange) -> NSRange in
                    let location = first.location + first.length, length = second.location - location   // Determine the start position and length of our new range
                    return NSMakeRange(location, length)                                                // Create and return the new range
                }
                // Inside function that will be used to move the searching range to the next event
                // Returns an NSNotFound range (NSNotFound, 0) if there are not more events
                let updateRange:(NSRange) -> NSRange = {(oldRange:NSRange) -> NSRange in
                    let beginingDeclaration = webContent.rangeOfString("BEGIN:VEVENT", options: NSStringCompareOptions.LiteralSearch, range: oldRange)
                    // If the "BEGIN:VEVENT" was not found in webContent (no more events)
                    if NSEqualRanges(beginingDeclaration, NSMakeRange(NSNotFound, 0)) {
                        return beginingDeclaration  // Return an 'NSNotFound' range (Named it myself;)
                    }
                    // Calculate the index of the last character of 'beginingDeclaration' flag
                    let endOfBeginingDeclaration = beginingDeclaration.location + beginingDeclaration.length
                    // Calculate the length of the new range
                    let length = oldRange.length - endOfBeginingDeclaration + oldRange.location
                    // Calculate the starting location of the new range
                    let location = endOfBeginingDeclaration
                    // Create and return the new range
                    return NSMakeRange(location, length)
                }
                
                // Counter for which event is currently being recorded
                var eventCounter = -1
                // A holder for the begining and end flags for each event field
                var fieldBoundaries:[NSRange]
                
                // The actual parsing of each event
                repeat {
                    eventCounter += 1           // Increase the counter to the next event
                    range = updateRange(range)  // Move our searching range to the next event
                    if NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) {   // If there are no more events in the searching range
                        break;
                    }
                    events.append(Event(calendar: self.calendarView.calendar))        // Create an entry for the event database
                    
                    // Record each field into our event database
                    for h in 0...searchTitles.count-1 {
                        fieldBoundaries = [NSRange]()   // Clear the fieldBoundaries for the new search
                        fieldBoundaries.append(webContent.rangeOfString(searchTitles[h][0], options: NSStringCompareOptions.LiteralSearch, range: range))   // Find the begining flag
                        fieldBoundaries.append(webContent.rangeOfString(searchTitles[h][1], options: NSStringCompareOptions.LiteralSearch, range: range))   // Find the ending flag
                        var tempHold:String = webContent.substringWithRange(findDifference(fieldBoundaries[0], fieldBoundaries[1]))
                        tempHold = tempHold.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())
                        tempHold = tempHold.stringByReplacingOccurrencesOfString("\u{005C}", withString: "", options: .LiteralSearch, range: nil)
                        eventOperations[h](tempHold)
                    }
                } while (true)
                
                self.calendarView.events = events
            }
        }
        
        task.resume()
    }
    
    //    // Find the stuff you need
    //    let startIndex = webContent.rangeOfString("Day Weather Forecast Summary:")
    //    let endIndex = webContent.rangeOfString(".</span>")
    //    // A holder variable
    //    var str:NSString
    //
    //    // If the stuff you need exists
    //    if (startIndex.length != 0) {
    //    // Crop it out
    //    str = NSString (string: webContent.substringToIndex(endIndex.location + 1))
    //    str = str.substringFromIndex(startIndex.location)
    //    // Remove the html tags
    //    str = str.stringByReplacingOccurrencesOfString("<[^>]+>", withString: "", options: .RegularExpressionSearch, range: NSMakeRange(0, str.length))
    //    // Replace a 'symbol' html tag with the actual symbol
    //    str = str.stringByReplacingOccurrencesOfString("&deg;", withString: "°", options: .RegularExpressionSearch, range: NSMakeRange(0, str.length))
    //    } else {
    //    str = "Please enter and appropriate city"
    //    }
    
    
    //    // This will be important !!!!!!!!!!!!!!!!!!!!
    //    // Not any more, doesnt exactly do what i hoped it would
    //
    //    // MARK : Events
    //    func loadEventsInCalendar() {
    //        // If there's a start date and an end date
    //        if let startDate = self.startDate(), endDate = self.endDate() {
    //            let store = EKEventStore()      // Create an instance of the system's calendar with all of its events.
    //
    //            // Declare an inside functioin/method that will:
    //            let fetchEvents = { (/*take in no parameters*/) -> Void in // and return void
    //                let predicate = store.predicateForEventsWithStartDate(startDate, endDate:endDate, calendars: nil)   // Create a portion of events, in a 'predicate' format, between the given dates
    //
    //                // The 'eventsMatchingPredicate' method will return all events that are in the time period of the given predicate
    //                // Therefore it is possible that it will return nil
    //                if let eventsBetweenDates = store.eventsMatchingPredicate(predicate) as [EKEvent]? {        // If there are events matching the predicate then
    //                    self.calendarView.events = eventsBetweenDates                                           // Add them into the calendar
    //                }
    //            }
    //
    //            // let q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
    //            if EKEventStore.authorizationStatusForEntityType(EKEntityType.Event) != EKAuthorizationStatus.Authorized {  // If the app does not have access to the system's calendar then
    //                // Request access from the user. (A window will pop-up requesting access to the calendar events)
    //                // 'completion' is the handler(yes, its a function) for whatever happens after the window
    //                // The handler has the parameter of granted:Bool and error:NSError? and returns void
    //                store.requestAccessToEntityType(EKEntityType.Event, completion: {(granted, error ) -> Void in
    //                    if granted {    // If the user has granted access to his calendar then
    //                        fetchEvents()   // Call the inside function
    //                    }
    //                })
    //            } else {    // If the app already had access to the calendar then
    //                fetchEvents()   // Call the inside function
    //            }
    //        }
    //    }
}
