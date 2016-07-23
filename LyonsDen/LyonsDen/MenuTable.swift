//
//  MenuTable.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-07.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class MenuTable: UITableViewController {
    // An array containig the titles of the cell in [0]
    let titles = ["DEN", "Home", "Announcements", "Calendar", "Clubs", "Events", "Contact"]
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "MenuCell\(indexPath.row)")
        cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        cell.textLabel?.text = titles[indexPath.row]
        cell.textLabel?.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2784, alpha: 1)
        if indexPath.row == 0 {
            cell.textLabel?.font = UIFont(name: "Reckoner", size: 41.0)
            cell.selectionStyle = UITableViewCellSelectionStyle.None
        } else {
        cell.textLabel?.font = UIFont(name: "Reckoner", size: 26.0)
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row == 1) {
            print ("I will show events")
            // Setup ListViewController for the events table
            
            ListViewController.showingClubs = false
        } else if (indexPath.row == 2) {
            print ("I will show clubs")
            // setup ListViewController for the clubs table
            
            ListViewController.showingClubs = true
        }
        // TEMPORARY !!!!!!!!!!!!!!!!!!!!!!
        if indexPath.row == 2 {
            return  // Make announcements unclickable
        }
        if indexPath.row != 0 {
            performSegueWithIdentifier(titles[indexPath.row] + "Segue", sender: nil) }
    }
}
