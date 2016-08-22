//
//  ClubViewController.swift
//  LyonsDen
//
//  This class will be used to display information about a certain club
//
//  Created by Inal Gotov on 2016-07-28.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Firebase

class ClubViewController: UIViewController, UITableViewDelegate {
    static var image:UIImage?       // The image of the club
    static var title:String!        // The title of the club
    static var info:String!         // The description of the club
    static var clubLeads:String!    // A list of club leaders
    static var eventsRef:FIRDatabaseReference!  // The database reference to the club's announcements
    // The content of each announcements
    //       Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // This will hold a database reference to the member list
    var ref:FIRDatabaseReference!
    
    @IBOutlet var clubImageView: UIImageView!   // UIImageView for the club
    @IBOutlet var clubTitleView: UILabel!       // Title UILabel for the club
    @IBOutlet var clubInfoVoew: UILabel!        // Description UILabel for the club
    @IBOutlet var clubLeadsView: UILabel!       // A UILabel of club leaders
    @IBOutlet var tableView: UITableView!       // A UITableView of club announcements
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set all the necessary information before displaying this ViewController
        clubTitleView.text = ClubViewController.title
        clubInfoVoew.text = ClubViewController.info
        clubLeadsView.text = "Club Leads: " + ClubViewController.clubLeads
        
        // Set the member list database reference
        self.ref = FIRDatabase.database().reference().child("clubs").child(ClubViewController.title).child("members")
        
        // Set Image/Title contraint appropriately
        if let img = ClubViewController.image {     // If an announcemnt image is present
            clubImageView.image = img       // Set the image
            // Move the title label to the side, if not already moved (Removes the additional constraint)
            self.view.removeConstraint(NSLayoutConstraint(item: clubTitleView.superview!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: clubTitleView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -8))
            clubImageView.hidden = false    // Show the image
        } else {    // If not announcement image is present
            clubImageView.hidden = true     // Hide the image just in case
            // Move the title label to the left side (Add an additional constraint)
            self.view.addConstraint(NSLayoutConstraint(item: clubTitleView.superview!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: clubTitleView, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -8))
        }
        
        // Download club announcements data
        parseForEvents(ClubViewController.eventsRef)
    }
    
    // Downloads club announcements data
    func parseForEvents (reference:FIRDatabaseReference) {
        // Navigate to and download the Events data
        reference.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the events
                for h in 0...dataContent.count-1 {
                    self.eventData[0].append(dataContent.objectAtIndex(h).objectForKey("title")! as! String)
                    self.eventData[1].append(dataContent.objectAtIndex(h).objectForKey("description")! as! String)
                    self.eventData[2].append((dataContent.objectAtIndex(h).objectForKey("dateTime")! as! NSNumber).description)
                    self.eventData[3].append(dataContent.objectAtIndex(h).objectForKey("location")! as! String)
                    self.images.append(nil) // Will be implemented later
                }
                // Reload the tableView to display the loaded data
                self.tableView.reloadData()
            } else {
                print ("There has been an error")
                // Will handle errors
            }
        })
    }
    
    // This method must be called prior to segueing into this class
    static func setupClubViewController (withTitle title:String, description:String, clubLeads:String, clubImage:UIImage?, andEvents eventsRef:FIRDatabaseReference) {
        ClubViewController.title = title
        ClubViewController.info = description
        ClubViewController.clubLeads = clubLeads
        ClubViewController.image = clubImage
        ClubViewController.eventsRef = eventsRef
    }
    
    // This method is called whener the MemberList button is pressed
    @IBAction func displayMembers(sender: UIButton) {
        // A holder for the member list
        var memberList = [[String](), [String]()]
        // Initiate the download of the member list
        self.ref.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if snapshot.exists() {  // If download succesful
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the events
                for h in 0...dataContent.count-1 {
                    memberList[0].append(dataContent.objectAtIndex(h) as! String)
                    memberList[1].append("")
                }
                // Prepare the PeopleList to display the member of this club
                PeopleList.setupPeopleList(withContent: memberList, andTitle: "\(ClubViewController.title) Members")
                // Segue into PeopleList
                self.performSegueWithIdentifier("MemberListSegue", sender: self)
            } else {
                print ("There has been an error")
            }
        })
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "ListCell")   // Declare the cell
        cell.backgroundColor = foregroundColor                              // Set the Background Color
        cell.imageView?.image = images[indexPath.row]                       // Set the Cell Image
        
        cell.textLabel?.text = eventData[0][indexPath.row]              // Set the Title Text
        cell.textLabel?.textColor = accentColor                             // Set the Title Text Color
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 20)         // Set the Title Text Font
        
        cell.detailTextLabel?.text = eventData[1][indexPath.row]        // Set the Description Text
        cell.detailTextLabel?.textColor = accentColor                       // Set the Description Text Color
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 16)   // Set the Description Text Font
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
        InfoViewController.setupViewController(title: eventData[0][indexPath.row]!,          // Give it a title to display
            info: eventData[1][indexPath.row]!,           // Give it a description to display
            date: eventData[2][indexPath.row],        // Give it a date to display
            location: eventData[3][indexPath.row],    // Give it a location to display
            image: images[indexPath.row])                    // Give it an image to display
        // Deselect the selected cell
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        // Segue into InfoViewController
        performSegueWithIdentifier("ClubInfoSegue", sender: nil)
    }
}
