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

// FIX TITLE POSITION

class ClubViewController: UIViewController, UITableViewDelegate {
    var clubImage:UIImage?       // The image of the club
    var clubTitle:String!        // The title of the club
    var clubInfo:String!         // The description of the club
    var clubLeads:String!    // A list of club leaders
    let refreshController = UIRefreshControl()
    var clubRef:FIRDatabaseReference!  // The database reference to the club
    var selectedIndex = 0
    // The content of each announcements
    //                           Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // States if the current user can edit this page
    var userIsLead = false {
        didSet {
            if userIsLead {
                self.navigationController?.setToolbarHidden(false, animated: true)
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

        // Initialize refresh controller
        refreshController.frame.size.height = 5
        refreshController.addTarget(self, action: #selector(refreshAnnouncements), for: .valueChanged)
        self.tableView.addSubview(refreshController)
        
        self.navigationController?.navigationBar.tintColor = colorNavigationText
        self.navigationController?.setToolbarHidden(true, animated: false)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "membersIcon"), style: .plain, target: self, action: #selector(displayMembers))
        self.setToolbarItems([UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(enterEditMode)),
                              UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.flexibleSpace, target: nil, action: nil),
                              UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(newAnnouncement))],
                             animated: false)
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        // Put all leader button into the toolbar, initially hidden, then show them whenever a leader comes into the scene
        
        // Set all the necessary information before displaying this ViewController
        clubTitleView.text = clubTitle
        clubInfoView.text = clubInfo
        clubLeadsView.text = "Club Leads: " + clubLeads
        clubImageView.image = clubImage       // Set the image
        
        // Just in case, if the current user has permission to edit this page, then display the edit button
        if userIsLead { userIsLead = true }
        
        checkForClubLeadership()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        print ("First")
        print (self.clubTitleView.frame.origin.x)
        print (self.clubTitleView.frame.width)
        super.viewWillAppear(animated)
        // Download club announcements data
        self.refreshAnnouncements()
        if clubImage == nil {
            clubImageView.isHidden = true     // Hide the image just in case
            let fields:[UIView] = [clubTitleView, titleField]
            for field in fields {
                field.frame.origin.x = 8
                field.frame.size.width = self.view.frame.width - 16
            }
        }
        print ("Second")
        print (self.clubTitleView.frame.origin.x)
        print (self.clubTitleView.frame.width)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if clubImage == nil {
            clubImageView.isHidden = true     // Hide the image just in case
            let fields:[UIView] = [clubTitleView, titleField]
            for field in fields {
                field.frame.origin.x = 8
                field.frame.size.width = self.view.frame.width - 16
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // If there is no image to display, then hide the UIImageView and shift the title and description to its place
        if clubImage == nil {
            clubImageView.isHidden = true     // Hide the image just in case
            let fields:[UIView] = [clubTitleView, titleField]
            for field in fields {
                field.frame.origin.x = 8
                field.frame.size.width = self.view.frame.width - 16
            }
        }
        print ("Third")
        print (self.clubTitleView.frame.origin.x)
        print (self.clubTitleView.frame.width)
    }
    
    func refreshAnnouncements () {
        // Clear events array to enter new Data
        self.eventData = [[String?](), [String?](), [String?](), [String?]()]
        // Reload data into events array
        self.parseForEvents(self.clubRef.child("announcements"))
    }
    
    func enterEditMode () {
        // Switch the fields' and labels' visibility states
        clubTitleView.isHidden = !clubTitleView.isHidden
        clubInfoView.isHidden = !clubInfoView.isHidden
        titleField.isHidden = !titleField.isHidden
        descriptionField.isHidden = !descriptionField.isHidden
        // If editing is being initiated, then make preparations for editing
        if self.toolbarItems?.first?.title == "Edit" {
            self.toolbarItems?.first?.title = "Done"
            titleField.text = clubTitleView.text
            descriptionField.text = clubInfoView.text
        // If editing is being completed, then finilize all edits
        } else {
            self.toolbarItems?.first?.title = "Edit"
            finalizeEditing()
        }
    }
    
    func finalizeEditing() {
        var childrenToBeUpdated:[String: String] = [String: String] ()
        if clubTitleView.text != titleField.text { childrenToBeUpdated["title"] = titleField.text! }
        if clubInfoView.text != descriptionField.text { childrenToBeUpdated["description"] = descriptionField.text }
        if childrenToBeUpdated.count > 0 {
            self.clubRef.updateChildValues(childrenToBeUpdated, withCompletionBlock: { (error, reference) in
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
        self.userIsLead = true
//        let userID = FIRAuth.auth()?.currentUser?.uid
//        ClubViewController.ref.child("leaders").observe(.value, with: { (snapshot) in
//            let leaderIDs:[String: String] = snapshot.value as! Dictionary
//            if (leaderIDs.values.contains(userID!)) {
//                self.userIsLead = true
//            }
//        })
    }
    
    func newAnnouncement () {
        performSegue(withIdentifier: "ClubAnnouncementSegue", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is AnnouncementViewController {
            (segue.destination as! AnnouncementViewController).clubAnnouncement = true
            (segue.destination as! AnnouncementViewController).clubRef = (sender as! ClubViewController).clubRef.child("announcements")
        } else if segue.destination is InfoViewController {
            let destination = segue.destination as! InfoViewController
            
            destination.eventTitle = eventData[0][selectedIndex]!
            destination.eventInfo = eventData[1][selectedIndex]!
            destination.eventDate = eventData[2][selectedIndex]!
            destination.eventLocation = eventData[3][selectedIndex]!
            destination.eventImage = images[selectedIndex]
        }
    }
    
    // Downloads club announcements data
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
                // Quit refreshing animation
                self.refreshController.endRefreshing()
            } else {
                print ("There has been an error")
                // Will handle errors
            }
        })
    }
    
    // This is required for a successful unwind to this View Controller
    // It just needs to be present, so don't mind it at all
    @IBAction func myUnwindAction (_ unwindSegue: UIStoryboardSegue) {
        
    }
    
    // This method is called whenever the MemberList button is pressed
    func displayMembers() {
        // Prepare the PeopleList View Controller for displaying this club's members
        PeopleList.listRef = self.clubRef.child("members")
        PeopleList.title = "Members"
        PeopleList.editEnabled = userIsLead
        // Segue into the prepared PeopleList
        self.performSegue(withIdentifier: "MemberListSegue", sender: self)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAtIndexPath indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "ListCell")   // Declare the cell
        cell.backgroundColor = UIColor(red: 0.9294, green: 0.9686, blue: 1, alpha: 1.0) /* #edf7ff */
        cell.imageView?.image = images[(indexPath as NSIndexPath).row]                       // Set the Cell Image
        
        cell.textLabel?.text = eventData[0][(indexPath as NSIndexPath).row]              // Set the Title Text
        cell.textLabel?.textColor = UIColor.black                             // Set the Title Text Color
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 20)         // Set the Title Text Font
        
        cell.detailTextLabel?.text = eventData[1][(indexPath as NSIndexPath).row]        // Set the Description Text
        cell.detailTextLabel?.textColor = UIColor.black                       // Set the Description Text Color
        cell.detailTextLabel?.font = UIFont(name: "Hapna Mono", size: 16)   // Set the Description Text Font
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Prepare InfoViewController, if nil is passed for either date, location or image, constraints are remade appropriately
        selectedIndex = indexPath.row
        // Deselect the selected cell
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue into InfoViewController
        performSegue(withIdentifier: "ClubInfoSegue", sender: nil)
    }
}
