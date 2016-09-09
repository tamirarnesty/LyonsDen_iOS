
//
//  HomeViewController.swift
//  LyonsDen
//
//  The HomeViewController class will be used for contrilling the home screen of the app
//
//  Created by Inal Gotov on 2016-06-30. edited by Tamir Arnesty
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//


import UIKit
import Firebase
var identifier:String?
var identifierIndex:Int?
var coursesData: [UIView]!
var labels:[[String]] = [["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"]]
var labelsDict:[String: [String]] = ["period1" : ["Name", "Code", "Teacher", "Room"]]
var defaultLabels = ["Name", "Code", "Teacher", "Room"]
var different = false
var updatePeriods:NSTimer?

class HomeViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem! // Menu button
    @IBOutlet var dayLabel: UILabel!                // The label representing the current day (1/2)
    @IBOutlet var scrollView: UIScrollView!         // The parent scroll view that holds it all. Still not configured completely
    @IBOutlet var tableList: UITableView!           // The table list holding all the announcements
    @IBOutlet var topViews: UIView!                 // The top views, above the table
    @IBOutlet var courses: [UIView]!                // The four period courses views
    @IBAction func returnToHome(returnSegue: UIStoryboardSegue) {}
    @IBOutlet var periodOneLabels: [UILabel]!
    @IBOutlet var periodTwoLabels: [UILabel]!
    @IBOutlet var periodThreeLabels: [UILabel]!
    @IBOutlet var periodFourLabels: [UILabel]!
    
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    var dayText = ""
    //var announcementTitlesInfos = [[String](), [String]()]
    //var announcementDatesLocations = [[String?](), [String?]()]
    // Reference to the database
    var ref:FIRDatabaseReference!
    
    // Didn't let me put it into announcements becuase its optional
    // To implement it, we might need a blank image to act in place of nil
    // -------------------------------------------------------------------------------- WE COULD MAKE IT A TRANSPARENT IMAGE ----------
    var images = [UIImage?]()
    var lastTableViewOffSet:CGFloat = 0.0
    var index = -1
    //var tapped:Int = 0
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // tap & hold gesture recognizers for courses views to segue to specific controllers.
        var longTaps = [UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:)))]
        for var i in 0...longTaps.count-1 {
            longTaps[i].delegate = self
            self.courses[i].addGestureRecognizer(longTaps[i])
        }
        
    }
    
    func periodUpdater () {
        //------- non period time gaps
        let y:CGFloat = 161.0
        let beforeSchoolView:UIView = UIView(frame: CGRectMake(3, y, 4, self.courses[0].frame.size.height))
        let lunchView:UIView = UIView(frame: CGRectMake(self.topViews.frame.size.width/2, y, 0.5, self.courses[0].frame.size.height))
        let afterSchoolView:UIView = UIView(frame: CGRectMake(self.topViews.frame.size.width-1, y, 0.5, self.courses[0].frame.size.height))
        beforeSchoolView.backgroundColor = accentColor
        lunchView.backgroundColor = accentColor
        afterSchoolView.backgroundColor = accentColor
        self.topViews.addSubview(beforeSchoolView); self.topViews.addSubview(lunchView); self.topViews.addSubview(afterSchoolView)
        beforeSchoolView.hidden = true
        lunchView.hidden = true
        afterSchoolView.hidden = true
        //--------- end
        
        
        //individual NSDates for each period. Day is same, time is different.
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let currentDate = NSDate()
        let periodOneComponents = NSDateComponents();
        periodOneComponents.hour = 08; periodOneComponents.minute = 45
        let periodTwoComponents = NSDateComponents();
        periodTwoComponents.hour = 10; periodTwoComponents.minute = 10
        let periodThreeComponents = NSDateComponents();
        periodThreeComponents.hour = 12; periodThreeComponents.minute = 30
        let periodFourComponents = NSDateComponents();
        periodFourComponents.hour = 13; periodFourComponents.minute = 50
        
        // non-period dates
        let lunchComponents = NSDateComponents();
        lunchComponents.hour = 11; lunchComponents.minute = 30
        let afterSchoolComponents = NSDateComponents();
        afterSchoolComponents.hour = 15; afterSchoolComponents.minute = 05
        
        // create dates from components
        let periodOne = calendar?.dateFromComponents(periodOneComponents)
        let periodTwo = calendar?.dateFromComponents(periodTwoComponents)
        let periodThree = calendar?.dateFromComponents(periodThreeComponents)
        let periodFour = calendar?.dateFromComponents(periodFourComponents)
        let lunch = calendar?.dateFromComponents(lunchComponents)
        let afterSchool = calendar?.dateFromComponents(afterSchoolComponents)
        
        
        var period = false
        var before = true; var duringLunch = false; var after = false
        
        let testComps = NSDateComponents()
        testComps.hour = 08; testComps.minute = 55
        let date = calendar?.dateFromComponents(testComps)
        
        var secondsBetween:NSTimeInterval = date!.timeIntervalSinceDate(periodOne!)
        print(currentDate.description)
        print("----------------" + String(secondsBetween))
        if date!.timeIntervalSinceDate(periodOne!) < 0 {
            period = false
            before = true
            print ("before school: " + String(date!.timeIntervalSinceDate(periodOne!)))
        } else if date!.timeIntervalSinceDate(periodOne!) >= 0 {
            period = true
            index = 0
            print ("period one: " + String(date!.timeIntervalSinceDate(periodOne!)))
        }
        
        if period && (before || duringLunch || after) {
            before = false; duringLunch = false; after = false
            beforeSchoolView.hidden = true; lunchView.hidden = true; afterSchoolView.hidden = true
            self.courses[index].backgroundColor = navigationBarColor
        } else {
            if !period {
                if before { beforeSchoolView.hidden = false }
                else if duringLunch { lunchView.hidden = false }
                else { if after { afterSchoolView.hidden = false }}
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the database
        ref = FIRDatabase.database().reference()
        // set date label to current day 1/2
        //self.parseForDay()
        self.parseForEvents(self.ref.child("announcements")) // download events data

        //----------- set up labels for courses
        if let tempLabels = NSUserDefaults.standardUserDefaults().objectForKey("labels") as? [[String]] {
            labels = tempLabels
            print (labels)
        }
        loadLabelsForViews()
        
        periodUpdater()
        updatePeriods = NSTimer.scheduledTimerWithTimeInterval(60, target: self, selector: #selector(periodUpdater), userInfo: nil, repeats: true)
        
        
        
        // Set the size of the scrollView
        scrollView.frame = view.bounds
        // Set the table's height to fill the screen, subtract 64pt for nav. bar
        tableList.constraints[0].constant = view.bounds.height - 64
        // Set the scrollable are size
        scrollView.contentSize = CGSizeMake(view.bounds.width, tableList.bounds.height + topViews.bounds.height)
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        for var i in 0...courses.count-1 {
            self.courses[i].layer.borderColor = UIColor.blackColor().CGColor
            self.courses[i].layer.borderWidth = 0.5
        }
        
               // For proper scrolling, didnt work :(
        //        setupGestures()
        
//        // Temporary, Table fill
//        for h in 0...37 {
//            announcementTitlesInfos [0].append("Title\(h + 1)")
//            announcementTitlesInfos [1].append("Description\(h + 1)")
//            announcementDatesLocations[0].append("Date\(h + 1)")
//            announcementDatesLocations[1].append("Location\(h + 1)")
//            if (h == 2 || h == 5) {
//                images.append(UIImage(named: "Splash"))
//            } else {
//                images.append(nil)
//            }
//        }
    }
    
    func loadLabelsForViews () {
        for var i in 0...courses.count-1 {
            for var x in 0...courses.count-1 {
                if i == 0 {
                    periodOneLabels[x].text = labels[i][x]
                } else if i == 1 {
                    periodTwoLabels[x].text = labels[i][x]
                } else if i == 2 {
                    periodThreeLabels[x].text = labels[i][x]
                } else {
                    periodFourLabels[x].text = labels[i][x]
                }
            }
        }
    }
    
    func getIndex (gesture: UIGestureRecognizer) -> Int {
        let value = ((gesture.view?.tag)!-1)
        return value
        
    }
    
    func handleLongTap (recognizer: UILongPressGestureRecognizer) {
        print("to edit")
        identifierIndex = getIndex(recognizer)
        performSegueWithIdentifier("periodEditorSegue", sender: self)
    }
    
    // Set number of items in table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    // Configure each item
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        
        cell.textLabel!.text = eventData[0][indexPath.row]
        cell.textLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        
        cell.detailTextLabel!.text = eventData[1][indexPath.row]
        cell.detailTextLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        return cell
    }
    
    // Set each item to segue into InfoViewController
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselct the selected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Prepare InfoViewController
        InfoViewController.setupViewController(title: eventData[0][indexPath.row]!,
                                               info: eventData[1][indexPath.row],
                                               date: eventData[0][indexPath.row],
                                               location: eventData[1][indexPath.row],
                                               image: images[indexPath.row])
        // Segue into InfoViewController
        performSegueWithIdentifier("AnnouncementSegue", sender: self)
    }
    
    
    
    // For proper scrolling, doesn't work all that well thoough :(
    
    //    func setupGestures () {
    //        let swipeUpGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeUp))
    //        swipeUpGesture.direction = UISwipeGestureRecognizerDirection.Up
    //        let swipeDownGesture = UISwipeGestureRecognizer(target: self, action: #selector(swipeDown))
    //        swipeDownGesture.direction = UISwipeGestureRecognizerDirection.Down
    //
    //        tableList.addGestureRecognizer(swipeUpGesture)
    //        tableList.addGestureRecognizer(swipeDownGesture)
    //    }
    //
    //    func swipeUp () {
    //        print ("I'm called")
    //        let offSet = tableList.contentOffset.y - self.offSet
    //        let tempHold = scrollView.contentOffset.y
    //        scrollView.contentOffset = CGPoint(x: 0, y: tempHold - offSet)
    //    }
    //
    //    func swipeDown () {
    //        print ("I'm called too")
    //        let offSet = tableList.contentOffset.y - self.offSet
    //        let tempHold = scrollView.contentOffset.y
    //        scrollView.contentOffset = CGPoint(x: 0, y: tempHold + offSet)
    //    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        //        print ("last off set = \(lastTableViewOffSet)")
        //
        //        let topViewsOffSet = self.scrollView.contentOffset.y
        //        let tableViewOffSet = scrollView.contentOffset.y
        //        lastTableViewOffSet = tableViewOffSet - lastTableViewOffSet
        //        self.scrollView.contentOffset = CGPointMake(0, topViewsOffSet - lastTableViewOffSet)
        //
        //        print ("top offset   = \(topViewsOffSet)")
        //        print ("table offset = \(tableViewOffSet)")
        //        print ("last off set = \(lastTableViewOffSet)")
        //        print ()
        //        let max = 0
    }
    
    func labelDidLoad() {
        dispatch_async(dispatch_get_main_queue()) {
            UIView.animateWithDuration(0.2, animations: {
                self.dayLabel.text = self.dayText
                self.dayLabel.alpha = 1
            })
        }
    }
    
    // day formats
    // DTSTART;VALUE=DATE:20170613
    // DTSTART:20130410T230000Z
    // DTSTART;TZID=America/Toronto:20110524T100000
    
    func parseForDay () {
        var day = "3"
        // The link from which the calendar is downloaded
        let url = NSURL (string: "https://calendar.google.com/calendar/ical/wlmacci%40gmail.com/public/basic.ics")!
        
        // The process of downloading and parsing the calendar
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) { (data, response, error) in
            
            let formats:[String] = [";VALUE=DATE:", ":", ";TZID=America/Toronto:"]
            // closures
            let formatDate:(NSString, Int) -> String = {(noFormat:NSString, index:Int) -> String in
                // fix dates yyyymmdd
                let formattedDate = noFormat.substringWithRange(NSMakeRange(0, 4)) + noFormat.substringWithRange(NSMakeRange(5, 2)) + noFormat.substringWithRange(NSMakeRange(8, 2))
                let finalDate = formats[index] + formattedDate
                
                return finalDate
            }
            
            
            // The following is simply a declaration and will not execute without the line 'task.resume()'
            if let URlContent = data {  // If Data has been loaded
                // If you got to this point then you've downloaded the calendar so...
                // Calendar File parsing starts here!!!
                // The string that holds the contents of the calendar's events
                let webContent:NSString = NSString(data: URlContent, encoding: NSUTF8StringEncoding)!
                
                // An array of flags used for locating the event fields
                // [h][0] - The flag that marks the begining of a field, [h][1] - The flag that marks the end of a field
                var searchTitles:[[String]] = [["DTSTART", "DTEND"], ["SUMMARY:", "TRANSP:"]]
                
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
                
                // Parse section to find event day info (1/2)
                OUTER:
                    for var i in 0...formats.count-1 {
                        searchTitles[0][0] += formatDate(NSDate().description, i)
                        INNER:
                            repeat {
                                range = updateRange(range)
                                // if end of file is reached
                                if NSEqualRanges(range, NSMakeRange(NSNotFound, 0)) {   // If there are no more events in the searching range
                                    if i == formats.count-1 {
                                        day = String(0)
                                        break OUTER;
                                    } else {
                                        break INNER; }                                            // Then no more shall be added (break from the loop)
                                }
                                
                                for x in 0...searchTitles.count-1 {
                                    fieldBoundaries = [NSRange]()
                                    fieldBoundaries.append(webContent.rangeOfString(searchTitles[x][0], options: NSStringCompareOptions.LiteralSearch, range: range))   // Find the begining flag
                                    fieldBoundaries.append(webContent.rangeOfString(searchTitles[x][1], options: NSStringCompareOptions.LiteralSearch, range: range))   // Find the ending flag
                                    var tempHold:NSString = webContent.substringWithRange(findDifference(fieldBoundaries[0], fieldBoundaries[1]))                         // Create a new string from whatever is in between the two flags. This will be the current field of the event
                                    tempHold = tempHold.stringByTrimmingCharactersInSet(NSCharacterSet.newlineCharacterSet())                                           // Remove all /r /n and other 'new line' characters from the event field
                                    tempHold = tempHold.stringByReplacingOccurrencesOfString("\u{005C}", withString: "", options: .LiteralSearch, range: NSMakeRange(0, tempHold.length-1))           // Replace all backslashes from the event field
                                    if x == 1 && tempHold.hasPrefix("DAY") {
                                        day = tempHold.substringWithRange(NSMakeRange(4, 1))
                                        print(day)
                                        break OUTER;
                                    }
                                }
                                
                        } while (true)
                        
                }
                self.dayText = day
                self.labelDidLoad()
            } else {
                //                let noDataAlert = UIAlertController () // tell them they have no data
                print("connect to data pls")
            }
        }
        task.resume()
    }
    
    // WORKS!!
    func parseForEvents (reference:FIRDatabaseReference) {
        // Navigate to and download the Events data
        reference.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the events
                let key = ["title", "description", "dateTime", "location"]
                for h in 0..<dataContent.count {
                    for j in 0..<key.count {
                        self.eventData[j].append(dataContent.objectAtIndex(h).objectForKey(key[j])?.description!)
                    }
                    self.images.append(nil) // Will be implemented later
                }
                // Reload the tableView to display the loaded data
                self.tableList.reloadData()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

