//
//  ListViewController.swift
//  LyonsDen
//
//  The ListViewController class will be used for controlling the Clubs/Events list screens.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class ListViewController: UITableViewController {
    @IBOutlet weak var menuButton: UIBarButtonItem!
    // States whether to display Clubs(if true) or to display Events(if false)
    static var showingClubs:Bool = false
    // Contains the contents of the table, whether its clubs or events 
    // [0] - Titles, [1] - Descriptions
    var tableContents = [[String](), [String]()]
    var images = [UIImage?]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        if ListViewController.showingClubs {
            // Fill tableContents with Clubs data
            title = "Clubs"
            
            // Temporary
            for h in 1...50 {
                tableContents[0].append("Title \(h)")
                tableContents[1].append("Description \(h)")
                if (h == 2 || h == 17) {
                    images.append(UIImage(named: "Home"))
                } else {
                    images.append(nil)
                }
            }
        } else {
            // Fill tableContents with Events data
            title = "Events"
            
            // Temporary
            for h in 1...40 {
                tableContents[0].append("Title \(40 - h)")
                tableContents[1].append("Description \(40 - h)")
                if (h == 2 || h == 17) {
                    images.append(UIImage(named: "Music"))
                } else {
                    images.append(nil)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tableContents[0].count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "ListCell")
        cell.backgroundColor = UIColor(red: 0.0118, green: 0.2431, blue: 0.5765, alpha: 1)  // Set Background Color
        cell.imageView?.image = images[indexPath.row]                                       // Set Cell Image
        
        cell.textLabel?.text = tableContents[0][indexPath.row]                              // Set Title Text
        cell.textLabel?.textColor = UIColor (red: 0.9961, green: 0.7765, blue: 0.2784, alpha: 1)    // Set Title Text Color
        
        cell.detailTextLabel?.text = tableContents[1][indexPath.row]                        // Set Description Text
        cell.detailTextLabel?.textColor = UIColor (red: 0.9961, green: 0.7765, blue: 0.2784, alpha: 1)  // Set Description Text Color
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // Prepare InfoViewController
        InfoViewController.setupViewController(tableContents[0][indexPath.row], info: tableContents[1][indexPath.row], image: images[indexPath.row])
        // Segue into InfoViewController
        performSegueWithIdentifier("InfoSegue", sender: nil)
    }
}
