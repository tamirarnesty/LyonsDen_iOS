
//
//  HomeViewController.swift
//  LyonsDen
//
//  The HomeViewController class will be used for contrilling the home screen of the app
//
//  Created by Inal Gotov on 2016-06-30. edited by Tamir Arnesty
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//


// TODO: Table goes off screen in iPhone 5
import UIKit
import Firebase

var identifierIndex:Int?

var labels:[[String]] = [["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"],
                         ["Name", "Code", "Teacher", "Room"]]
var defaultLabels = ["Name", "Code", "Teacher", "Room"]

class HomeViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem! // Menu button
    @IBOutlet var dayLabel: UILabel!                // The label representing the current day (1/2)
    @IBOutlet var scrollView: UIScrollView!         // The parent scroll view that holds it all. Still not configured completely
    @IBOutlet var tableList: UITableView!           // The table list holding all the announcements
    @IBOutlet var topViews: UIView!                 // The top views, above the table
    @IBOutlet var courses: [UIView]!                // The four period courses views
    @IBOutlet var periodOneLabels: [UILabel]!       // Labels for period 1 course
    @IBOutlet var periodTwoLabels: [UILabel]!       // Labels for period 2 course
    @IBOutlet var periodThreeLabels: [UILabel]!     // Labels for period 3 course
    @IBOutlet var periodFourLabels: [UILabel]!      // Labels for period 4 course
    
    
    static var updatePeriods:Timer?
    var refreshController:UIRefreshControl!
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    // Reference to the database
    var ref:FIRDatabaseReference!
    var gestureRecognizersAdded = false
    
    // Didn't let me put it into announcements becuase its optional
    // To implement it, we might need a blank image to act in place of nil
    // -------------------------------------------------------------------------------- WE COULD MAKE IT A TRANSPARENT IMAGE ----------
    var images = [UIImage?]()
    var lastTableViewOffset:CGFloat = 0.0
    var tableViewTouched = false
    var index = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        print ()
//        print ("view will really appear soon")
//        print ()
//        print (gestureRecognizersAdded)
//        print (self.courses[0].gestureRecognizers?.description)
//        print ("Adding gesture recognizer for")
        for i in 0...courses.count-1 {
//            print (i)
            if !gestureRecognizersAdded {
//                print ("Did add recognizer")
                self.courses[i].addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))))
            }
        }
        gestureRecognizersAdded = true
//        print ("many views")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up screen
//        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
//        swipeUp.direction = UISwipeGestureRecognizerDirection.up
//        swipeUp.addTarget(self, action: #selector(swipedUp))
//        self.view.addGestureRecognizer(swipeUp)
        periodUpdater()

        // set up announcements table
        //self.layoutTableView()
        //------- Initializing
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Initialize refresh controller
        refreshController = UIRefreshControl()
        refreshController.frame.size.height = 5
        refreshController.addTarget(self, action: #selector(reloadHome), for: .valueChanged)
        self.tableList.addSubview(refreshController)
        
        // set date label to current day 1/2
        //self.parseForDay()
        self.parseForEvents(self.ref.child("announcements")) // download events data

        //----------- set up labels for courses
        if let tempLabels = UserDefaults.standard.object(forKey: "labels") as? [[String]] {
            labels = tempLabels
        }
        loadLabelsForViews()
        
        HomeViewController.updatePeriods = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(periodUpdater), userInfo: nil, repeats: true)
        
        // Set the size of the scrollView
        scrollView.frame = view.bounds
        // Set the table's height to fill the screen, subtract 64pt for nav. bar
        tableList.constraints[0].constant = view.bounds.height - 64
        tableList.frame.size.height = view.bounds.height - topViews!.bounds.height
        
        // Set the scrollable are size
        scrollView.contentSize = CGSize(width: view.bounds.width, height: tableList.bounds.height + topViews.bounds.height)
        scrollView.isScrollEnabled = false
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        for i in 0...courses.count-1 {
            self.courses[i].layer.borderColor = UIColor.black.cgColor
            self.courses[i].layer.borderWidth = 0.5
        }
        
               // For proper scrolling, didnt work :(
        //        setupGestures()
        tableList.frame = self.view.bounds;
        
        dayLabel.alpha = 0
        
        // If a DayDictionary does not exist
        if UserDefaults.standard.dictionary(forKey: keyDayDictionary) == nil {
            // Calendar in which the events are going to be aligned in
            var calendar = Calendar(identifier: Calendar.Identifier.gregorian)
            calendar.timeZone = TimeZone(abbreviation: "EST")!
            // The Download Session
            let task = URLSession.shared.dataTask(with: URL(string: "https://calendar.google.com/calendar/ical/wlmacci%40gmail.com/public/basic.ics")!, completionHandler: { (data, response, error) in
                if let URLContent = data {
                    let calendarContent:NSString = NSString(data: URLContent, encoding: String.Encoding.utf8.rawValue)! // Declare downloaded content
                    CalendarViewController.parse(CalendarViewController())(calendarContent, inCalendar: calendar)       // Pass the content to the CalendarVC parses
                    self.dayLabelDidLoad(loadSuccess: true)                                                             // Notify about success of operation
                }
            })
            // Check for internet, this is where this method starts
            checkInternet(completionHandler: { (available, response) in
                if available {
                    task.resume()   // If internet is available then, download the dictionary
                } else {
                    self.dayLabelDidLoad(loadSuccess: false)    // If it is not, then notify about failure of operation
                }
            })
        } else {    // If a dictionary does exist, then it just does its thing
            self.dayLabelDidLoad(loadSuccess: true)
        }
    }
    
    // Called when the dayLabel is ready to be displayed
    func dayLabelDidLoad (loadSuccess:Bool) {
        DispatchQueue.main.async {
            if loadSuccess {    // If the Day of the day can be retrieved. then
                UIView.animate(withDuration: 0.2, animations: {
                    // Retrieve the Day of the day
                    var dayOfDay = (UserDefaults.standard.dictionary(forKey: keyDayDictionary))?[(Date().description as NSString).substring(to: 10)] as! String?
                    // If it is not a day, then declare the Day of the day as Day X
                    dayOfDay = (dayOfDay == nil) ? "X" : dayOfDay
                    // Set the day
                    self.dayLabel.text = dayOfDay
                    self.dayLabel.alpha = 1
                })
            } else {        // If not, then notify the user about it
                let toast = ToastView(inView: self.view, withText: "Could not retrieve the\nDay of the day!", andDuration: 2)
                self.view.addSubview(toast)
                toast.initiate()
            }
        }
    }

    func reloadHome () {
        // Clear events array to enter new Data
        self.eventData = [[String?](), [String?](), [String?](), [String?]()]
        // Reload data into events array
        self.parseForEvents(self.ref.child("announcements"))
        // Quit refreshing animation
        self.refreshController.endRefreshing()
    }
    
    func layoutTableView () {
        // set up tableview
        //tableList.autoresizingMask = [ UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        //tableList.tableFooterView = UIView(frame: CGRect.zero)
        
        let contentSize:CGSize = self.tableList.contentSize
        let boundsSize:CGSize = self.tableList.bounds.size
        var yOffset:CGFloat = 0
        if(contentSize.height < boundsSize.height) {
            yOffset = CGFloat((boundsSize.height - contentSize.height)/2);
        }
        self.tableList.contentOffset = CGPoint(x: 0, y: yOffset);
    }
    
    func periodUpdater () {
        //------- non period time gaps
        // create them
        let y:CGFloat = 161.0
        let beforeSchoolView:UIView = UIView(frame: CGRect(x: 3, y: y, width: 4, height: self.courses[0].frame.size.height))
        let lunchView:UIView = UIView(frame: CGRect(x: self.topViews.frame.size.width/2, y: y, width: 0.5, height: self.courses[0].frame.size.height))
        let afterSchoolView:UIView = UIView(frame: CGRect(x: self.courses[3].frame.size.width-3, y: 0, width: 0.5, height: self.courses[0].frame.size.height))
        
        // color them
        beforeSchoolView.backgroundColor = accentColor
        lunchView.backgroundColor = UIColor.red
        afterSchoolView.backgroundColor = UIColor.green
        
        // add them
        self.topViews.addSubview(beforeSchoolView)
        self.topViews.addSubview(lunchView)
        self.topViews.addSubview(afterSchoolView)
        
        // hide them
        beforeSchoolView.isHidden = true
        lunchView.isHidden = true
        afterSchoolView.isHidden = true
        //--------- end
        
        
        //individual NSDates for each period. Day is same, time is different.
        // Calendar time zone is currently EDT. CHANGED LATER DUE TO ISSUES
        var lyonsCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
        lyonsCalendar.timeZone = TimeZone(abbreviation: "EST")!
        var periodOneComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        periodOneComponents.hour = 8; periodOneComponents.minute = 45
        
//        print(periodOneComponents.description)
        var periodTwoComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        periodTwoComponents.hour = 10; periodTwoComponents.minute = 10
        var periodThreeComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        periodThreeComponents.hour = 12; periodThreeComponents.minute = 30
        var periodFourComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        periodFourComponents.hour = 13; periodFourComponents.minute = 50
//        print(periodOneComponents.description)
        
        // non-period dates
        var lunchComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        lunchComponents.hour = 11; lunchComponents.minute = 30
        var afterSchoolComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
//        print(periodOneComponents.description)
        afterSchoolComponents.hour = 15; afterSchoolComponents.minute = 05
        
        // create dates from components
//        print(periodOneComponents.description)
        
        let periodOne = lyonsCalendar.date(from: periodOneComponents)!
//        print(periodOne.description)
        let periodTwo = lyonsCalendar.date(from: periodTwoComponents)!
//        print(periodTwo.description)
        let periodThree = lyonsCalendar.date(from: periodThreeComponents)!
//        print(periodThree.description)
        let periodFour = lyonsCalendar.date(from: periodFourComponents)!
//        print(periodFour.description)
        let lunch = lyonsCalendar.date(from: lunchComponents)!
//        print(lunch.description)
        let afterSchool = lyonsCalendar.date(from: afterSchoolComponents)!
//        print(afterSchool.description)
        
        
        var period = false
        var before = false; var duringLunch = false; var after = false
        
        var todayComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        todayComponents.timeZone = TimeZone(abbreviation: "EST")!
//        todayComponents.hour = -3
        let today = lyonsCalendar.date(from: todayComponents)!
        
//        print(today.description)
//        print(todayComponents.timeZone)
//        print(today.timeIntervalSince(periodOne))
        // determines which part of the day it is based on Dates
            if today.timeIntervalSince(periodOne) < 0 { // ----
                period = false
                before = true
//                print ("before school")
            } else if today.timeIntervalSince(periodOne) >= 0 && today.timeIntervalSince(periodTwo) < 0 { // ----
                period = true
                index = 0
                print ("period one")
            } else if today.timeIntervalSince(periodTwo) >= 0 && today.timeIntervalSince(lunch) < 0 { // ----
                period = true
                index = 1
//                print ("period two")
            } else if today.timeIntervalSince(lunch) >= 0 && today.timeIntervalSince(periodThree) < 0 { // ----
                period = false
                duringLunch = true
//                print ("lunch")
            } else if today.timeIntervalSince(periodThree) >= 0 && today.timeIntervalSince(periodFour) < 0 { // ----
                period = true
                index = 2
//                print ("period three")
            } else if today.timeIntervalSince(periodFour) >= 0 && today.timeIntervalSince(afterSchool) < 0 { // ----
                period = true
                index = 3
//                print ("period four")
            } else if today.timeIntervalSince(periodFour) >= 0 { // ----
                period = false
                after = true
//                print ("after school")
            }
        
        
        
        if period {
            if (before || duringLunch || after) {
                before = false; duringLunch = false; after = false
            }
            beforeSchoolView.isHidden = true; lunchView.isHidden = true; afterSchoolView.isHidden = true
            self.courses[index].backgroundColor = navigationBarColor
        } else {
            if !period {
                if before { beforeSchoolView.isHidden = false }
                else if duringLunch { lunchView.isHidden = false }
                else { if after { afterSchoolView.isHidden = false }
//                print("done")
                }
            }
        }
    }
    
    // Loads the text into each of the period views
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
    
    // Returns the index of the view that was tapped on
    func getIndex (_ gesture: UILongPressGestureRecognizer) -> Int {
        let value = ((gesture.view?.tag)!-1)
        return value
        
    }
    
    // Called when there is a long press on one of the period views
    func handleLongTap (_ recognizer: UILongPressGestureRecognizer) {
//        print("to edit")
        identifierIndex = getIndex(recognizer)
//        print("once/twice")
        performSegue(withIdentifier: "periodEditorSegue", sender: nil)
    }
    
    // Set number of items in table
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    func numberOfSectionsInTableView(_ tableView: UITableView) -> Int {
        return 1
    }

    
    // Configure each item
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "Cell")

//        var bg:UIColor = UIColor(hue: 0.8111, saturation: 0.04, brightness: 0.5, alpha: 1.0) /* #fdf4ff */
//        bg = UIColor(red: 0.9922, green: 0.9569, blue: 1, alpha: 1.0) /* #fdf4ff */
        cell.backgroundColor = colorTextFieldBackground.withAlphaComponent(0.8)

//cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        
        cell.textLabel!.text = eventData[0][(indexPath as NSIndexPath).row]!
        cell.textLabel!.textColor = colorWhiteText
        //cell.textLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)

        cell.detailTextLabel!.text = eventData[1][(indexPath as NSIndexPath).row]!
        cell.detailTextLabel!.textColor = colorWhiteText
        //cell.detailTextLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        return cell
    }
    
    // Set each item to segue into InfoViewController
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselct the selected cell
        tableView.deselectRow(at: indexPath, animated: true)
        // Prepare InfoViewController
        InfoViewController.setupViewController(title: eventData[0][(indexPath as NSIndexPath).row]!,
                                               info: eventData[1][(indexPath as NSIndexPath).row],
                                               date: eventData[0][(indexPath as NSIndexPath).row],
                                               location: eventData[1][(indexPath as NSIndexPath).row],
                                               image: images[(indexPath as NSIndexPath).row])
        // Segue into InfoViewController
        performSegue(withIdentifier: "AnnouncementSegue", sender: self)
    }

// MARK: DEBUGGING
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        print ("        TableViewOffset: \(scrollView.contentOffset.y)")
//        print ("         TopViewsHeight: \(self.topViews.frame.height)")
//        print ("       ScrollViewOffset: \(self.scrollView.contentOffset.y)")
//        print ("ScrollViewContentHeight: \(self.scrollView.contentSize.height)")
//        print ("      ScrollViewYOrigin: \(self.scrollView.frame.origin.y)")
        
        // Find the amount by which the tableView was scrolled
        let deltaTableOffset = lastTableViewOffset - scrollView.contentOffset.y
        
        // If tableView is not being overscrolled
        if scrollView.contentOffset.y > 0 && scrollView.contentOffset.y < scrollView.frame.height {
            // If scrolling up and not overscrolling scrollView
            if deltaTableOffset < 0 && self.scrollView.contentOffset.y < self.topViews.frame.height - 64 {   // Swipe down
//                print ("Scrolling up")
                // Scroll the scrollView
                if self.scrollView.contentOffset.y - deltaTableOffset > self.topViews.frame.height - 64 {
//                    print ("Adjusting Overflow")
                    self.scrollView.contentOffset.y = self.topViews.frame.height - 64
                } else {
                    self.scrollView.contentOffset.y -= deltaTableOffset
                }
                
            // If scrolling down and not overscrolling scrollView
            } else if deltaTableOffset > 0 && self.scrollView.contentOffset.y > -64 {    // Swipe up
//                print ("Scrolling down")
                // Scroll the scrollView
                if self.scrollView.contentOffset.y - deltaTableOffset < -64 {
//                    print ("Adjusting Overflow")
                    self.scrollView.contentOffset.y = -64
                } else {
                    self.scrollView.contentOffset.y -= deltaTableOffset
                }
            }
        }
        // Prepare for next call
        lastTableViewOffset = scrollView.contentOffset.y
//        print ()
    }
    
    /* The parseForEvents method loads announcements specifically from Firebase.
     The announcement events are loaded into eventData which is used to enter information into the UITableView
     
     @param reference - FIRDatabaseReference to get the events needed.
     */
    func parseForEvents (_ reference:FIRDatabaseReference) {
        // Navigate to and download the Events data
        reference.queryOrdered(byChild: "dateTime").observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the events
                let key = ["title", "description", "dateTime", "location"]
                for h in 0..<dataContent.count {
                    for j in 0..<key.count {
                        self.eventData[j].append(((dataContent.object(at: h) as AnyObject).object(forKey: key[j]) as! NSString).description)
                    }
                    self.images.append(nil) // Will be implemented later
                }
                // Reverse data in array so it is by newest created date
                for i in 0..<self.eventData.count {
                    self.eventData[i].reverse()
                }
                
                for h in 0..<40 {
                    for j in 0..<key.count {
                        self.eventData[j].append("This is an extra \(j)")
                    }
                }
                // Reload the tableView to display the loaded data
                self.tableList.reloadData()
                //self.layoutTableView()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
}

