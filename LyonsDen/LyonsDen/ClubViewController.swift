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

// TODO: IMPLEMENT ANNOUNCEMENT ADDING
// TODO: CHANGE BACKGROUND UNDER TABLEVIEW
// TODO: HIDE KEYBOARD AFTER EDITING IS COMPLETE

class ClubViewController: UIViewController, UITableViewDelegate {
    static var image:UIImage?       // The image of the club
    static var title:String!        // The title of the club
    static var info:String!         // The description of the club
    static var clubLeads:String!    // A list of club leaders
    static var ref:FIRDatabaseReference!  // The database reference to the club
    // The content of each announcements
    //                           Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // States if the current user can edit this page
    var userIsLead = false {
        didSet {
            if userIsLead {
                navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(enterEditMode))
            }
        }
    }
    
    //@IBOutlet var titleField: UITextField!
    @IBOutlet var titleField: UITextView!       // Title UITextField for editing the club title
    @IBOutlet var descriptionField: UITextView! // Description UITextView for editing the club description
    @IBOutlet var clubImageView: UIImageView!   // UIImageView for the club
    @IBOutlet var clubTitleView: UILabel!       // Title UILabel for the club
    @IBOutlet var clubInfoView: UILabel!        // Description UILabel for the club
    @IBOutlet var clubLeadsView: UILabel!       // A UILabel of club leaders
    @IBOutlet var tableView: UITableView!       // A UITableView of club announcements
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set all the necessary information before displaying this ViewController
        clubTitleView.text = ClubViewController.title
        clubInfoView.text = ClubViewController.info
        clubLeadsView.text = "Club Leads: " + ClubViewController.clubLeads
        
        clubImageView.image = ClubViewController.image       // Set the image
        
        // Just in case, if the current user has permission to edit this page, then display the edit button
        if userIsLead { userIsLead = true }
        
        // Download club announcements data
        parseForEvents(ClubViewController.ref.child("announcements"))
    }
    
    override func viewDidLayoutSubviews() {
        // If there is no image to display, then hide the UIImageView and shift the title and description to its place
        if clubImageView.image == nil {
            clubImageView.isHidden = true     // Hide the image just in case
            let fields:[UIView] = [clubTitleView, titleField, clubInfoView, descriptionField]
            for field in fields {
                field.frame.origin.x = clubImageView.frame.origin.x
                field.frame.size.width = self.view.frame.width - 16
            }
        }
    }
    
    func enterEditMode () {
        // Switch the fields' and labels' visibility states
        clubTitleView.isHidden = !clubTitleView.isHidden
        clubInfoView.isHidden = !clubInfoView.isHidden
        titleField.isHidden = !titleField.isHidden
        descriptionField.isHidden = !descriptionField.isHidden
        // If editing is being initiated, then make preparations for editing
        if navigationItem.rightBarButtonItem?.title == "Edit" {
            navigationItem.rightBarButtonItem?.title = "Done"
            titleField.text = clubTitleView.text
            descriptionField.text = clubInfoView.text
        // If editing is being completed, then finilize all edits
        } else {
            navigationItem.rightBarButtonItem?.title = "Edit"
            finalizeEditing()
        }
    }
    
    func finalizeEditing() {
        var childrenToBeUpdated:[String: String] = [String: String] ()
        if clubTitleView.text != titleField.text { childrenToBeUpdated["title"] = titleField.text! }
        if clubInfoView.text != descriptionField.text { childrenToBeUpdated["description"] = descriptionField.text }
        if childrenToBeUpdated.count > 0 {
            ClubViewController.ref.updateChildValues(childrenToBeUpdated, withCompletionBlock: { (error, reference) in
                if error == nil {
                    self.clubTitleView.text = self.titleField.text
                    self.clubInfoView.text = self.descriptionField.text
                    let toast = ToastView(inView: self.view, withText: "Changes Applied!")
                    self.view.addSubview(toast)
                    toast.initiate()
                    ListViewController.contentChanged = true
                } else {
                    let toast = ToastView(inView: self.view, withText: "Sumbission Failed!")
                    self.view.addSubview(toast)
                    toast.initiate()
                    print (error)
                }
            })
        }
    }
    
    // This is used to make the keyboard go away, when a tap outside of the keyboard has been made
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    // This is used to make the keyboard go away, when the return key is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool{
        textField.resignFirstResponder()
        return true
    }
    
    // This method check whether the current user has permission to edit this page
    func checkForClubLeadership () {
        let userID = FIRAuth.auth()?.currentUser?.uid
        ClubViewController.ref.child("leaders").observe(.value, with: { (snapshot) in
            let leaderIDs:[String: String] = snapshot.value as! Dictionary
            if (leaderIDs.values.contains(userID!)) {
                self.userIsLead = true
            }
        })
    }
    
    // Downloads club announcements data
    func parseForEvents (_ reference:FIRDatabaseReference) {
        // Navigate to and download the Events data
        reference.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the events
                for h in 0...dataContent.count-1 {
                    self.eventData[0].append((dataContent.object(at: h) as AnyObject).object(forKey: "title")! as! String)
                    self.eventData[1].append((dataContent.object(at: h) as AnyObject).object(forKey: "description")! as! String)
                    self.eventData[2].append(ListViewController.formatTime((((dataContent.object(at: h) as AnyObject).object(forKey: "dateTime")! as! NSNumber).description) as NSString))
                    self.eventData[3].append((dataContent.object(at: h) as AnyObject).object(forKey: "location")! as! String)
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
        ClubViewController.ref = eventsRef
    }
    
    // This method is called whenever the MemberList button is pressed
    @IBAction func displayMembers(_ sender: UIButton) {
        // Prepare the PeopleList View Controller for displaying this club's members
        PeopleList.listRef = ClubViewController.ref.child("members")
        PeopleList.title = "Members"
        PeopleList.editEnabled = userIsLead
        // Segue into the prepared PeopleList
        self.performSegue(withIdentifier: "MemberListSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    private func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListCell")   // Declare the cell
        cell.backgroundColor = foregroundColor                              // Set the Background Color
        cell.imageView?.image = images[(indexPath as NSIndexPath).row]                       // Set the Cell Image
        
        cell.textLabel?.text = eventData[0][(indexPath as NSIndexPath).row]              // Set the Title Text
        cell.textLabel?.textColor = accentColor                             // Set the Title Text Color
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 20)         // Set the Title Text Font
        
        cell.detailTextLabel?.text = eventData[1][(indexPath as NSIndexPath).row]        // Set the Description Text
        cell.detailTextLabel?.textColor = accentColor                       // Set the Description Text Color
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 16)   // Set the Description Text Font
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
        InfoViewController.setupViewController(title: eventData[0][(indexPath as NSIndexPath).row]!,          // Give it a title to display
            info: eventData[1][(indexPath as NSIndexPath).row]!,           // Give it a description to display
            date: eventData[2][(indexPath as NSIndexPath).row],        // Give it a date to display
            location: eventData[3][(indexPath as NSIndexPath).row],    // Give it a location to display
            image: images[(indexPath as NSIndexPath).row])                    // Give it an image to display
        // Deselect the selected cell
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue into InfoViewController
        performSegue(withIdentifier: "ClubInfoSegue", sender: nil)
    }
}
