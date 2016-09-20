
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
var updatePeriods:Timer?

class HomeViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem! // Menu button
    @IBOutlet var dayLabel: UILabel!                // The label representing the current day (1/2)
    @IBOutlet var scrollView: UIScrollView!         // The parent scroll view that holds it all. Still not configured completely
    @IBOutlet var tableList: UITableView!           // The table list holding all the announcements
    @IBOutlet var topViews: UIView!                 // The top views, above the table
    @IBOutlet var courses: [UIView]!                // The four period courses views
    @IBAction func returnToHome(_ returnSegue: UIStoryboardSegue) {}
    @IBOutlet var periodOneLabels: [UILabel]!
    @IBOutlet var periodTwoLabels: [UILabel]!
    @IBOutlet var periodThreeLabels: [UILabel]!
    @IBOutlet var periodFourLabels: [UILabel]!
    
    
    var refreshController:UIRefreshControl!
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    var dayText = ""
    // Reference to the database
    var ref:FIRDatabaseReference!
    
    // Didn't let me put it into announcements becuase its optional
    // To implement it, we might need a blank image to act in place of nil
    // -------------------------------------------------------------------------------- WE COULD MAKE IT A TRANSPARENT IMAGE ----------
    var images = [UIImage?]()
    var lastTableViewOffSet:CGFloat = 0.0
    var index = -1
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // tap & hold gesture recognizers for courses views to segue to specific controllers.
//        var longTaps = [UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
//                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
//                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
//                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:)))]
        for var i in 0...courses.count-1 {
            self.courses[i].addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))))
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set up screen
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(swipedUp))
        swipeUp.direction = UISwipeGestureRecognizerDirection.up
        swipeUp.addTarget(self, action: #selector(swipedUp))
        self.view.addGestureRecognizer(swipeUp)
        periodUpdater()

        // set up announcements table
        //self.layoutTableView()
        //------- Initializing
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Initialize refresh controller
        refreshController = UIRefreshControl()
        refreshController.frame.size.height = 10
        refreshController.addTarget(self, action: #selector(reloadHome), for: .valueChanged)

        // set date label to current day 1/2
        //self.parseForDay()
        self.parseForEvents(self.ref.child("announcements")) // download events data

        //----------- set up labels for courses
        if let tempLabels = UserDefaults.standard.object(forKey: "labels") as? [[String]] {
            labels = tempLabels
        }
        loadLabelsForViews()
        
        updatePeriods = Timer.scheduledTimer(timeInterval: 60, target: self, selector: #selector(periodUpdater), userInfo: nil, repeats: true)
        
        // Set the size of the scrollView
        scrollView.frame = view.bounds
        // Set the table's height to fill the screen, subtract 64pt for nav. bar
        tableList.constraints[0].constant = view.bounds.height - 64
        // Set the scrollable are size
        scrollView.contentSize = CGSize(width: view.bounds.width, height: tableList.bounds.height + topViews.bounds.height)
        scrollView.isScrollEnabled = false
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        for var i in 0...courses.count-1 {
            self.courses[i].layer.borderColor = UIColor.black.cgColor
            self.courses[i].layer.borderWidth = 0.5
        }
        
               // For proper scrolling, didnt work :(
        //        setupGestures()
        tableList.frame = self.view.bounds;

        
    }
    
    func swipedUp (_ up: UISwipeGestureRecognizer) {
        self.view.resignFirstResponder()
    }
    
    func reloadHome () {
        
        print ("refreshed")
        
        self.refreshController.endRefreshing()
    }
    
    func layoutTableView () {
        // set up tableview
        tableList.autoresizingMask = [ UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        tableList.tableFooterView = UIView(frame: CGRect.zero)
        
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
        let afterSchoolView:UIView = UIView(frame: CGRect(x: (self.topViews.frame.size.width/2)*2, y: y, width: 0.5, height: self.courses[0].frame.size.height))
        
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
        var periodOneComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        periodOneComponents.hour = 8; periodOneComponents.minute = 45
        
        print(periodOneComponents.description)
        var periodTwoComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        periodTwoComponents.hour = 10; periodTwoComponents.minute = 10
        var periodThreeComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        periodThreeComponents.hour = 12; periodThreeComponents.minute = 30
        var periodFourComponents =  lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        periodFourComponents.hour = 13; periodFourComponents.minute = 50
        print(periodOneComponents.description)
        
        // non-period dates
        var lunchComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        lunchComponents.hour = 11; lunchComponents.minute = 30
        var afterSchoolComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        print(periodOneComponents.description)
        afterSchoolComponents.hour = 15; afterSchoolComponents.minute = 05
        
        // create dates from components
        print(periodOneComponents.description)
        // CALENDAR TIME ZONE IS CHANGED TO GMT TO PREVENT ISSUES
        lyonsCalendar.timeZone = TimeZone(abbreviation: "GMT")!
        let periodOne = lyonsCalendar.date(from: periodOneComponents)!
        print(periodOne.description)
        let periodTwo = lyonsCalendar.date(from: periodTwoComponents)!
        print(periodTwo.description)
        let periodThree = lyonsCalendar.date(from: periodThreeComponents)!
        print(periodThree.description)
        let periodFour = lyonsCalendar.date(from: periodFourComponents)!
        print(periodFour.description)
        let lunch = lyonsCalendar.date(from: lunchComponents)!
        print(lunch.description)
        let afterSchool = lyonsCalendar.date(from: afterSchoolComponents)!
        print(afterSchool.description)
        
        
        var period = false
        var before = false; var duringLunch = false; var after = false
        
        var todayComponents = lyonsCalendar.dateComponents([.year, .month, .day, .hour, .minute], from: Date())
        todayComponents.timeZone = TimeZone(abbreviation: "GMT")!
        todayComponents.hour = -3
        let today = lyonsCalendar.date(from: todayComponents)!
        
        print(today.description)
        print(todayComponents.timeZone)
        print(today.timeIntervalSince(periodOne))
        // determines which part of the day it is based on Dates
            if today.timeIntervalSince(periodOne) < 0 { // ----
                period = false
                before = true
                print ("before school")
            } else if today.timeIntervalSince(periodOne) >= 0 && today.timeIntervalSince(periodTwo) < 0 { // ----
                period = true
                index = 0
                print ("period one")
            } else if today.timeIntervalSince(periodTwo) >= 0 && today.timeIntervalSince(lunch) < 0 { // ----
                period = true
                index = 1
                print ("period two")
            } else if today.timeIntervalSince(lunch) >= 0 && today.timeIntervalSince(periodThree) < 0 { // ----
                period = false
                duringLunch = true
                print ("lunch")
            } else if today.timeIntervalSince(periodThree) >= 0 && today.timeIntervalSince(periodFour) < 0 { // ----
                period = true
                index = 2
                print ("period three")
            } else if today.timeIntervalSince(periodFour) >= 0 && today.timeIntervalSince(afterSchool) < 0 { // ----
                period = true
                index = 3
                print ("period four")
            } else if today.timeIntervalSince(periodFour) >= 0 { // ----
                period = false
                after = true
                print ("after school")
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
                print("done")}
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
        print("to edit")
        identifierIndex = getIndex(recognizer)
        performSegue(withIdentifier: "periodEditorSegue", sender: self)
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

        var bg:UIColor = UIColor(hue: 0.8111, saturation: 0.04, brightness: 0.5, alpha: 1.0) /* #fdf4ff */
        bg = UIColor(red: 0.9922, green: 0.9569, blue: 1, alpha: 1.0) /* #fdf4ff */
        cell.backgroundColor = bg

//cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        
        cell.textLabel!.text = eventData[0][(indexPath as NSIndexPath).row]!
        cell.textLabel!.textColor = UIColor.blue
        //cell.textLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)

        cell.detailTextLabel!.text = eventData[1][(indexPath as NSIndexPath).row]!
        cell.detailTextLabel!.textColor = UIColor.blue
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.2, animations: {
                self.dayLabel.text = self.dayText
                self.dayLabel.alpha = 1
            })
        }
    }
    
    // day formats
    // DTSTART;VALUE=DATE:20170613
    // DTSTART:20130410T230000Z
    // DTSTART;TZID=America/Toronto:20110524T100000
    
        
    /* The parseForEvents method loads announcements specifically from Firebase.
     The announcement events are loaded into eventData which is used to enter information into the UITableView
     
     @param reference - FIRDatabaseReference to get the events needed.
     */
    func parseForEvents (_ reference:FIRDatabaseReference) {
        // Navigate to and download the Events data
        reference.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
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
                // Reload the tableView to display the loaded data
                try! self.tableList.reloadData()
                //self.layoutTableView()
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

