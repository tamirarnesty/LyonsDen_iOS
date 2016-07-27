//
//  KDCalendarView.swift
//  KDCalendar
//
//  Created by Michael Michailidis on 02/04/2015.
//  Modified by Inal Gotov on 12/07/2016
//  Added the functionality of the scrolling buttons
//  Made minor changes to the nature of date selection
//
//  Copyright (c) 2015 Karmadust. All rights reserved.
//
//  Half-Commented by Inal Gotov

import UIKit
import EventKit

// Global Variables

let cellReuseIdentifier = "CalendarDayCell" // The reuse identifier for the cell
let NUMBER_OF_DAYS_IN_WEEK = 7              // The number of days in a week
let MAXIMUM_NUMBER_OF_ROWS = 6              // Maximum number of rows in a month
let HEADER_DEFAULT_HEIGHT : CGFloat = 80.0  // Default height of the header
let FIRST_DAY_INDEX = 0                     // Default index of the first index
let NUMBER_OF_DAYS_INDEX = 1                // Default ??????????????????????????
let DATE_SELECTED_INDEX = 2                 // Default selected index

//// Extension of the Event class
//extension Event {
//    var isOneDay : Bool {
//        let components = NSCalendar.currentCalendar().components([.Era, .Year, .Month, .Day], fromDate: self.startDate!, toDate: self.endDate!, options: NSCalendarOptions())
//        return (components.era == 0 && components.year == 0 && components.month == 0 && components.day == 0)
//    }
//}

// The protocol(Interface) that is used to define a DataSource for this Calendar
protocol CalendarViewDataSource {
    func startDate() -> NSDate? // Method that determines the start date of the current month
    func endDate() -> NSDate?   // Method that determines the end date of the current month
}

// The protocol(Interface) that is used to define a Delegate(User Interaction Handler) for this Calendar
protocol CalendarViewDelegate {
    func calendar(calendar : CalendarView, canSelectDate date : NSDate) -> Bool        // Returns true if the current date can be selected
    func calendar(calendar : CalendarView, didScrollToMonth date : NSDate) -> Void              // Called when the month is scrolled
    func calendar(calendar : CalendarView, didSelectDate date : NSDate, withEvents events: [Event]) -> Void   // Called when a date is selected
    func calendar(calendar : CalendarView, didDeselectDate date : NSDate) -> Void      // Called when a date has been deselected
}


// This class handles the calendar view
class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var dataSource  : CalendarViewDataSource?   // The Data Soutce Object of the calendar. Must be set from the outside
    var delegate    : CalendarViewDelegate?     // The User Interaction Handler Object. Must be set from the outside
    
    // calView = CalendarView
    
    // A gregorian version of this calView's NSCalendar
    lazy var gregorian : NSCalendar = {
        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!    // Create a gregorian calendar
        cal.timeZone = NSTimeZone(abbreviation: "UTC")!                     // Set it timezone to UTC format
        return cal
    }()
    
    // The actual calendar that is used for this calView
    var calendar : NSCalendar {
        return self.gregorian
    }
    
    // The scrolling direction of this calView
    var direction : UICollectionViewScrollDirection = .Horizontal {
        // If this calendar has a layout, set the direction of that layout to the direction of this calView
        didSet {
            if let layout = self.calendarView.collectionViewLayout as? CalendarFlowLayout {
                layout.scrollDirection = direction
                self.calendarView.reloadData()
            }
        }
    }
    
    private var startDateCache : NSDate = NSDate()      // The start date of this calView
    private var endDateCache : NSDate = NSDate()        // The end date of this calView
    private var startOfMonthCache : NSDate = NSDate()   // The ????????????????????????????
    private var todayIndexPath : NSIndexPath?           // The index of today's date
    var displayDate : NSDate?                           // The current date that is displayed
    
    private(set) var selectedIndexPaths : [NSIndexPath] = [NSIndexPath]()   // An array containing the indexes of the selected dates
    private(set) var selectedDates : [NSDate] = [NSDate]()                  // An array containing the selected dates
    
    private var eventsByIndexPath : [NSIndexPath:[Event]] = [NSIndexPath:[Event]]() // A dictionary containing an array of Events for a given NSIndexPath
    
    // The event bank for this calendar
    var events : [Event]? {
        didSet {
            // Recreate the eventsByindexPath bank
            eventsByIndexPath = [NSIndexPath:[Event]]()
            
            // If there are events then continue
            guard let events = events else {
                return
            }
            
            // This holds the difference in seconds between the current timezone and GMT
            let secondsFromGMTDifference = NSTimeInterval(NSTimeZone.localTimeZone().secondsFromGMT)
            // For each event...
            for event in events {
                // Declare the search/create flags
                let flags: NSCalendarUnit = [NSCalendarUnit.Month, NSCalendarUnit.Day]
                // Determine the start date in GMT
                let startDate = event.startDate!.dateByAddingTimeInterval(secondsFromGMTDifference)
                // Get the distance of the event from the start of the month
                let distanceFromStartComponent = self.gregorian.components( flags, fromDate:startOfMonthCache, toDate: startDate, options: NSCalendarOptions() )
                // Create the indexPath of the event
                let indexPath = NSIndexPath(forItem: distanceFromStartComponent.day, inSection: distanceFromStartComponent.month)
                // If there are already events in the created indexPath then
                if var eventsList : [Event] = eventsByIndexPath[indexPath] {
                    eventsList.append(event) // Simply append them to the dictionary of eventsByindexPaths
                    eventsByIndexPath[indexPath] = eventsList
                } else {
                    eventsByIndexPath[indexPath] = [event] // Otherwise create the dictionary entry
                }
            }
            self.calendarView.reloadData()  // Reload the data
        }
    }
    
    // This holds an instance of the Calendar Header
    lazy var headerView : CalendarHeaderView = {
        let hv = CalendarHeaderView(frame:CGRectZero)
        return hv
    }()
    
    // This holds a UICollectionView for this calView
    lazy var calendarView : UICollectionView = {
        let layout = CalendarFlowLayout()           // Creates a layout for this collection view
        layout.scrollDirection = self.direction;    // Sets its scrolling direction
        layout.minimumInteritemSpacing = 0          // Sets the minimum spacing between each item
        layout.minimumLineSpacing = 0               // Sets the minimum spacing between each line (row, i think)
        
        let cv = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)  // Creates the collection view itslef
        cv.dataSource = self                        // Sets its Data Source
        cv.delegate = self                          // Sets its Delegate (User Interaction Handler)
        cv.pagingEnabled = true                     // Makes it pageable
        cv.backgroundColor = UIColor.clearColor()   // Makes its background transparent
        // Hides scrolling indicators
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        
        cv.allowsMultipleSelection = true           // Makes it multiscreen
        return cv
    }()
    
    // Override for the variable that defines the position and size of this view
    override var frame: CGRect {
        // Sets the sizes of all elements within this view
        didSet {
            let heigh = frame.size.height - HEADER_DEFAULT_HEIGHT
            let width = frame.size.width
            
            self.headerView.frame   = CGRect(x:0.0, y:0.0, width: frame.size.width, height:HEADER_DEFAULT_HEIGHT)   // Set the size and position of the header
            self.calendarView.frame = CGRect(x:0.0, y:HEADER_DEFAULT_HEIGHT, width: width, height: heigh)           // Set the size and position of the calendar
            
            let layout = self.calendarView.collectionViewLayout as! UICollectionViewFlowLayout
            layout.itemSize = CGSizeMake(width / CGFloat(NUMBER_OF_DAYS_IN_WEEK), heigh / CGFloat(MAXIMUM_NUMBER_OF_ROWS))  // Set the size of each item
        }
    }
    
    // Create a new calView with size 200x200 at (0, 0)
    override init(frame: CGRect) {
        super.init(frame : CGRectMake(0.0, 10.0, 200.0, 200.0))
        self.initialSetup()
    }
    
    // The Interface Builder Initializer
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Called when the view has been loaded from an interface builder
    override func awakeFromNib() {
        self.initialSetup()
    }
    
    // Setup the calView
    private func initialSetup() {
        self.clipsToBounds = true   // Makes sure that this calView's subviews dont go beyond the calView's boundaries
        // Register the Class in the collection view (what?)
        self.calendarView.registerClass(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.headerView)    // Add the header
        self.addSubview(self.calendarView)  // Add the calendar
    }
    
    // Implementation of the UICollectionViewDataSource
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        guard let startDate = self.dataSource?.startDate(), endDate = self.dataSource?.endDate() else {
            return 0
        }
        
        startDateCache = startDate
        endDateCache = endDate
        
        // check if the dates are in correct order
        if self.gregorian.compareDate(startDate, toDate: endDate, toUnitGranularity: .Nanosecond) != NSComparisonResult.OrderedAscending {
            return 0
        }
        
        let firstDayOfStartMonth = self.gregorian.components( [.Era, .Year, .Month], fromDate: startDateCache)
        firstDayOfStartMonth.day = 1
        
        guard let dateFromDayOneComponents = self.gregorian.dateFromComponents(firstDayOfStartMonth) else {
            return 0
        }
        
        startOfMonthCache = dateFromDayOneComponents
        
        let today = NSDate()
        if  startOfMonthCache.compare(today) == NSComparisonResult.OrderedAscending && endDateCache.compare(today) == NSComparisonResult.OrderedDescending {
            let differenceFromTodayComponents = self.gregorian.components([NSCalendarUnit.Month, NSCalendarUnit.Day], fromDate: startOfMonthCache, toDate: today, options: NSCalendarOptions())
            self.todayIndexPath = NSIndexPath(forItem: differenceFromTodayComponents.day, inSection: differenceFromTodayComponents.month)
        }
        let differenceComponents = self.gregorian.components(NSCalendarUnit.Month, fromDate: startDateCache, toDate: endDateCache, options: NSCalendarOptions())
        
        return differenceComponents.month + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
    }
    
    var monthInfo : [Int:[Int]] = [Int:[Int]]()
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let monthOffsetComponents = NSDateComponents()
        
        // offset by the number of months
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = self.gregorian.dateByAddingComponents(monthOffsetComponents, toDate: startOfMonthCache, options: NSCalendarOptions()) else {
            return 0
        }
        
        let numberOfDaysInMonth = self.gregorian.rangeOfUnit(.Day, inUnit: .Month, forDate: correctMonthForSectionDate).length
        
        var firstWeekdayOfMonthIndex = self.gregorian.component(NSCalendarUnit.Weekday, fromDate: correctMonthForSectionDate)
        firstWeekdayOfMonthIndex = firstWeekdayOfMonthIndex - 1 // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
        
        monthInfo[section] = [firstWeekdayOfMonthIndex, numberOfDaysInMonth]
        
        return NUMBER_OF_DAYS_IN_WEEK * MAXIMUM_NUMBER_OF_ROWS // 7 x 6 = 42
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCellWithReuseIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! CalendarDayCell
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]! // we are guaranteed an array by the fact that we reached this line (so unwrap)
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - fdIndex, inSection: indexPath.section) // if the first is wednesday, add 2
        
        if indexPath.item >= fdIndex && indexPath.item < fdIndex + nDays {
            dayCell.textLabel.text = String(fromStartOfMonthIndexPath.item + 1)
            dayCell.hidden = false
        } else {
            dayCell.textLabel.text = ""
            dayCell.hidden = true
        }
        
        dayCell.selected = selectedIndexPaths.contains(indexPath)
        
        if indexPath.section == 0 && indexPath.item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        if let idx = todayIndexPath {
            dayCell.isToday = (idx.section == indexPath.section && idx.item + fdIndex == indexPath.item)
        }
        
        if let eventsForDay = eventsByIndexPath[fromStartOfMonthIndexPath] {
            dayCell.eventsCount = eventsForDay.count
        } else {
            dayCell.eventsCount = 0
        }
        
        return dayCell
    }
    
    // Implementation of the UIScrollViewDelegate
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func calculateDateBasedOnScrollViewPosition(scrollView: UIScrollView) {
        let cvbounds = self.calendarView.bounds
        var page : Int = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        
        page = page > 0 ? page : 0
        
        let monthsOffsetComponents = NSDateComponents()
        monthsOffsetComponents.month = page
        
        guard let delegate = self.delegate else {
            return
        }
        
        guard let yearDate = self.gregorian.dateByAddingComponents(monthsOffsetComponents, toDate: self.startOfMonthCache, options: NSCalendarOptions()) else {
            return
        }
        
        let month = self.gregorian.component(NSCalendarUnit.Month, fromDate: yearDate) // get month
        let monthName = NSDateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = self.gregorian.component(NSCalendarUnit.Year, fromDate: yearDate)
        
        self.headerView.monthLabel.text = monthName + " " + String(year)
        self.displayDate = yearDate
        delegate.calendar(self, didScrollToMonth: yearDate)
    }
    
    // Implementation of the UICollectionViewDelegate
    private var dateBeingSelectedByUser : NSDate?
    
    func collectionView(collectionView: UICollectionView, shouldSelectItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        let firstDayInMonth = currentMonthInfo[FIRST_DAY_INDEX]
        let offsetComponents = NSDateComponents()
        offsetComponents.month = indexPath.section
        offsetComponents.day = indexPath.item - firstDayInMonth
        
        if let dateUserSelected = self.gregorian.dateByAddingComponents(offsetComponents, toDate: startOfMonthCache, options: NSCalendarOptions()) {
            dateBeingSelectedByUser = dateUserSelected
            // Optional protocol method (the delegate can "object")
            if let canSelectFromDelegate = delegate?.calendar(self, canSelectDate: dateUserSelected) {
                return canSelectFromDelegate
            }
            return true // it can select any date by default
        }
        return false // if date is out of scope
    }
    
    func selectDate(date : NSDate) {
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.selectedIndexPaths.contains(indexPath) == false else {
            return
        }
        
        self.calendarView.selectItemAtIndexPath(indexPath, animated: true, scrollPosition: .None)
        self.calendarView.reloadData()
        
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
    }
    
    // Modified by Inal Gotov
    func deselectDate(date : NSDate) {
        // Continue only if the given date exists in the calendar
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        // Continue only if the given date is selected
        guard self.selectedIndexPaths.contains(indexPath) == true else {
            return
        }
        // Deselect the date
        self.calendarView.deselectItemAtIndexPath(indexPath, animated: true)
        // Reload the calendar data
        self.calendarView.reloadData()
        // Find the index of the given date in the selectedDates and selectedIndexPaths array
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }
        
        // Remove the date from the selectedDates and selectedIndexPaths
        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
    }
    
    func indexPathForDate(date : NSDate) -> NSIndexPath? {
        let distanceFromStartComponent = self.gregorian.components( [.Month, .Day], fromDate:startOfMonthCache, toDate: date, options: NSCalendarOptions() )
        
        guard let currentMonthInfo : [Int] = monthInfo[distanceFromStartComponent.month] else {
            return nil
        }
        
        let item = distanceFromStartComponent.day + currentMonthInfo[FIRST_DAY_INDEX]
        let indexPath = NSIndexPath(forItem: item, inSection: distanceFromStartComponent.month)
        
        return indexPath
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        let currentMonthInfo : [Int] = monthInfo[indexPath.section]!
        let fromStartOfMonthIndexPath = NSIndexPath(forItem: indexPath.item - currentMonthInfo[FIRST_DAY_INDEX], inSection: indexPath.section)
        var eventsArray : [Event] = [Event]()
        
        if let eventsForDay = eventsByIndexPath[fromStartOfMonthIndexPath] {
            eventsArray = eventsForDay;
        }
        
        delegate?.calendar(self, didSelectDate: dateBeingSelectedByUser, withEvents: eventsArray)
        // Update model
        selectedIndexPaths.append(indexPath)
        selectedDates.append(dateBeingSelectedByUser)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        guard let index = selectedIndexPaths.indexOf(indexPath) else {
            return
        }
        
        delegate?.calendar(self, didDeselectDate: dateBeingSelectedByUser)
        selectedIndexPaths.removeAtIndex(index)
        selectedDates.removeAtIndex(index)
    }
    
    func reloadData() {
        self.calendarView.reloadData()
    }
    
    func setDisplayDate(date : NSDate, animated: Bool) {
        if let dispDate = self.displayDate {
            // skip is we are trying to set the same date
            if  date.compare(dispDate) == NSComparisonResult.OrderedSame {
                return
            }
            
            // check if the date is within range
            if  date.compare(startDateCache) == NSComparisonResult.OrderedAscending ||
                date.compare(endDateCache) == NSComparisonResult.OrderedDescending   {
                return
            }
        
            let difference = self.gregorian.components([NSCalendarUnit.Month], fromDate: startOfMonthCache, toDate: date, options: NSCalendarOptions())
            let distance : CGFloat = CGFloat(difference.month) * self.calendarView.frame.size.width
            self.calendarView.setContentOffset(CGPoint(x: distance, y: 0.0), animated: animated)
        }
    }
    
    // Extra Code from this point on
    func changeMonth (sender:UIButton!) {
        if sender.currentImage == UIImage(named: "LeftButton") {
            // Past
            self.setDisplayDate(self.calendar.dateByAddingUnit(.Month, value: -1, toDate: self.displayDate!, options: NSCalendarOptions.MatchFirst)!, animated: true)
        } else {
            // Future
            self.setDisplayDate(self.calendar.dateByAddingUnit(.Month, value: 1, toDate: self.displayDate!, options: NSCalendarOptions.MatchFirst)!, animated: true)
        }
    }
}
