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
//  Commented and Modified by Inal Gotov

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


// The protocol(Interface) that is used to define a DataSource for this Calendar
protocol CalendarViewDataSource {
    func startDate() -> Date? // Method that determines the start date of the current month
    func endDate() -> Date?   // Method that determines the end date of the current month
}

// The protocol(Interface) that is used to define a Delegate(User Interaction Handler) for this Calendar
protocol CalendarViewDelegate {
    func calendar(_ calendar : CalendarView, canSelectDate date : Date) -> Bool        // Returns true if the current date can be selected
    func calendar(_ calendar : CalendarView, didScrollToMonth date : Date) -> Void              // Called when the month is scrolled
    func calendar(_ calendar : CalendarView, didSelectDate date : Date, withEvents events: [Event]) -> Void   // Called when a date is selected
    func calendar(_ calendar : CalendarView, didDeselectDate date : Date) -> Void      // Called when a date has been deselected
}


// This class handles the calendar view
class CalendarView: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    var dataSource  : CalendarViewDataSource?   // The Data Soutce Object of the calendar. Must be set from the outside
    var delegate    : CalendarViewDelegate?     // The User Interaction Handler Object. Must be set from the outside
    
    // calView = CalendarView
    
    // A gregorian version of this calView's NSCalendar
    lazy var gregorian : Calendar = {
        var cal = Calendar(identifier: Calendar.Identifier.gregorian)   // Create a gregorian calendar
        cal.timeZone = TimeZone(abbreviation: "EST")!                     // Set it timezone to UTC format
        return cal
    }()
    
    // The actual calendar that is used for this calView
    var calendar : Calendar {
        return self.gregorian
    }
    
    // The scrolling direction of this calView
    var direction : UICollectionViewScrollDirection = .horizontal {
        // If this calendar has a layout, set the direction of that layout to the direction of this calView
        didSet {
            if let layout = self.calendarView.collectionViewLayout as? CalendarFlowLayout {
                layout.scrollDirection = direction
                self.calendarView.reloadData()
            }
        }
    }
    
    fileprivate var startDateCache : Date = Date()      // The start date of this calView
    fileprivate var endDateCache : Date = Date()        // The end date of this calView
    fileprivate var startOfMonthCache : Date = Date()   // The ????????????????????????????
    fileprivate var todayIndexPath : IndexPath?           // The index of today's date
    var displayDate : Date?                           // The current date that is displayed
    
    fileprivate(set) var selectedIndexPaths : [IndexPath] = [IndexPath]()   // An array containing the indexes of the selected dates
    fileprivate(set) var selectedDates : [Date] = [Date]()                  // An array containing the selected dates
    
    fileprivate var eventsByIndexPath : [IndexPath:[Event]] = [IndexPath:[Event]]() // A dictionary containing an array of Events for a given NSIndexPath
    
    // The event bank for this calendar
    var events : [Event]? {
        didSet {
            // Recreate the eventsByindexPath bank
            eventsByIndexPath = [IndexPath:[Event]]()
            
            // If there are events then continue
            guard let events = events else {
                return
            }
            
            // This holds the difference in seconds between the current timezone and GMT
            let secondsFromGMTDifference = TimeInterval(NSTimeZone.local.secondsFromGMT())
            // For each event...
            for event in events {
                // Declare the search/create flags
                let flags: NSCalendar.Unit = [NSCalendar.Unit.month, NSCalendar.Unit.day]
                // Determine the start date in GMT
                let startDate = event.startDate!.addingTimeInterval(secondsFromGMTDifference)
                // Get the distance of the event from the start of the month
                let distanceFromStartComponent = (self.gregorian as NSCalendar).components( flags, from:startOfMonthCache, to: startDate as Date, options: NSCalendar.Options() )
                // Create the indexPath of the event
                let indexPath = IndexPath(item: distanceFromStartComponent.day! + 1, section: distanceFromStartComponent.month!)
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
        let hv = CalendarHeaderView(frame:CGRect.zero)
        return hv
    }()
    
    // This holds a UICollectionView for this calView
    lazy var calendarView : UICollectionView = {
        let layout = CalendarFlowLayout()           // Creates a layout for this collection view
        layout.scrollDirection = self.direction;    // Sets its scrolling direction
        layout.minimumInteritemSpacing = 0          // Sets the minimum spacing between each item
        layout.minimumLineSpacing = 0               // Sets the minimum spacing between each line (row, i think)
        
        let cv = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)  // Creates the collection view itslef
        cv.dataSource = self                        // Sets its Data Source
        cv.delegate = self                          // Sets its Delegate (User Interaction Handler)
        cv.isPagingEnabled = true                   // Makes it pageable
        cv.backgroundColor = UIColor.clear          // Makes its background transparent
        // Hides scrolling indicators
        cv.showsHorizontalScrollIndicator = false
        cv.showsVerticalScrollIndicator = false
        
        cv.allowsMultipleSelection = true           // Allows users to select multiple items at a time
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
            layout.itemSize = CGSize(width: width / CGFloat(NUMBER_OF_DAYS_IN_WEEK), height: heigh / CGFloat(MAXIMUM_NUMBER_OF_ROWS))  // Set the size of each item
        }
    }
    
    // Create a new calView with size 200x200 at (0, 0)
    override init(frame: CGRect) {
        super.init(frame : CGRect(x: 0.0, y: 10.0, width: 200.0, height: 200.0))
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
    fileprivate func initialSetup() {
        self.clipsToBounds = true   // Makes sure that this calView's subviews dont go beyond the calView's boundaries
        // Register the Class in the collection view (what?)
        self.calendarView.register(CalendarDayCell.self, forCellWithReuseIdentifier: cellReuseIdentifier)
        self.addSubview(self.headerView)    // Add the header
        self.addSubview(self.calendarView)  // Add the calendar
    }
    
    // Implementation of the UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        guard let startDate = self.dataSource?.startDate(), let endDate = self.dataSource?.endDate() else {
            return 0
        }
        
        startDateCache = startDate
        endDateCache = endDate
        
        // check if the dates are in correct order
        if (self.gregorian as NSCalendar).compare(startDate, to: endDate, toUnitGranularity: .nanosecond) != ComparisonResult.orderedAscending {
            return 0
        }
        
        var firstDayOfStartMonth = (self.gregorian as NSCalendar).components( [.era, .year, .month], from: startDateCache)
        firstDayOfStartMonth.day = 1
        
        guard let dateFromDayOneComponents = self.gregorian.date(from: firstDayOfStartMonth) else {
            return 0
        }
        
        startOfMonthCache = dateFromDayOneComponents
        
        let today = Date()
        if  startOfMonthCache.compare(today) == ComparisonResult.orderedAscending && endDateCache.compare(today) == ComparisonResult.orderedDescending {
            let differenceFromTodayComponents = (self.gregorian as NSCalendar).components([NSCalendar.Unit.month, NSCalendar.Unit.day], from: startOfMonthCache, to: today, options: NSCalendar.Options())
            self.todayIndexPath = IndexPath(item: differenceFromTodayComponents.day!, section: differenceFromTodayComponents.month!)
        }
        let differenceComponents = (self.gregorian as NSCalendar).components(NSCalendar.Unit.month, from: startDateCache, to: endDateCache, options: NSCalendar.Options())
        
        return differenceComponents.month! + 1 // if we are for example on the same month and the difference is 0 we still need 1 to display it
    }
    
    var monthInfo : [Int:[Int]] = [Int:[Int]]()
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        var monthOffsetComponents = DateComponents()
        
        // offset by the number of months
        monthOffsetComponents.month = section;
        
        guard let correctMonthForSectionDate = (self.gregorian as NSCalendar).date(byAdding: monthOffsetComponents, to: startOfMonthCache, options: NSCalendar.Options()) else {
            return 0
        }
        
        let numberOfDaysInMonth = (self.gregorian as NSCalendar).range(of: .day, in: .month, for: correctMonthForSectionDate).length
        
        var firstWeekdayOfMonthIndex = (self.gregorian as NSCalendar).component(NSCalendar.Unit.weekday, from: correctMonthForSectionDate)
        firstWeekdayOfMonthIndex = firstWeekdayOfMonthIndex - 1 // firstWeekdayOfMonthIndex should be 0-Indexed
        firstWeekdayOfMonthIndex = (firstWeekdayOfMonthIndex + 6) % 7 // push it modularly so that we take it back one day so that the first day is Monday instead of Sunday which is the default
        
        monthInfo[section] = [firstWeekdayOfMonthIndex, numberOfDaysInMonth]
        
        return NUMBER_OF_DAYS_IN_WEEK * MAXIMUM_NUMBER_OF_ROWS // 7 x 6 = 42
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dayCell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as! CalendarDayCell
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]! // we are guaranteed an array by the fact that we reached this line (so unwrap)
        let fdIndex = currentMonthInfo[FIRST_DAY_INDEX]
        let nDays = currentMonthInfo[NUMBER_OF_DAYS_INDEX]
        let fromStartOfMonthIndexPath = IndexPath(item: (indexPath as NSIndexPath).item - fdIndex, section: (indexPath as NSIndexPath).section) // if the first is wednesday, add 2
        
        if (indexPath as NSIndexPath).item >= fdIndex && (indexPath as NSIndexPath).item < fdIndex + nDays {
            dayCell.textLabel.text = String((fromStartOfMonthIndexPath as NSIndexPath).item + 1)
            dayCell.isHidden = false
        } else {
            dayCell.textLabel.text = ""
            dayCell.isHidden = true
        }
        
        dayCell.isSelected = selectedIndexPaths.contains(indexPath)
        
        if (indexPath as NSIndexPath).section == 0 && (indexPath as NSIndexPath).item == 0 {
            self.scrollViewDidEndDecelerating(collectionView)
        }
        if let idx = todayIndexPath {
            dayCell.isToday = ((idx as NSIndexPath).section == (indexPath as NSIndexPath).section && (idx as NSIndexPath).item + fdIndex == (indexPath as NSIndexPath).item)
        }
        
        if eventsByIndexPath[fromStartOfMonthIndexPath] != nil {
            dayCell.containsEvent = true
        } else {
            dayCell.containsEvent = false
        }
        
        return dayCell
    }
    
    // Implementation of the UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        self.calculateDateBasedOnScrollViewPosition(scrollView)
    }
    
    func calculateDateBasedOnScrollViewPosition(_ scrollView: UIScrollView) {
        let cvbounds = self.calendarView.bounds
        var page : Int = Int(floor(self.calendarView.contentOffset.x / cvbounds.size.width))
        
        page = page > 0 ? page : 0
        
        var monthsOffsetComponents = DateComponents()
        monthsOffsetComponents.month = page
        
        guard let delegate = self.delegate else {
            return
        }
        
        guard let yearDate = (self.gregorian as NSCalendar).date(byAdding: monthsOffsetComponents, to: self.startOfMonthCache, options: NSCalendar.Options()) else {
            return
        }
        
        let month = (self.gregorian as NSCalendar).component(NSCalendar.Unit.month, from: yearDate) // get month
        let monthName = DateFormatter().monthSymbols[(month-1) % 12] // 0 indexed array
        let year = (self.gregorian as NSCalendar).component(NSCalendar.Unit.year, from: yearDate)
        
        self.headerView.monthLabel.text = monthName + " " + String(year)
        self.displayDate = yearDate
        delegate.calendar(self, didScrollToMonth: yearDate)
    }
    
    // Implementation of the UICollectionViewDelegate
    fileprivate var dateBeingSelectedByUser : Date?
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]!
        let firstDayInMonth = currentMonthInfo[FIRST_DAY_INDEX]
        var offsetComponents = DateComponents()
        offsetComponents.month = (indexPath as NSIndexPath).section
        offsetComponents.day = (indexPath as NSIndexPath).item - firstDayInMonth
        
        if let dateUserSelected = (self.gregorian as NSCalendar).date(byAdding: offsetComponents, to: startOfMonthCache, options: NSCalendar.Options()) {
            dateBeingSelectedByUser = dateUserSelected
            // Optional protocol method (the delegate can "object")
            if let canSelectFromDelegate = delegate?.calendar(self, canSelectDate: dateUserSelected) {
                return canSelectFromDelegate
            }
            return true // it can select any date by default
        }
        return false // if date is out of scope
    }
    
    func selectDate(_ date : Date) {
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        
        guard self.selectedIndexPaths.contains(indexPath) == false else {
            return
        }
        
        self.calendarView.selectItem(at: indexPath, animated: true, scrollPosition: UICollectionViewScrollPosition())
        self.calendarView.reloadData()
        
        selectedIndexPaths.append(indexPath)
        selectedDates.append(date)
    }
    
    // Modified by Inal Gotov
    func deselectDate(_ date : Date) {
        // Continue only if the given date exists in the calendar
        guard let indexPath = self.indexPathForDate(date) else {
            return
        }
        // Continue only if the given date is selected
        guard self.selectedIndexPaths.contains(indexPath) == true else {
            return
        }
        // Deselect the date
        self.calendarView.deselectItem(at: indexPath, animated: true)
        // Reload the calendar data
        self.calendarView.reloadData()
        // Find the index of the given date in the selectedDates and selectedIndexPaths array
        guard let index = selectedIndexPaths.index(of: indexPath) else {
            return
        }
        
        // Remove the date from the selectedDates and selectedIndexPaths
        selectedIndexPaths.remove(at: index)
        selectedDates.remove(at: index)
    }
    
    func indexPathForDate(_ date : Date) -> IndexPath? {
        let distanceFromStartComponent = (self.gregorian as NSCalendar).components( [.month, .day], from:startOfMonthCache, to: date, options: NSCalendar.Options() )
        
        guard let currentMonthInfo : [Int] = monthInfo[distanceFromStartComponent.month!] else {
            return nil
        }
        
        let item = distanceFromStartComponent.day! + currentMonthInfo[FIRST_DAY_INDEX]
        let indexPath = IndexPath(item: item, section: distanceFromStartComponent.month!)
        
        return indexPath
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        let currentMonthInfo : [Int] = monthInfo[(indexPath as NSIndexPath).section]!
        let fromStartOfMonthIndexPath = IndexPath(item: (indexPath as NSIndexPath).item - currentMonthInfo[FIRST_DAY_INDEX], section: (indexPath as NSIndexPath).section)
        var eventsArray : [Event] = [Event]()
        
        if let eventsForDay = eventsByIndexPath[fromStartOfMonthIndexPath] {
            eventsArray = eventsForDay;
        }
        
        delegate?.calendar(self, didSelectDate: dateBeingSelectedByUser, withEvents: eventsArray)
        // Update model
        selectedIndexPaths.append(indexPath)
        selectedDates.append(dateBeingSelectedByUser)
    }
    
    func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        guard let dateBeingSelectedByUser = dateBeingSelectedByUser else {
            return
        }
        
        guard let index = selectedIndexPaths.index(of: indexPath) else {
            return
        }
        
        delegate?.calendar(self, didDeselectDate: dateBeingSelectedByUser)
        selectedIndexPaths.remove(at: index)
        selectedDates.remove(at: index)
    }
    
    func reloadData() {
        self.calendarView.reloadData()
    }
    
    func setDisplayDate(_ date : Date, animated: Bool) {
        if let dispDate = self.displayDate {
            // skip is we are trying to set the same date
            if  date.compare(dispDate) == ComparisonResult.orderedSame {
                return
            }
            
            // check if the date is within range
            if  date.compare(startDateCache) == ComparisonResult.orderedAscending ||
                date.compare(endDateCache) == ComparisonResult.orderedDescending   {
                return
            }
        
            let difference = (self.gregorian as NSCalendar).components([NSCalendar.Unit.month], from: startOfMonthCache, to: date, options: NSCalendar.Options())
            let distance : CGFloat = CGFloat(difference.month!) * self.calendarView.frame.size.width
            self.calendarView.setContentOffset(CGPoint(x: distance, y: 0.0), animated: animated)
        }
    }
    
    // Extra Code from this point on
    func changeMonth (_ sender:UIButton!) {
        if sender.tag == 0 {
            // Past
            self.setDisplayDate((self.calendar as NSCalendar).date(byAdding: .month, value: -1, to: self.displayDate!, options: NSCalendar.Options.matchFirst)!, animated: true)
        } else {
            // Future
            self.setDisplayDate((self.calendar as NSCalendar).date(byAdding: .month, value: 1, to: self.displayDate!, options: NSCalendar.Options.matchFirst)!, animated: true)
        }
    }
}
