//
//  CalendarViewController.swift
//  LyonsDen
//
//  The CalendarViewContrller will be used for displaying the calendar as well as events associated with certain dates.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class CalendarViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {
    // The Calendar View
    // The size doesnt matter, it will resize it self later.
    var calendarView:CalendarView = CalendarView(frame: CGRectZero)
    // The loading wheel that is displayed
    @IBOutlet var loadingWheel: UIActivityIndicatorView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    var scrollView:UIScrollView?
    var currentEvents:[EventView?] = []
    var lastSelectedDate:NSDate?
    let dateLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadingWheel.startAnimating()
        loadingWheel.hidesWhenStopped = true
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()                                     // Set Button Target class
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))              // Set Button Target method
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())  // Create a gesture recognizer in the ViewController
        }
        // Set the DataSource and Delegate of the calendar
        calendarView.dataSource = self
        calendarView.delegate = self
        
        // Create a place holder for the calendar's height
        let calendarHeight = (self.view.frame.size.width - 16.0 * 2) + 20.0
        
        // Resize and position the scrollView
        scrollView = UIScrollView(frame: CGRectMake(0, calendarHeight + 16, self.view.frame.width, self.view.frame.height - calendarHeight))
        scrollView!.backgroundColor = backgroundColor
        
        dateLabel.frame = CGRectMake(8, 8, scrollView!.frame.width - 16, 21)
        dateLabel.textColor = accentColor
        dateLabel.text = ""
        dateLabel.textAlignment = NSTextAlignment.Center
        scrollView!.addSubview(dateLabel)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Resize the Calendar to fit the screen.
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        calendarView.reloadData()
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width + 20.0
        self.calendarView.frame = CGRect(x: 16.0, y: 60.0, width: width, height: height)
        self.calendarView.setDisplayDate(NSDate(), animated: true)
        self.calendarView.reloadData()
        
        if self.currentEvents.count > 0 {
            self.scrollView!.contentSize.height = 37 + (self.currentEvents[0]!.frame.height + 16) * CGFloat(self.currentEvents.count)
        } else {
            self.scrollView!.contentSize.height = self.scrollView!.frame.height
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.loadEventsIntoCalendar()
        loadingWheel.stopAnimating()
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
        print ("I eselected \(date.description)")
    }
    
    // Called when a date is selected. Required to be implemented
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [Event]) {
        if date == lastSelectedDate {
            return
        }
        
        if let lastDate = lastSelectedDate {
            self.calendarView.deselectDate(lastDate)
        }
        lastSelectedDate = date
        
        dispatch_async(dispatch_get_main_queue()) {
            self.currentEvents.removeAll()
            
            if self.scrollView!.subviews.count > 0 {
                for subview in self.scrollView!.subviews {
                    if subview != self.dateLabel {
                        subview.removeFromSuperview()
                    }
                }
            }
        
            if (events.count > 0) {
                for h in 0...events.count - 1 {
                    self.currentEvents.append(EventView(frame: CGRectMake(8, 37 + (320 * CGFloat(h)), self.scrollView!.frame.width - 16, 316)))
                    self.scrollView!.addSubview(self.currentEvents[h]!)
                    self.currentEvents[h]!.titleLabel.text = events[h].title
                    self.currentEvents[h]!.infoLabel.text = events[h].description
                    self.currentEvents[h]!.timeLabel.text = events[h].startDate?.description
                    self.currentEvents[h]!.locationLabel.text = events[h].location
                }
            }
            self.dateLabel.text = NSString(string: date.description).substringToIndex(10)
        }
    }
    
    // https://calendar.google.com/calendar/ical/yusuftazim204%40gmail.com/private-f2b3e6f282204329e487a76f4478cb33/basic.ics
    func loadEventsIntoCalendar() {
        // The link from which the calendar is downloaded
        let url = NSURL (string: "https://calendar.google.com/calendar/ical/yusuftazim204%40gmail.com/private-f2b3e6f282204329e487a76f4478cb33/basic.ics")!
        var eventsHaveBeenLoaded = false
        
        // The process of downloading and parsing the calendar
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            if let URlContent = data {  // If Data has been loaded
                // If you got to this point then you've downloaded the calendar so...
                
                // Calendar File parsing starts here!!!
                
                // The string that holds the contents of the calendar's events
                let webContent:NSString = NSString(data: URlContent, encoding: NSUTF8StringEncoding)!
                // An array of flags used for locating the event fields
                // [h][0] - The flag that marks the begining of a field, [h][1] - The flag that marks the end of a field
                let searchTitles:[[String]] = [["SUMMARY:", "TRANSP:"], ["DESCRIPTION:", "LAST-MODIFIED:"], ["DTSTART", "DTEND"], ["DTEND", "DTSTAMP"], ["LOCATION:", "SEQUENCE:"]]
                // An array that will contain the events themselves
                var events:[Event] = [Event]()
                // An array of operation for configuring the last added event, operations are in the same order as searchTitles. 
                // The operations automatically modify the last item in the 'events' array.
                // The actual contents of this array are calculated at the time of access and will be different as defined in the if statement
                var eventOperations:[(NSString) -> Void] {
                    if events.count != 0 {  // If there are events. then there are operations
                        return [events[events.count-1].setTitle, events[events.count-1].setDescription, events[events.count-1].setStartDate, events[events.count-1].setEndDate, events[events.count-1].setLocation]
                    } else {                // If there are no events, then there are no operations
                        return []
                    }                       // Simple as that.
                }
                // The range of "webContent's" content that is to be scanned
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
                        var tempHold:String = webContent.substringWithRange(findDifference(fieldBoundaries[0], fieldBoundaries[1]))                         // Create a new string from whatever is in between the two flags. This will be the current field of the event
                        tempHold = tempHold.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())                                           // Remove all /r /n and other 'new line' characters from the event field
                        tempHold = tempHold.stringByReplacingOccurrencesOfString("\u{005C}", withString: "", options: .LiteralSearch, range: nil)           // Replace all backslashes from the event field
                        eventOperations[h](tempHold)                                                                                                        // Add the event field to the current event being recorded
                    }
                } while (true)
                // Pass the recorded events to the calendar
                self.calendarView.events = events
                print ("I loaded the events")
                eventsHaveBeenLoaded = true
            } else if let errorData = error {
                print ("An error occured")
            } else {
                print ("No internet")
            }
        }
        
        task.resume()
        
        while (true) {
            if task.state == NSURLSessionTaskState.Completed {//&& eventsHaveBeenLoaded {
                // Add the calendar into the ViewController
                print ("Now I'am displaying the calendar")
                self.view.addSubview(calendarView)
                self.view.addSubview(scrollView!)
                
                
                break
            }
        }
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
    
    
//    currentEvents.append(EventView(frame: CGRectMake(8, 37, scrollView!.frame.width - 16, 316)))
//    
//    scrollView!.addSubview(currentEvents[0]!)
//    
//    currentEvents[0]!.titleLabel.text = "Ttiel"
//    currentEvents[0]!.infoLabel.text = "Info"
//    currentEvents[0]!.timeLabel.text = "2:30"
//    currentEvents[0]!.locationLabel.text = "School"
//    
//    currentEvents.append(EventView(frame: CGRectMake(8, 37 + 316 + 8, scrollView!.frame.width - 16, 316)))
//    
//    scrollView!.addSubview(currentEvents[1]!)
//    
//    currentEvents[1]!.titleLabel.text = "Ttiel Kobalsdas"
//    currentEvents[1]!.infoLabel.text = "Info"
//    currentEvents[1]!.timeLabel.text = "2:30 bdshaio"
//    currentEvents[1]!.locationLabel.text = "School dsa dsa"
}
