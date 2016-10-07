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
    static var title:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = colorNavigationText
        
        // Set the title of the list
        PeopleList.title = PeopleList.title
        // If the current user has permission to edit thi list, then display the edit button
        if PeopleList.editEnabled && PeopleList.title == "Members" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(enterEditMode))
        }
        parseWebData()
    }
    
    // This is called whenever the user presses the Edit/Done button
    func enterEditMode () {
        if navigationItem.rightBarButtonItem?.title == "Edit" {     // Entering edit mode
            navigationItem.rightBarButtonItem?.title = "Done"       // Switch edit button
            // Switch back button
            leftSideItemHolder = navigationItem.leftBarButtonItem
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(addMemberInitiated))
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
                    childrenToUpdate[PeopleList.listRef.childByAutoId().key ] = self.newContent[0][h]
                }
            }
            // Add the new members to the database
            PeopleList.listRef.updateChildValues(childrenToUpdate, withCompletionBlock: { (error, reference) in
                let toast = ToastView(inView: self.view, withText: "Success!")
                if error == nil {   // If operation was successful, notify the user
                    print ("Update Success!")
                } else {            // If operation failed then, notify the user
                    print ("Update Failed!")
                    print (error)
                    toast.displayText = "Update Failed!"
                }
                self.view.addSubview(toast)
                toast.initiate()
            })
        }
        
        // Remove any removed users, from the database
        PeopleList.listRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            let snapshots = snapshot.children.allObjects as! [FIRDataSnapshot]
            for h in 0..<snapshots.count {
                if (!self.newContent[0].contains(snapshots[h].value as! String)) {
                    snapshots[h].ref.removeValue()
                    self.content[0].remove(at: h)
                    self.content[1].remove(at: h)
                }
            }
            // Add any new users to the database
            checkForNewMembers()
        })
    }
    
    // This is called whenever the user pressed the "Add" button
    func addMemberInitiated () {
        // Display an alert view, where the user will enter the name of the new user
        let alert:LyonsAlert = LyonsAlert(withTitle: "Add new member", subtitle: "Enter the name of the new member", style: .alert)
        alert.addAction(UIAlertAction(title: "Submit", style: UIAlertActionStyle.default) { (action) in
            self.addMember((alert.alertView.textFields?.first?.text!)!)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        alert.addTextFieldWithPlaceHolder("Enter name here")
        alert.showIn(self)
    }
    
    // This is called whenever the user enters a name into the alert view
    func addMember (_ name:String) {
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
                    self.content[0].append(dataContent.object(at: h) as! String)
                    self.newContent[0].append(dataContent.object(at: h) as! String)
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
                    self.content[0].append((dataContent.object(at: h) as AnyObject).object(forKey: "name")! as! String)
                    let tempHold:String = "\((dataContent.object(at: h) as AnyObject).object(forKey: "department")! as! String) \((dataContent.object(at: h) as AnyObject).object(forKey: "email")! as! String)"
                    self.content[1].append(tempHold)
                }
            } else {
                print ("There has been an error")
            }
        }
        
        PeopleList.listRef.observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            // Depending on which list has been initiated, call the appropriate parser
            if PeopleList.title == "Teachers" {
                parseForTeachers(snapshot)
            } else if PeopleList.title == "Members" {
                parseForMembers(snapshot)
            }
            // Reload the displaying list
            self.tableView.reloadData()
        })
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (self.tableView.isEditing) ? newContent[0].count : content[0].count
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // This is used to enable editing
        if tableView.isEditing {
            return true
        }
        return false
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        // This is used to allow deleting of cells, (only when editing)
        if editingStyle == UITableViewCellEditingStyle.delete {
            let index = newContent[0].index(of: (tableView.cellForRow(at: indexPath)?.textLabel?.text)!)!
            newContent[0].remove(at: index)
            newContent[1].removeLast()
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "TeacherCell")
        cell.backgroundColor = UIColor(red: 0.9294, green: 0.9686, blue: 1, alpha: 1.0) /* #edf7ff */
        cell.textLabel?.text = (self.tableView.isEditing) ? newContent[0][(indexPath as NSIndexPath).row] : content[0][(indexPath as NSIndexPath).row]
        cell.textLabel!.textColor = UIColor.black
        cell.detailTextLabel?.text = (self.tableView.isEditing) ? newContent[1][(indexPath as NSIndexPath).row] : content[1][(indexPath as NSIndexPath).row]
        cell.detailTextLabel!.textColor = UIColor.black
        cell.selectionStyle = .none
        return cell
    }
}
