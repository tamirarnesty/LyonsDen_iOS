//
//  MenuTable.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-07.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import FirebaseAuth

class MenuTable: UITableViewController {
    // An array containig the titles of the cell in [0]
    var titles = ["DEN", "Home", "Calendar", "Announcements", "Events", "Clubs", "Contact", "User"]
    var listViewDisplayContent = 0
    
    @IBOutlet var sidebarTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.sidebarTable.tableFooterView = UIView()
        self.sidebarTable.frame.origin.y += self.view.frame.height/4
        self.sidebarTable.center.y = self.view.center.y
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "EventSegue" {
            ((segue.destination as! UINavigationController).viewControllers.first as! ListViewController).displayContent = listViewDisplayContent
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0 {
            return 100
        } else {
            return 43.67
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "MenuCell\((indexPath as NSIndexPath).row)")
        
        cell.backgroundColor = backgroundColor.withAlphaComponent(0.8)
        cell.textLabel?.text = titles[(indexPath as NSIndexPath).row]
        cell.textLabel?.textColor = colorWhiteText
        if (indexPath as NSIndexPath).row == 0 {
            cell.textLabel?.text = nil
            cell.imageView?.image = #imageLiteral(resourceName: "denLogo")
            cell.selectionStyle = UITableViewCellSelectionStyle.none
        } else {
            cell.textLabel?.font = UIFont(name: "Reckoner", size: 26.0)
        }
        if indexPath.row == titles.count-1 {
            cell.textLabel?.text = (FIRAuth.auth()?.currentUser?.displayName != nil ? FIRAuth.auth()?.currentUser?.displayName : titles[titles.count-1])
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Announcements == 3, Events == 4, Clubs == 5
        if indexPath.row > 2 && indexPath.row < 6 {
            listViewDisplayContent = indexPath.row - 2
            performSegue(withIdentifier: "EventSegue", sender: nil)
            return
        }
        if (indexPath as NSIndexPath).row != 0 {
            performSegue(withIdentifier: titles[(indexPath as NSIndexPath).row] + "Segue", sender: nil)
        }
    }
}
