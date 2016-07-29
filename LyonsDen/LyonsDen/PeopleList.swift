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

class PeopleList: UITableViewController {
    // The array containing the data
    // [0] - Name, [1] - Other info
    static var content = [[String](), [String]()]
    // This holds the titles of the list
    static var title:String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the title of the list
        self.title = PeopleList.title
    }
    
    // This must be called prior to segueing into this class
    //                                       The Content of the list      The title of the list
    static func setupPeopleList (withContent content:[[String]], andTitle title:String) {
        // Prepare the content of the list
        PeopleList.content = content
        // Prepare the title of the list
        PeopleList.title = title
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return PeopleList.content[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "TeacherCell")
        cell.textLabel?.text = PeopleList.content[0][indexPath.row]
        cell.textLabel!.textColor = accentColor
        cell.detailTextLabel?.text = PeopleList.content[1][indexPath.row]
        cell.detailTextLabel!.textColor = accentColor
        cell.backgroundColor = foregroundColor
        cell.textLabel?.font = UIFont(name: "Hapna Mono", size: 12)
        cell.selectionStyle = .None
        return cell
    }
}