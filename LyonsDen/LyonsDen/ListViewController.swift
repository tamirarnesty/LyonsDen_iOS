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

class ListViewController: UITableViewController {
    // The menu button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    static var displayContent = 0
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // Reference to the database
    var ref:FIRDatabaseReference!
                        //       Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        
        let titles = ["Announcements", "Events", "Clubs"]
        self.title = titles[ListViewController.displayContent - 1]
        if ListViewController.displayContent == 3 {
            parseForClubs()
        } else {
            parseForEvents(self.ref.child((ListViewController.displayContent == 1) ? "announcements" : "events"))    // Download events data
        }
    }
    
    static func formatTime (time:NSString) -> String {
        var output:NSString = ""
        output = output.stringByAppendingString(time.substringToIndex(4)) + "-"
        output = output.stringByAppendingString(time.substringWithRange(NSMakeRange(4, 2)) + "-")
        output = output.stringByAppendingString(time.substringWithRange(NSMakeRange(6, 2)))
        if time.substringWithRange(NSMakeRange(8, 4)) != "2400" {
            output = output.stringByAppendingString(" " + time.substringWithRange(NSMakeRange(8, 2)) + ":")
            output = output.stringByAppendingString(time.substringWithRange(NSMakeRange(10, 2)))
        }
        return output as String
    }
    
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
                self.tableView.reloadData()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    func parseForClubs () {
        // Navigate to and download the Clubs data
        self.ref.child("clubs").observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the clubs
                let key = ["title", "description", "leads"]
                for h in 0...dataContent.count - 1 {
                    for j in 0..<key.count {
                        self.eventData[j].append(dataContent.objectAtIndex(h).objectForKey(key[j])! as! String)
                    }
                    self.images.append(nil)
                }
                // Reload the tableView to display the loaded data
                self.tableView.reloadData()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    // Set the number of cell the table will display
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    // Set the height of each cell
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    // Configure each cell
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "ListCell")   // Declare the cell
        cell.backgroundColor = foregroundColor                              // Set the Background Color
        cell.imageView?.image = images[indexPath.row]                       // Set the Cell Image
        
        cell.textLabel?.text = eventData[0][indexPath.row]!              // Set the Title Text
        cell.textLabel?.textColor = accentColor                             // Set the Title Text Color
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 20)         // Set the Title Text Font
        
        cell.detailTextLabel?.text = eventData[1][indexPath.row]!        // Set the Description Text
        cell.detailTextLabel?.textColor = accentColor                       // Set the Description Text Color
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 16)   // Set the Description Text Font
        return cell                                                         // Return the cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Deselect the selected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Segue into the appropriate ViewController
        if ListViewController.displayContent == 3 {
            // Prepare ClubViewController, if nil is passed for image, then constraints are remade appropriately
            ClubViewController.setupClubViewController(withTitle: self.eventData[0][indexPath.row]!,    // Club Title
                                                       description: self.eventData[1][indexPath.row]!,  // Club Description
                                                       clubLeads: self.eventData[2][indexPath.row]!,    // Club Leaders
                                                       clubImage: self.images[indexPath.row],           // Club Image
                                                       andEvents: self.ref.child("clubs").child(eventData[0][indexPath.row]!).child("announcements"))   // Database reference to the club's announcements
            // Segue into ClubViewController
            performSegueWithIdentifier("ClubSegue", sender: nil)
        } else {
            // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
            InfoViewController.setupViewController(title: eventData[0][indexPath.row]!,          // Give it a title to display
                                                   info: eventData[1][indexPath.row]!,           // Give it a description to display
                                                   date: eventData[2][indexPath.row],        // Give it a date to display
                                                   location: eventData[3][indexPath.row],    // Give it a location to display
                                                   image: images[indexPath.row])                    // Give it an image to display
            // Segue into InfoViewController
            performSegueWithIdentifier("InfoSegue", sender: nil)
        }
    }
}
