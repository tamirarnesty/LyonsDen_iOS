//
//  HomeViewController.swift
//  LyonsDen
//
//  The HomeViewController class will be used for contrilling the home screen of the app
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//




import UIKit

class HomeViewController: UIViewController, UITableViewDelegate {
    @IBOutlet weak var menuButton: UIBarButtonItem! // Menu button
    @IBOutlet var dayLabel: UILabel!                // The label representing the current day (1/2)
    @IBOutlet var scrollView: UIScrollView!         // The parent scroll view that holds it all. Still not configured completely
    @IBOutlet var tableList: UITableView!           // The table list holding all the announcements
    @IBOutlet var topViews: UIView!                 // The top views, above the table
    
    var announcementTitlesInfos = [[String](), [String]()]
    var announcementDatesLocations = [[String?](), [String?]()]
    
    // Didn't let me put it into announcements becuase its optional
    // To implement it, we might need a blank image to act in place of nil
    var images = [UIImage?]()
    var lastTableViewOffSet:CGFloat = 0.0

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        // For proper scrolling, didnt work :(
//        setupGestures()
        
        // Temporary, Table fill
        for h in 0...37 {
            announcementTitlesInfos [0].append("Title\(h + 1)")
            announcementTitlesInfos [1].append("Description\(h + 1)")
            announcementDatesLocations[0].append("Date\(h + 1)")
            announcementDatesLocations[1].append("Location\(h + 1)")
            if (h == 2 || h == 5) {
                images.append(UIImage(named: "Splash"))
            } else {
                images.append(nil)
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
        // Deselct the selected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Prepare InfoViewController
        InfoViewController.setupViewController(title: announcementTitlesInfos[0][indexPath.row],
                                               info: announcementTitlesInfos[1][indexPath.row],
                                               date: announcementDatesLocations[0][indexPath.row],
                                               location: announcementDatesLocations[1][indexPath.row],
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
}

