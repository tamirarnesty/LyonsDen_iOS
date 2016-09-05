//
//  CalendarViewController.swift
//  LyonsDen
//
//  The CalendarViewContrller will be used for displaying the calendar as well as events associated with selected dates.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

// TODO: FIX LOCATION LABEL GETTING OUT OF ITS BOUNDS

class CalendarViewController: UIViewController, CalendarViewDataSource, CalendarViewDelegate {
    // The Calendar View
    // The size doesnt matter, it will resize it self later.
    var calendarView:CalendarView = CalendarView(frame: CGRectZero)
    // The loading wheel that is displayed
    @IBOutlet var loadingWheel: UIActivityIndicatorView!
    // The menu button on the Navigation Bar
    @IBOutlet weak var menuButton: UIBarButtonItem!
    // The scroll view, containing each event
    var scrollView:UIScrollView?
    // An array of events for the currently selected day
    var currentEvents:[EventView?] = []
    // The last selected day
    var lastSelectedDate:NSDate?
    // The label representing a strigified version of the currently selected date
    let dateLabel = UILabel()
    
    
    // Called when the segue initiating button is pressed
    override func viewDidLoad() {
        // Super call
        super.viewDidLoad()
        // Start the animation of the loading wheel
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
        
        // Setup the scrollView
        scrollView = UIScrollView(frame: CGRectMake(0, calendarHeight + 16, self.view.frame.width, self.view.frame.height - calendarHeight))    // Resize and position the scrollView
        scrollView!.backgroundColor = backgroundColor                           // Set the scrollView's background color
        dateLabel.frame = CGRectMake(8, 8, scrollView!.frame.width - 16, 21)    // Resize and position the dateLabel
        dateLabel.textColor = accentColor                                       // Change the text color of the dateLabel
        dateLabel.text = ""                                                     // Set a place holder for the text of the dateLabel
        dateLabel.textAlignment = NSTextAlignment.Center                        // Center the dateLabel's text on screen
        scrollView!.addSubview(dateLabel)                                       // Add the dateLabel to the scrollView
        
        // Add the calendar and scrollView to the main view and hide them until events are loaded
        self.view.addSubview(calendarView)
        self.view.addSubview(scrollView!)
        calendarView.hidden = true
        scrollView?.hidden = true
        
        // Initiate the loading of events from the web.
        self.loadEventsIntoCalendar()
    }
    
    // Called before apearing
    override func viewDidLayoutSubviews() {
        // Super call
        super.viewDidLayoutSubviews()
        // Declare the width and height of the calendar
        let width = self.view.frame.size.width - 16.0 * 2
        let height = width + 20.0
        self.calendarView.frame = CGRect(x: 16.0, y: 60.0, width: width, height: height)    // Resize and position the calendar on screen


        // If there are any events in the current date, then resize the scrollView's contentSize accordingly
        if self.currentEvents.count > 0 {   // If an event exists
            self.scrollView!.contentSize.height = 37 + (self.currentEvents[0]!.frame.height + 16) * CGFloat(self.currentEvents.count)
        } else {                            // If an event does not exist
            self.scrollView!.contentSize.height = self.scrollView!.frame.height
        }
    }
    
    // Called after the view has appeared
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)   // Super call
        self.calendarView.setDisplayDate(NSDate(), animated: true)                          // Set the current displayed date on the calendar, to the current date
        self.calendarView.reloadData()                                                      // Reload the calendar data
    }
    
    // Called whenever the events have been loaded
    func eventsDidLoad() {
        dispatch_async(dispatch_get_main_queue()) {
            self.calendarView.reloadData()
            
            self.calendarView.alpha = 0
            self.scrollView?.alpha = 0
            // Unhide the calendar and scrollView
            self.calendarView.hidden = false
            self.scrollView?.hidden = false
            
            UIView.animateWithDuration(0.2, animations: {
                self.calendarView.alpha = 1
                self.scrollView?.alpha = 1
                self.loadingWheel.alpha = 0
            })
            
            // Stop the loading wheel
            self.loadingWheel.stopAnimating()
        }
    }
    
// MARK: EVENTS
    
    // This function handles the process of downloading a calendar file from the web and parsing it, to add it to the app's calendar
    func loadEventsIntoCalendar() {
        // The link from which the calendar is downloaded
        let url = NSURL (string: "https://calendar.google.com/calendar/ical/wlmacci%40gmail.com/public/basic.ics")!
        
        // The process of downloading and parsing the calendar
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            // The following is simply a declaration and will not execute without the line 'task.resume()'
            if let URlContent = data {  // If Data has been loaded
                // If you got to this point then you've downloaded the calendar so...
                // Calendar File parsing starts here!!!
                // The string that holds the contents of the calendar's events
                let webContent:NSString = NSString(data: URlContent, encoding: NSUTF8StringEncoding)!
                
                // An array of flags used for locating the event fields
                // [h][0] - The flag that marks the begining of a field, [h][1] - The flag that marks the end of a field
                let searchTitles:[[String]] = [["SUMMARY:", "TRANSP:"], ["DESCRIPTION:", "LAST-MODIFIED:"], ["DTSTART", "DTEND"], ["DTEND", "DTSTAMP"], ["LOCATION:", "SEQUENCE:"]]
                // The set that will contain the events themselves
                var eventBank:Set<Event> = Set<Event>()
                // An array of operation for configuring the last added event, operations are in the same order as searchTitles.
                // The operations automatically modify the last item in the 'events' array.
                // The actual contents of this array are calculated at the time of access and will be different as defined in the if statement
                // Read the whole chapter on 'Functions' in the txtbook, there's some interesting stuff there, it'll all make sense
                
                var curEvent = Event(calendar: self.calendarView.calendar)

                var eventOperations:[(NSString) -> Void] {
                        return [curEvent.setTitle, curEvent.setDescription, curEvent.setStartDate, curEvent.setEndDate, curEvent.setLocation]
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
                
                // A holder for the begining and end flags for each event field
                var fieldBoundaries:[NSRange]
                // The actual parsing of each event
                repeat {
                    range = updateRange(range)  // Move our searching range to the next event
                    if NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) {   // If there are no more events in the searching range
                        break;                                              // Then no more shall be added (break from the loop)
                    }
                    
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
                    eventBank.insert(curEvent)
                    curEvent = Event(calendar: self.calendarView.calendar)
                } while (true)
                // Pass the recorded events to the calendar
                self.calendarView.events = Array(eventBank)
                // Notify the ViewController that the events have been loaded
                self.eventsDidLoad()
            } else if let errorData = error {   // If there has been an error
                print ("Calendar View: Event Download, Failed!")
                print ("Printing error description...")
                print ()
                print (errorData.description)
                print ()
                // Will, either handle or display the error, whenever i get more experience with this
            } else {    // If there is no internet
                print ("Calendar View: Event Download, No Internet!")
                // Will display an error
            }
        }
        // Initiate the load ing process
        task.resume()
    }
    
// MARK: CALENDAR DATASOURCE IMPLEMENTATION
    
    // Set the start date that can be viewed with the calendar
    func startDate() -> NSDate? {
        // This will be changed
        
        // Declare a dateComponents to hold the date values
        let dateComponents = NSDateComponents()
        
        /////////////////////////////////////////////////////////////////
        // This is what you need to change, everything else works fine //
        // Set how far back the calendar can be viewed                 //
        /////////////////////////////////////////////////////////////////
        dateComponents.month = -5
        
        // Declare today's date
        let today = NSDate()
        // Declare the range of the between the start date and today
        let startDate = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        // Return the start date
        return startDate
    }
    
    // Set the end date that can be viewed with the calendar
    func endDate() -> NSDate? {
        // This will be changed
        
        // Declare a dateComponents to hold the date values
        let dateComponents = NSDateComponents()
        
        /////////////////////////////////////////////////////////////////
        // This is what you need to change, everything else works fine //
        // Set how far the calendar can be viewed                      //
        /////////////////////////////////////////////////////////////////
        dateComponents.year = 1;
        
        // Declare today's date
        let today = NSDate()
        // Declare the range of the between the end date and today
        let oneYearsFromNow = self.calendarView.calendar.dateByAddingComponents(dateComponents, toDate: today, options: NSCalendarOptions())
        // Return the end date
        return oneYearsFromNow
    }
    
// MARK: CALENDAR DELEGATE IMPLEMENTATION
    
    // Called before selecting a date (I think). Required to be implemented
    func calendar(calendar: CalendarView, canSelectDate date: NSDate) -> Bool { return true }
    
    // Called when a month is scrolled in the calendar. Required to be implemented
    func calendar(calendar: CalendarView, didScrollToMonth date: NSDate) {}
    
    // Called when a date is deselected. Required to be implemented
    func calendar(calendar: CalendarView, didDeselectDate date: NSDate) {}
    
    // Called when a date is selected. Required to be implemented
    func calendar(calendar: CalendarView, didSelectDate date: NSDate, withEvents events: [Event]) {
        if let lastDate = lastSelectedDate {
            if date == lastDate {
                return
            }
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
                    let tempHold = events[h].startDate!.description as NSString
                    self.currentEvents[h]!.timeLabel.text = tempHold.substringToIndex(16) as String
                    self.currentEvents[h]!.locationLabel.text = events[h].location
                    
                    self.currentEvents[h]!.locationLabel.frame.size.width = (self.currentEvents[h]!.frame.width/2) - 16
                    self.currentEvents[h]!.timeLabel.frame.size.width = (self.currentEvents[h]!.frame.width/2) - 16
                }
            }
            self.dateLabel.text = NSString(string: date.description).substringToIndex(10)
        }
    }
}
