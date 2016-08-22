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

class PeopleList: UITableViewController {
    static var listRef:FIRDatabaseReference!
    // The array containing the data
    // [0] - Name, [1] - Other info
    var content = [[String](), [String]()]
    // This holds the titles of the list
    static var title:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title of the list
        self.title = PeopleList.title
        parseWebData()
    }
    
    func parseWebData () {
        let parseForMembers:(NSArray) -> Void = { (array) in
            
        }
        let parseForTeachers:(NSArray) -> Void = { (array) in
            
        }
        
        PeopleList.listRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                let data = snapshot.value as! NSDictionary
                let dataContent = data.allValues as NSArray
                if (dataContent.objectAtIndex(0).containsValueForKey("email")) {
                    let parser = parseForTeachers
                } else if (dataContent.objectAtIndex(0).containsValueForKey("name")) {
                    
                }
                for h in 0...dataContent.count {
                    
                }
            }
        })
        
        self.tableView.reloadData()
        
        /*
         if snapshot.exists() {
         // Create an NSDictionary instance of the data
         let data = snapshot.value as! NSDictionary
         // Create an NSArray instance of all the values from the NSDictionary
         let dataContent = data.allValues as NSArray
         // Record each field of the events
         for h in 0...dataContent.count-1 {
         self.eventData[0].append(dataContent.objectAtIndex(h).objectForKey("title")! as! String)
         self.eventData[1].append(dataContent.objectAtIndex(h).objectForKey("description")! as! String)
         self.eventData[2].append(ListViewController.formatTime(((dataContent.objectAtIndex(h).objectForKey("dateTime")! as! NSNumber).description) as NSString))
         self.eventData[3].append(dataContent.objectAtIndex(h).objectForKey("location")! as! String)
         self.images.append(nil) // Will be implemented later
         }
         // Reload the tableView to display the loaded data
         self.tableView.reloadData()
         } else {
         print ("There has been an error")
         // Will handle errors
         }
         */
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "TeacherCell")
        cell.textLabel?.text = content[0][indexPath.row]
        cell.textLabel!.textColor = accentColor
        cell.detailTextLabel?.text = content[1][indexPath.row]
        cell.detailTextLabel!.textColor = accentColor
        cell.backgroundColor = foregroundColor
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        cell.selectionStyle = .None
        return cell
    }
}