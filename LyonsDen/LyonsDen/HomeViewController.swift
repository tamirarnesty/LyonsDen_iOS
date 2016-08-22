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
var identifier:String?
var identifierIndex:Int?
var coursesData: [UIView]!
var labels:[[String]] = [["Name", "Code", "Teacher", "Room"],
                        ["Name", "Code", "Teacher", "Room"],
                        ["Name", "Code", "Teacher", "Room"],
                        ["Name", "Code", "Teacher", "Room"]]
var defaultLabels = ["Name", "Code", "Teacher", "Room"]
var different = false

class HomeViewController: UIViewController, UITableViewDelegate, UIGestureRecognizerDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem! // Menu button
    @IBOutlet var dayLabel: UILabel!                // The label representing the current day (1/2)
    @IBOutlet var scrollView: UIScrollView!         // The parent scroll view that holds it all. Still not configured completely
    @IBOutlet var tableList: UITableView!           // The table list holding all the announcements
    @IBOutlet var topViews: UIView!                 // The top views, above the table
    @IBOutlet var courses: [UIView]!                // The four period courses views
    @IBAction func returnToHome(returnSegue: UIStoryboardSegue) {}
    
    var announcementTitlesInfos = [[String](), [String]()]
    var announcementDatesLocations = [[String?](), [String?]()]
    
    // Didn't let me put it into announcements becuase its optional
    // To implement it, we might need a blank image to act in place of nil
    var images = [UIImage?]()
    var lastTableViewOffSet:CGFloat = 0.0
    var index = -1
    var tapped:Int = 0
    
    override func viewWillAppear(animated: Bool) {
        //----------- set up labels for courses
        if let tempLabels = NSUserDefaults.standardUserDefaults().objectForKey("labels") as? [[String]] {
            labels = tempLabels
            print (labels)
        }
        loadLabelsForViews()
        
        // tap & hold gesture recognizers for courses views to segue to specific controllers.
        var longTaps = [UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:))),
                        UILongPressGestureRecognizer(target: self, action: #selector(HomeViewController.handleLongTap(_:)))]
        var taps = [UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleTap(_:))),
                    UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleTap(_:))),
                    UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleTap(_:))),
                    UITapGestureRecognizer(target: self, action: #selector(HomeViewController.handleTap(_:)))]
        for var i in 0...longTaps.count-1 {
            longTaps[i].delegate = self
            taps[i].delegate = self
            courses[i].addGestureRecognizer(longTaps[i])
            courses[i].addGestureRecognizer(taps[i])
            
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        loadLabelsForViews()
        
        
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
        
//        var startDate:NSDate?
//        let dateCreator:NSDateComponents = NSDateComponents()
//        
//        let cal = NSCalendar(identifier: NSCalendarIdentifierGregorian)!    // Create a gregorian calendar
//        cal.timeZone = NSTimeZone(abbreviation: "UTC")!                     // Set it timezone to UTC format
//        dateCreator.year = 2016
//        dateCreator.month = 7
//        dateCreator.day = 28
//        dateCreator.hour = 11
//        dateCreator.minute = 35
//        dateCreator.second = 00
//        dateCreator.calendar = cal
//        startDate = dateCreator.date!
//        
////        let date = NSDate()
//        let calendar = NSCalendar.currentCalendar()
//        let components = calendar.components([.Minute, .Hour], fromDate: startDate!)
//        let minutes = components.minute
//        let hours = components.hour
//        let day = calendar.components(.Day, fromDate: startDate!).day
        
        
        //individual NSDates for each period. Day is same, time is different.
        let calendar = NSCalendar(identifier: NSCalendarIdentifierGregorian)
        let currentDate = NSDate()
        let currentDateComponents = NSDateComponents()
        let periodOneComponents = currentDateComponents; periodOneComponents.day = 1; periodOneComponents.month = 08; periodOneComponents.year = 2016; periodOneComponents.hour = 08; periodOneComponents.minute = 45
        let periodTwoComponents = currentDateComponents; periodTwoComponents.day = 1; periodTwoComponents.month = 08; periodTwoComponents.year = 2016; periodTwoComponents.hour = 10; periodTwoComponents.minute = 10
        let periodThreeComponents = currentDateComponents; periodThreeComponents.day = 1; periodThreeComponents.month = 08; periodThreeComponents.year = 2016; periodThreeComponents.hour = 12; periodThreeComponents.minute = 30
        let periodFourComponents = currentDateComponents; periodFourComponents.day = 1; periodFourComponents.month = 08; periodFourComponents.year = 2016; periodFourComponents.hour = 13; periodFourComponents.minute = 50
        let lunchComponents = currentDateComponents; lunchComponents.day = 1; lunchComponents.month = 08; lunchComponents.year = 2016; lunchComponents.hour = 11; lunchComponents.minute = 30
        let afterSchoolComponents = currentDateComponents; afterSchoolComponents.day = 1; afterSchoolComponents.month = 08; afterSchoolComponents.year = 2016; afterSchoolComponents.hour = 15; afterSchoolComponents.minute = 05
        
        let periodOne = calendar?.dateFromComponents(periodOneComponents)
        let periodTwo = calendar?.dateFromComponents(periodTwoComponents)
        let periodThree = calendar?.dateFromComponents(periodThreeComponents)
        let periodFour = calendar?.dateFromComponents(periodFourComponents)
        let lunch = calendar?.dateFromComponents(lunchComponents)
        let afterSchool = calendar?.dateFromComponents(afterSchoolComponents)
//        let periodOneStart = currentDateComponents
//        let periodOneEnd = currentDateComponents
//        let periodTwo = currentDateComponents
//        let periodThree = currentDateComponents
//        let periodFour = currentDateComponents
//        let afterSchool = currentDateComponents
//        let lunchTime = currentDateComponents
//        
//        // period 1
//        periodOneStart.hour = 08; periodOneStart.minute = 45
//        periodOneStart.day = 28; periodOneStart.year = currentDateComponents.year; periodOneStart.month = 7
//        periodOneEnd.hour = 10; periodOneEnd.minute = 10
//        periodOneEnd.day = 28; periodOneEnd.year = currentDateComponents.year; periodOneEnd.month = 7
//        // period 2
//        periodTwo.hour = 10; periodTwo.minute = 10
//        periodTwo.day = 28; periodTwo.year = currentDateComponents.year; periodTwo.month = 7
//        periodThree.hour = 12; periodThree.minute = 30
//        periodThree.day = 28; periodThree.year = currentDateComponents.year; periodThree.month = 7
//        periodFour.hour = 13; periodFour.minute = 50
//        periodFour.day = 28; periodFour.year = currentDateComponents.year; periodFour.month = 7
//
//        afterSchool.hour = 15; afterSchool.minute = 05
//        afterSchool.day = currentDateComponents.day; afterSchool.year = currentDateComponents.year; afterSchool.month = currentDateComponents.month
//        lunchTime.hour = 11; lunchTime.minute = 30
//        lunchTime.day = 28; lunchTime.year = currentDateComponents.year; lunchTime.month = 7
//        let periodOneDateStart = calendar?.dateFromComponents(periodOneStart)
//        let periodOneDateEnd = calendar?.dateFromComponents(periodOneEnd)
//        let periodTwoDate = calendar?.dateFromComponents(periodTwo)
//        let periodThreeDate = calendar?.dateFromComponents(periodThree)
//        let periodFourDate = calendar?.dateFromComponents(periodFour)
//        let afterSchoolDate = calendar?.dateFromComponents(afterSchool)
//        let lunchTimeDate = calendar?.dateFromComponents(lunchTime)
        
        var period = false
        var before = false; var duringLunch = false; var after = false
        //var wasActivated = [false, false, false, false, false, false, false]
        
        let components = NSDateComponents()
        components.day = 1; components.month = 08; components.year = 2016; components.hour = 10; components.minute = 45
        let date = calendar?.dateFromComponents(components)
        
//        let comps = calendar?.components([.Minute, .Hour], fromDate: date!)
//        let hours = comps!.hour
//        let minutes = comps!.minute
        
        //.OrderedAscending first date before second date
        //.OrderedDescending first date after second date
        
//        if periodOneDateStart!.compare(date!) == .OrderedAscending {
//            period = false; before = true
//            index = -1
//            print ("before school")
//        }
//        if periodOneDateStart!.compare(date!) == .OrderedAscending {
//            period = true
//            index = 0
//            print ("period one")
//         }
//        if date?.compare(periodTwoDate!) == .OrderedAscending {
//            period = true
//            index = 1
//            print ("period two")
//        }
        if date!.compare(periodOne!) == .OrderedAscending { // before school
            period = false; before = true
            print ("before school")
        }
        else if date!.compare(periodTwo!) == .OrderedAscending { // before period two (period one)
            period = true
            print ("period one")
        }
        else if date!.compare(lunch!) == .OrderedAscending { // before lunch (period two)
            period = true
            print ("period two")
        }
        else if date!.compare(periodThree!) == .OrderedAscending { // before period three (during lunch)
            period = false; duringLunch = true
            print ("period lunch")
        }
        else if date!.compare(periodFour!) == .OrderedAscending { // before period four
            period = true
            print ("period three")
        }
        else if date!.compare(afterSchool!) == .OrderedAscending { // before end of school (last period)
            period = true
            print ("period four")
        }
        else {
            if date!.compare(afterSchool!) == .OrderedDescending { // date is later than after school
                period = false; after = true
                print ("after school")
            }}
        
        if period && (before || duringLunch || after) {
            before = false; duringLunch = false; after = false
            beforeSchoolView.hidden = true; lunchView.hidden = true; afterSchoolView.hidden = true
        } else {
            if !period {
                if before { beforeSchoolView.hidden = false }
                else if duringLunch { lunchView.hidden = false }
                else { if after { afterSchoolView.hidden = false }}
            }
        }

//        if (date?.compare(periodOneDate!) == .OrderedAscending || date?.compare(periodOneDate!) == .OrderedSame){
//            period = true
//            index = 0
//            print ("period one")
////        }
//        if (date?.compare(periodTwoDate!) == .OrderedAscending || date?.compare(periodTwoDate!) == .OrderedSame) {
//            period = true
//            index = 1
//            print ("period two")
//        }
//        if (date?.compare(lunchTimeDate!) == .OrderedAscending || date?.compare(lunchTimeDate!) == .OrderedSame) {
//            period = false
//            index = -2
//            print ("lunch")
//        }
//        if (date?.compare(periodThreeDate!) == .OrderedAscending || date?.compare(periodThreeDate!) == .OrderedSame) {
//            period = true
//            index = 2
//            print ("period three")
//        }
//        if (date?.compare(periodFourDate!) == .OrderedAscending || date?.compare(periodFourDate!) == .OrderedSame) {
//            period = true
//            index = 3
//            print ("period four")
//        }
//        if (date?.compare(afterSchoolDate!) == .OrderedAscending || date?.compare(afterSchoolDate!) == .OrderedSame) {
//            period = false
//            index = -1
//            print ("after school")
//        }
        
//
//        
//        if date?.compare(periodOneDate!) == .OrderedAscending { // date is smaller than periodOneDate == so must be earlier than 8:45
//            if !wasActivated[0] {
//                period = false
//                wasActivated[0] = !wasActivated[0]
//                // start of day clear everything
//                for var i in 0...wasActivated.count {
//                    wasActivated[i] = false
//                }
//                index = -1
//                print ("before school")
//            }
//        } else if (date?.compare(periodFourDate!) == .OrderedAscending) && (date?.compare(afterSchoolDate!) == .OrderedDescending) {
//            if !wasActivated[5] {
//                period = true
//                wasActivated[5] = !wasActivated[5]
//                index = 3
//                print ("period four")
//            }
//        } else if (date?.compare(periodThreeDate!) == .OrderedAscending) && (date?.compare(periodFourDate!) == .OrderedDescending) {
//            if !wasActivated[4] {
//                period = true
//                wasActivated[4] = !wasActivated[4]
//                index = 2
//                print("period three")
//            }
//        } else if (date?.compare(lunchTimeDate!) == .OrderedAscending) && (date?.compare(periodThreeDate!) == .OrderedDescending) {
//            if !wasActivated[3] {
//                period = false
//                wasActivated[3] = !wasActivated[3]
//                index = -2
//                print("lunch")
//            }
//        } else if (date?.compare(periodTwoDate!) == .OrderedAscending) && (date?.compare(lunchTimeDate!) == .OrderedDescending) {
//            if !wasActivated[2] {
//                period = true
//                wasActivated[2] = !wasActivated[2]
//                index = 1
//                print ("period two")
//            }
//        } else if (date?.compare(periodOneDate!) == .OrderedAscending) && (date?.compare(periodTwoDate!) == .OrderedDescending) {
//            if !wasActivated[1] {
//                period = true
//                wasActivated[1] = !wasActivated[1]
//                index = 0
//                print ("period one")
//            }
//        } else {
//            if date?.compare(afterSchoolDate!) == .OrderedDescending {
//                if !wasActivated[6] {
//                    wasActivated[6] = !wasActivated[6]
//                    wasActivated[0] = !wasActivated[0]
//                    period = false
//                    index = -1
//                    print ("after school")
//                }
//            }
//        }
//        if hours >= 13 && minutes >= 50 {
//            period = true
//            index = 3
//            print ("fourth")
//        } else if hours >= 12 && minutes >= 30 {
//            period = true
//            index = 2
//            print ("third")
//        } else if (hours >= 10 && minutes >= 10) && (hours <= 11 && minutes < 30){
//            period = true
//            index = 1
//            print("third")
//        } else if (hours >= 8 && minutes >= 45) && (hours <= 10 && minutes < 5) {
//            period = true
//            index = 0
//            print ("first")
//        } else {
//            period = false
//            print ("not during class")
//        }
//        
//        if period && (before == true  || lunch == true || after == true) {
//            before = false; lunch = false; after = false
//            beforeSchoolView.hidden = true; lunchView.hidden = true; afterSchoolView.hidden = true
//        } else {
//            if hours <= 8 && minutes < 45 {
//                beforeSchoolView.hidden = false
//                index = -1
//                before = true
//                print("before")
//            } else if (hours >= 11 && minutes >= 30) && (hours <= 12 && minutes < 30){
//                lunchView.hidden = false
//                index = 0
//                print("lunch")
//            }else if hours >= 15 && minutes > 5 {
//                print("third")
//                afterSchoolView.hidden = false
//                index = -2
//            }
//        }
//        if day >= 2 && day <= 6 {
//            if hours >= 8 && minutes >= 45 {
//                if hours <= 10 && minutes <= 5 {
//                    index = 0
//                }
//            } else if hours >= 10 && minutes >= 10 {
//                if hours <= 11 && minutes < 30 {
//                    index = 1
//                }
//            } else if hours >= 11 && minutes >= 30 {
//                if hours <= 12 && minutes <= 30 {
//                    index = -2
//                }
//            } else if hours >= 12 && minutes >= 30 {
//                    if hours <= 13 && minutes <= 45 {
//                        index = 2
//                    }
//            } else if hours >= 13 && minutes >= 50 {
//                if hours <= 15 && minutes <= 5 {
//                    index = 3
//                }
//            } else {
//                index = -1
//            }
            var message = ""
            var go = false
            
            switch (index) {
            case -1:
                message = "School is not in session at the moment."
                go = true
                break
            case -2:
                message = "It's lunch time right now. Class resumes at 12:30."
                go = true
                break
            default:
                self.courses[index].backgroundColor = navigationBarColor
                break
            }
            
//            if go {
//                let alert = UIAlertController(title: "Alert", message: "This is an alert.", preferredStyle: .Alert) // 7
//                let defaultAction = UIAlertAction(title: "OK", style: .Default) { (alert: UIAlertAction!) -> Void in
//                    NSLog("You pressed button OK")
//                } // 8
//                
//                alert.addAction(defaultAction) // 9
//                self.presentViewController(alert, animated: true, completion:nil)  // 11
//            }
//        }
    
        // For proper scrolling, didnt work :(
//        setupGestures()
        
        // Temporary, Table fill
        for h in 0...37 {
            announcementTitlesInfos [0].append("Title\(h + 1)")
            announcementTitlesInfos [1].append("Description\(h + 1)")
            if (h == 2 || h == 5) {
                images.append(UIImage(named: "Splash"))
            } else {
                images.append(nil)
            }
        }
    }
    
    func loadLabelsForViews () {
        for var i in 0...courses.count-1 {
            for var x in 0...courses.count-1 {
                (courses[i].viewWithTag(x+1) as? UILabel)?.text = labels[i][x]
            }
//            (courses[i].viewWithTag(1) as? UILabel)?.text = labels[i][0]
//            (courses[i].viewWithTag(2) as? UILabel)?.text = labels[i][1]
//            (courses[i].viewWithTag(3) as? UILabel)?.text = labels[i][2]
//            (courses[i].viewWithTag(4) as? UILabel)?.text = labels[i][3]
        }
    }

    func getIndex (gesture: UIGestureRecognizer) -> Int {
        var temp:Int?
        let value = ((gesture.view?.tag)!-1)
        return value
        
    }
    
    func handleLongTap (recognizer: UILongPressGestureRecognizer) {
        print("to edit")
        identifierIndex = getIndex(recognizer)
//        let value = recognizer.view?.accessibilityIdentifier![(recognizer.view?.accessibilityIdentifier?.endIndex.advancedBy(-1))!]
        performSegueWithIdentifier("periodEditorSegue", sender: self)
    }
    
    func handleTap (recognizer: UITapGestureRecognizer) {
        print("to view")
        identifierIndex = getIndex(recognizer)
//        let value = recognizer.view?.accessibilityIdentifier![(recognizer.view?.accessibilityIdentifier?.endIndex.advancedBy(-1))!]
//        identifierIndex = Int(String(value))
//        for var x in 0...defaultLabels.count-1 {
//            if labels[tapped][x].compare(defaultLabels[x]) != .OrderedSame {
//                different = true
//            }
//        }
//        if !different {
//            self.performSegueWithIdentifier("periodEditorSegue", sender: self)
//            identifier = courses[tapped].accessibilityIdentifier
//        } else {
            //self.performSegueWithIdentifier("skipSegue", sender: self)
            different = false
//        }
        
    }
    

    // Set number of items in table
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return announcementTitlesInfos[0].count
    }
    
    // Configure each item
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        cell.textLabel!.text = announcementTitlesInfos[0][indexPath.row]
        cell.textLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.detailTextLabel!.text = announcementTitlesInfos[1][indexPath.row]
        cell.detailTextLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        return cell
    }

    // Set each item to segue into InfoViewController
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Prepare InfoViewController
        InfoViewController.setupViewController(title: announcementTitlesInfos[0][indexPath.row],
                                               info: announcementTitlesInfos[1][indexPath.row],
                                               date: announcementDatesLocations[0][indexPath.row],
                                               location: announcementDatesLocations[0][indexPath.row],
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

