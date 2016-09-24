//
//  ListViewController.swift
//  LyonsDen
//
//  The ListViewController class will be used for displaying the list of Clubs or Events.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Firebase

// TODO: IMLPEMENT PULL TO REFRESH

class ListViewController: UITableViewController {
    // The menu button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    static var displayContent = 0
    
    static var contentChanged = false
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // Reference to the database
    var ref:FIRDatabaseReference!
    // Refresh Controller to update data in screen
    var refreshController: UIRefreshControl!
                        //       Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    var clubKeys:[String] = [String]()
    var loadingWheel:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize refresh controller
        refreshController = UIRefreshControl()
        refreshController.frame.size.height = 5
        refreshController.addTarget(self, action: #selector(reloadHome), for: .valueChanged)
        self.tableView.addSubview(refreshController)
        
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.view.backgroundColor = backgroundColor
        
        loadingWheel.center.x = self.view.center.x
        loadingWheel.center.y = self.view.center.y
        webContentWillLoad()
        
        
        let titles = ["Announcements", "Events", "Clubs"]
        self.title = titles[ListViewController.displayContent - 1]
        if ListViewController.displayContent == 3 {
            parseForClubs()
        } else {
            parseForEvents(self.ref.child((ListViewController.displayContent == 1) ? "announcements" : "events"))    // Download events data
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ListViewController.contentChanged {
            ListViewController.contentChanged = false
            webContentWillLoad()
            parseForClubs()
        }
    }
    
    func reloadHome () {
        
        print ("refreshed")
        // Clear events array to enter new Data
        self.eventData = [[String?](), [String?](), [String?](), [String?]()]
        // Reload data into events array
        if ListViewController.displayContent == 3 {
            parseForClubs()
        } else {
            parseForEvents(self.ref.child((ListViewController.displayContent == 1) ? "announcements" : "events"))    // Download events data
        }        // Quit refreshing animation
        self.refreshController.endRefreshing()
    }

    
    static func formatTime (_ time:NSString) -> String {
        var output:NSString = ""
        output = (output.appending(time.substring(to: 4)) + "-") as NSString
        output = output.appending(time.substring(with: NSMakeRange(4, 2)) + "-") as NSString
        output = output.appending(time.substring(with: NSMakeRange(6, 2))) as NSString
        if time.substring(with: NSMakeRange(8, 4)) != "2400" {
            output = output.appending(" " + time.substring(with: NSMakeRange(8, 2)) + ":") as NSString
            output = output.appending(time.substring(with: NSMakeRange(10, 2))) as NSString
        }
        return output as String
    }
    
    func webContentWillLoad () {
        self.tableView.isHidden = true
        self.clubKeys.removeAll()
        for h in 0..<eventData.count { eventData[h].removeAll() }
        loadingWheel.startAnimating()
    }
    
    func webContentDidLoad () {
        self.tableView.isHidden = false
        loadingWheel.stopAnimating()
    }
    
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
                        self.eventData[j].append(((dataContent.object(at: h) as AnyObject!).object(forKey: key[j]) as AnyObject!).description)
                    }
                    self.images.append(nil) // Will be implemented later
                }
                // Reverse data in array so it is by newest created date
                for var i in 0..<self.eventData.count {
                    self.eventData[i].reverse()
                }
                // Reload the tableView to display the loaded data
                self.tableView.reloadData()
                self.webContentDidLoad()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    func parseForClubs () {
        // Navigate to and download the Clubs data
        self.ref.child("clubs").queryOrderedByKey().observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the clubs
                let key = ["title", "description", "leads"]
                for h in 0...dataContent.count - 1 {
                    self.clubKeys.append((dataContent.object(at: h) as AnyObject).object(forKey: "key")! as! String)
                    
                    for j in 0..<key.count {
                        self.eventData[j].append((dataContent.object(at: h) as AnyObject).object(forKey: key[j])! as! String)
                    }
                    
                    self.images.append(nil)
                }
                // Reload the tableView to display the loaded data
                self.tableView.reloadData()
                self.webContentDidLoad()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    // Set the number of cell the table will display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    // Set the height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    // Configure each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListCell")   // Declare the cell
        cell.backgroundColor = foregroundColor                              // Set the Background Color
        cell.imageView?.image = images[(indexPath as NSIndexPath).row]                       // Set the Cell Image
        
        cell.textLabel?.text = eventData[0][(indexPath as NSIndexPath).row]!              // Set the Title Text
        cell.textLabel?.textColor = accentColor                             // Set the Title Text Color
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 20)         // Set the Title Text Font
        
        cell.detailTextLabel?.text = eventData[1][(indexPath as NSIndexPath).row]!        // Set the Description Text
        cell.detailTextLabel?.textColor = accentColor                       // Set the Description Text Color
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 16)   // Set the Description Text Font
        return cell                                                         // Return the cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Deselect the selected cell
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue into the appropriate ViewController
        if ListViewController.displayContent == 3 {
            // Prepare ClubViewController, if nil is passed for image, then constraints are remade appropriately
            ClubViewController.setupClubViewController(withTitle: self.eventData[0][(indexPath as NSIndexPath).row]!,    // Club Title
                                                       description: self.eventData[1][(indexPath as NSIndexPath).row]!,  // Club Description
                                                       clubLeads: self.eventData[2][(indexPath as NSIndexPath).row]!,    // Club Leaders
                                                       clubImage: self.images[(indexPath as NSIndexPath).row],           // Club Image
                                                       andEvents: self.ref.child("clubs").child(clubKeys[(indexPath as NSIndexPath).row]))   // Database reference to the club
            // Segue into ClubViewController
            performSegue(withIdentifier: "ClubSegue", sender: nil)
        } else {
            // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
            InfoViewController.setupViewController(title: eventData[0][(indexPath as NSIndexPath).row]!,          // Give it a title to display
                                                   info: eventData[1][(indexPath as NSIndexPath).row]!,           // Give it a description to display
                                                   date: eventData[2][(indexPath as NSIndexPath).row],        // Give it a date to display
                                                   location: eventData[3][(indexPath as NSIndexPath).row],    // Give it a location to display
                                                   image: images[(indexPath as NSIndexPath).row])                    // Give it an image to display
            // Segue into InfoViewController
            performSegue(withIdentifier: "InfoSegue", sender: nil)
        }
    }
}
