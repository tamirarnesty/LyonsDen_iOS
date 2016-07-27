//
//  TeacherTable.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-06.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class TeacherTable: UITableViewController {
    // The array containing the data on the teachers
    // [0]=name, [1]=contact info
    var content = [[String](), [String]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view title text, at the Navigation Bar
        self.title = "Teachers"
        
        // Will read info from a file and load it into the content array
        
        // temporary
        for h in 0...49 {
            content[0].append("Teacher \(h+1)")
            content[1].append("Contact Info \(h+1)")
        }
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return content[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "TeacherCell")
        cell.textLabel?.text = content[0][indexPath.row]
        cell.textLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.detailTextLabel?.text = content[1][indexPath.row]
        cell.detailTextLabel!.textColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2184, alpha: 1)
        cell.backgroundColor = UIColor (red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        return cell
    }
}
