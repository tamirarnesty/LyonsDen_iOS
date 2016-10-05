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
    var expandedCell:ListExpandableCell? = nil {
        willSet (newValue) {
            expandedCell?.isExpanded = !(expandedCell?.isExpanded)!
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize refresh controller
        refreshController = UIRefreshControl()
        refreshController.frame.size.height = 5
        refreshController.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.tableView.addSubview(refreshController)
        
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.view.backgroundColor = colorBackground
        
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
    
    func refreshList () {
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
        let parseTime:(String) -> String = { (input) in
            var output = input
            output.insert("-", at: output.characters.index(output.startIndex, offsetBy: 4))
            output.insert("-", at: output.characters.index(output.startIndex, offsetBy: 7))
            output.insert(" ", at: output.characters.index(output.startIndex, offsetBy: 10))
            output.insert(":", at: output.characters.index(output.startIndex, offsetBy: 13))
            output = output.substring(to: output.characters.index(output.startIndex, offsetBy: 16))
            
            return output
        }
        
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
                        if j == 2 { self.eventData[j].append(parseTime (((dataContent.object(at: h) as AnyObject!).object(forKey: key[j]) as AnyObject!).description)) }
                        else { self.eventData[j].append(((dataContent.object(at: h) as AnyObject!).object(forKey: key[j]) as AnyObject!).description) }
                    }
                    self.images.append(nil) // Will be implemented later
                }
                // Reverse data in array so it is by newest created date
                for i in 0..<self.eventData.count {
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
        if ListViewController.displayContent != 3 && expandedCell != nil && tableView.cellForRow(at: indexPath) == expandedCell {
            return 148.0
        }
        return 44.0
    }
    
    
    // Configure each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListExpandableCell(style: .default, reuseIdentifier: "ListCell", index: indexPath.row, creatorWidth: tableView.frame.width) { (index) in
            // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
            InfoViewController.setupViewController(title: self.eventData[0][index]!,          // Give it a title to display
                info: self.eventData[1][index]!,           // Give it a description to display
                date: self.eventData[2][index],        // Give it a date to display
                location: self.eventData[3][index],    // Give it a location to display
                image: self.images[index])                    // Give it an image to display
            // Segue into InfoViewController
            self.performSegue(withIdentifier: "InfoSegue", sender: nil)
        }
        
        cell.tag = indexPath.row
        cell.titleLabel.text = eventData[0][indexPath.row]!              // Set the Title Text
        cell.descriptionLabel.text = eventData[1][indexPath.row]!        // Set the Description Text
        cell.dateLabel.text = eventData[2][indexPath.row]
        return cell                                                         // Return the cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue into the appropriate ViewController
        if ListViewController.displayContent == 3 {
            // Prepare ClubViewController, if nil is passed for image, then constraints are remade appropriately
            ClubViewController.setupClubViewController(withTitle: self.eventData[0][indexPath.row]!,    // Club Title
                description: self.eventData[1][(indexPath as NSIndexPath).row]!,  // Club Description
                clubLeads: self.eventData[2][(indexPath as NSIndexPath).row]!,    // Club Leaders
                clubImage: self.images[(indexPath as NSIndexPath).row],           // Club Image
                andEvents: self.ref.child("clubs").child(self.clubKeys[indexPath.row]))   // Database reference to the club
            // Segue into ClubViewController
            self.performSegue(withIdentifier: "ClubSegue", sender: nil)
        } else {
            (tableView.cellForRow(at: indexPath) as! ListExpandableCell).isExpanded = !(tableView.cellForRow(at: indexPath) as! ListExpandableCell).isExpanded
            expandedCell = tableView.cellForRow(at: indexPath) as! ListExpandableCell!
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
