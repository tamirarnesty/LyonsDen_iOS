//
//  TeacherTable.swift
//  LyonsDen
//
//  This class can and will be used to (exclusively) display a list of information
//
//  Created by Inal Gotov on 2016-07-06.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Firebase

// TODO: IMPLEMENT DELETE ANIMATION
// TODO: IMPLEMENT ADD ANIMATION, IF POSSIBLE

class PeopleList: UITableViewController {
    // Reference to the list that should be displayed
    static var listRef:FIRDatabaseReference!
    // States whether the current user has permission to edit this list
    static var editEnabled = false
    // Holder for the left side Navigation bar button
    var leftSideItemHolder:UIBarButtonItem?
    // The array containing the data
    // [0] - Name, [1] - Other info
    var content = [[String](), [String]()]
    // A clone array containing the edited content
    var newContent = [[String](), [String]()]
    // This holds the titles of the list
    static var title:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title of the list
        self.title = PeopleList.title
        // If the current user has permission to edit thi list, then display the edit button
        if PeopleList.editEnabled && self.title == "Members" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .Plain, target: self, action: #selector(enterEditMode))
        }
        parseWebData()
    }
    
    // This is called whenever the user presses the Edit/Done button
    func enterEditMode () {
        if navigationItem.rightBarButtonItem?.title == "Edit" {     // Entering edit mode
            navigationItem.rightBarButtonItem?.title = "Done"       // Switch edit button
            // Switch back button
            leftSideItemHolder = navigationItem.leftBarButtonItem
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .Plain, target: self, action: #selector(addMemberInitiated))
            // Enter editing mode
            self.tableView.setEditing(true, animated: true)
        } else {                                                    // Leaving edit mode
            navigationItem.rightBarButtonItem?.title = "Edit"       // Switch edit button
            navigationItem.leftBarButtonItem = leftSideItemHolder   // Switch back button
            self.tableView.setEditing(false, animated: true)        // Leave editing mode
            finalizeEditing()                                       // Finalize any modifications
        }
    }
    
    // This is called whenever the user presses the done button, after enterEditMode()
    func finalizeEditing () {
        // For new added content
        let checkForNewMembers: () -> Void = {
            var childrenToUpdate = [String: String]()
            // Construct a dictionary of new members added to the list
            if self.content[0].count < self.newContent[0].count {
                for h in self.content[0].count..<self.newContent[0].count {
                    childrenToUpdate[PeopleList.listRef.childByAutoId().key as! String] = self.newContent[0][h]
                }
            }
            // Add the new members to the database
            PeopleList.listRef.updateChildValues(childrenToUpdate, withCompletionBlock: { (error, reference) in
                let toast = ToastView(inView: self.view, withText: "Success!")
                if error == nil {   // If operation was successful, notify the user
                    print ("Update Success!")
                } else {            // If operation failed then, notify the user
                    print ("Update Failed!")
                    print (error?.description)
                    toast.displayText = "Update Failed!"
                }
                self.view.addSubview(toast)
                toast.initiate()
            })
        }
        
        // Remove any removed users, from the database
        PeopleList.listRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            for h in 0..<snapshots.count {
                if (!self.newContent[0].contains(snapshots[h].value as! String)) {
                    snapshots[h].ref.removeValue()
                    self.content[0].removeAtIndex(h)
                    self.content[1].removeAtIndex(h)
                }
            }
            // Add any new users to the database
            checkForNewMembers()
        })
    }
    
    // This is called whenever the user pressed the "Add" button
    func addMemberInitiated () {
        // Display an alert view, where the user will enter the name of the new user
        let alert:LyonsAlert = LyonsAlert(withTitle: "Add new member", subtitle: "Enter the name of the new member", style: .Alert)
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.Default) { (action) in
            self.addMember((alert.alertView.textFields?.first?.text!)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        alert.addTextFieldWithPlaceHolder("Enter name here")
        alert.showIn(self)
    }
    
    // This is called whenever the user enters a name into the alert view
    func addMember (name:String) {
        // Add the new member to the list
        newContent[0].append(name)
        newContent[1].append("")
        tableView.reloadData()
    }
    
    func parseWebData () {
        let parseForMembers:(FIRDataSnapshot) -> Void = { (snapshot) in
            if snapshot.exists() {  // If download succesful
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                // Create an NSArray instance of all the values from the NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the members
                for h in 0...dataContent.count-1 {
                    self.content[0].append(dataContent.objectAtIndex(h) as! String)
                    self.newContent[0].append(dataContent.objectAtIndex(h) as! String)
                    self.content[1].append("")
                    self.newContent[1].append("")
                }
            } else {
                print ("There has been an error")
            }
        }
        let parseForTeachers:(FIRDataSnapshot) -> Void = { (snapshot) in
            if snapshot.exists() {
                // Parse web data into readable formats
                let data = snapshot.value as! NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the members
                for h in 0..<data.count {
                    self.content[0].append(dataContent.objectAtIndex(h).objectForKey("name")! as! String)
                    let tempHold:String = "\(dataContent.objectAtIndex(h).objectForKey("department")! as! String) \(dataContent.objectAtIndex(h).objectForKey("email")! as! String)"
                    self.content[1].append(tempHold)
                }
            } else {
                print ("There has been an error")
            }
        }
        
        PeopleList.listRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            // Depending on which list has been initiated, call the appropriate parser
            if self.title == "Teachers" {
                parseForTeachers(snapshot)
            } else if self.title == "Members" {
                parseForMembers(snapshot)
            }
            // Reload the displaying list
            self.tableView.reloadData()
        })
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tableView.editing) ? newContent[0].count : content[0].count
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // This is used to enable editing
        if tableView.editing {
            return true
        }
        return false
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        // This is used to allow deleting of cells, (only when editing)
        if editingStyle == UITableViewCellEditingStyle.Delete {
            let index = newContent[0].indexOf((tableView.cellForRowAtIndexPath(indexPath)?.textLabel?.text)!)!
            newContent[0].removeAtIndex(index)
            newContent[1].removeLast()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "TeacherCell")
        cell.textLabel?.text = (self.tableView.editing) ? newContent[0][indexPath.row] : content[0][indexPath.row]
        cell.textLabel!.textColor = accentColor
        cell.detailTextLabel?.text = (self.tableView.editing) ? newContent[1][indexPath.row] : content[1][indexPath.row]
        cell.detailTextLabel!.textColor = accentColor
        cell.backgroundColor = foregroundColor
//        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        cell.selectionStyle = .None
        return cell
    }
}