//
//  ListViewController.swift
//  LyonsDen
//
//  The ListViewController class will be used for displaying the list of Clubs or Events.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit
import Firebase

class ListViewController: UITableViewController {
    // The menu button
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    var displayContent:Int!
    
    static var contentChanged = false
    // Contains Image for each item. Will be implemented later
    var images = [UIImage?]()
    // Reference to the database
    var ref:FIRDatabaseReference!
    // Refresh Controller to update data in screen
    var refreshController: UIRefreshControl!
                        //       Title        Description  Date&Time    Location
    var eventData:[[String?]] = [[String?](), [String?](), [String?](), [String?]()]
    var clubKeys:[String] = [String]()
    var loadingWheel:UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.white)
    var loadingCurtain:UIView = UIView()
    var selectedCellIndex = 0
    var expandedCell:ListExpandableCell? = nil {
        willSet {
            expandedCell?.collapseCell()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initialize refresh controller
        refreshController = UIRefreshControl()
        refreshController.frame.size.height = 5
        refreshController.addTarget(self, action: #selector(refreshList), for: .valueChanged)
        self.tableView.addSubview(refreshController)
        
        // Initialize the database
        ref = FIRDatabase.database().reference()
        
        // Make sidemenu swipeable
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = #selector(SWRevealViewController.revealToggle(_:))
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
        }
        
        self.view.backgroundColor = colorBackground
        
        loadingWheel.center.x = self.view.center.x
        loadingWheel.center.y = self.view.center.y
        loadingCurtain.frame = self.view.frame
        loadingCurtain.backgroundColor = colorBackground
        self.view.addSubview(loadingCurtain)
        self.view.addSubview(loadingWheel)
        webContentWillLoad()
        
        
        let titles = ["Announcements", "Events", "Clubs"]
        self.title = titles[displayContent - 1]
        if displayContent == 3 {
            parseForClubs()
        } else {
            parseForEvents(self.ref.child((displayContent == 1) ? "announcements" : "events"))    // Download events data
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if ListViewController.contentChanged {
            ListViewController.contentChanged = false
            webContentWillLoad()
            parseForClubs()
        }
    }
    
    func refreshList () {
        print ("refreshed")
        // Clear events array to enter new Data
        self.eventData = [[String?](), [String?](), [String?](), [String?]()]
        // Reload data into events array
        if displayContent == 3 {
            parseForClubs()
        } else {
            parseForEvents(self.ref.child((displayContent == 1) ? "announcements" : "events"))    // Download events data
        }        // Quit refreshing animation
        self.refreshController.endRefreshing()
    }

    
    static func formatTime (_ time:NSString) -> String {
        var output:NSString = ""
        output = (output.appending(time.substring(to: 4)) + "-") as NSString
        output = output.appending(time.substring(with: NSMakeRange(4, 2)) + "-") as NSString
        output = output.appending(time.substring(with: NSMakeRange(6, 2))) as NSString
        if time.substring(with: NSMakeRange(8, 4)) != "2400" {
            output = output.appending(" " + time.substring(with: NSMakeRange(8, 2)) + ":") as NSString
            output = output.appending(time.substring(with: NSMakeRange(10, 2))) as NSString
        }
        return output as String
    }
    
    func webContentWillLoad () {
        self.tableView.isHidden = true
        self.clubKeys.removeAll()
        for h in 0..<eventData.count { eventData[h].removeAll() }
        
        if loadingCurtain.alpha == 0 {
            UIView.animate(withDuration: 0.2, animations: { self.loadingCurtain.alpha = 1 })
        }
        
        loadingWheel.startAnimating()
    }
    
    func webContentDidLoad () {
        self.tableView.isHidden = false
        UIView.animate(withDuration: 0.2, animations: { self.loadingCurtain.alpha = 0 })
        loadingWheel.stopAnimating()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.destination is ClubViewController {
            let destination = segue.destination as! ClubViewController
            
            destination.clubTitle = self.eventData[0][selectedCellIndex]!
            destination.clubInfo = self.eventData[1][selectedCellIndex]!
            destination.clubLeads = self.eventData[2][selectedCellIndex]!
            destination.clubImage = self.images[selectedCellIndex]
            destination.clubRef = self.ref.child("clubs").child(self.clubKeys[selectedCellIndex])
        } else if segue.destination is InfoViewController {
            let destination = segue.destination as! InfoViewController
            
            destination.eventTitle = self.eventData[0][selectedCellIndex]!
            destination.eventInfo = self.eventData[1][selectedCellIndex]!
            destination.eventDate = self.eventData[2][selectedCellIndex]!
            destination.eventLocation = self.eventData[3][selectedCellIndex]!
            destination.eventImage = self.images[selectedCellIndex]
        }
    }
    
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
                self.webContentDidLoad()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    func parseForClubs () {
        // Navigate to and download the Clubs data
        self.ref.child("clubs").queryOrderedByKey().observeSingleEvent(of: FIRDataEventType.value, with: { (snapshot) in
            if snapshot.exists() {
                // Create an NSDictionary instance of the data
                let data = snapshot.value as! NSDictionary
                let dataContent = data.allValues as NSArray
                // Record each field of the clubs
                let key = ["title", "description", "leads"]
                for h in 0...dataContent.count - 1 {
                    self.clubKeys.append((dataContent.object(at: h) as AnyObject).object(forKey: "key")! as! String)
                    
                    for j in 0..<key.count {
                        self.eventData[j].append((dataContent.object(at: h) as AnyObject).object(forKey: key[j])! as! String)
                    }
                    
                    self.images.append(nil)
                }
                // Reload the tableView to display the loaded data
                self.tableView.reloadData()
                self.webContentDidLoad()
            } else {
                print ("There has been an error")
                // Handle the error
            }
        })
    }
    
    // Set the number of cell the table will display
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventData[0].count
    }
    
    // Set the height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        print (displayContent)
//        print (expandedCell?.description)
//        print (tableView.cellForRow(at: indexPath)?.description)
        if displayContent != 3 && expandedCell != nil && expandedCell!.tag == indexPath.row {// && tableView.cellForRow(at: indexPath) == expandedCell {
            return 148.0
        }
        return 44.0
    }
    
    // Configure each cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ListExpandableCell(style: .default, reuseIdentifier: "ListCell", index: indexPath.row, creatorWidth: tableView.frame.width) { (index) in
            self.selectedCellIndex = index
            // Segue into InfoViewController
            self.performSegue(withIdentifier: "InfoSegue", sender: self)
        }
        
        cell.tag = indexPath.row
        cell.titleLabel.text = eventData[0][indexPath.row]!              // Set the Title Text
        cell.descriptionLabel.text = eventData[1][indexPath.row]!        // Set the Description Text
        cell.dateLabel.text = eventData[2][indexPath.row]
        return cell                                                         // Return the cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Segue into the appropriate ViewController
        if displayContent == 3 {
            self.selectedCellIndex = indexPath.row
            // Segue into ClubViewController
            self.performSegue(withIdentifier: "ClubSegue", sender: self)
        } else {
            let cell = tableView.cellForRow(at: indexPath) as! ListExpandableCell
            if cell.isExpanded {
                cell.collapseCell()
                expandedCell = nil
            } else {
                cell.expandCell()
                expandedCell = tableView.cellForRow(at: indexPath) as! ListExpandableCell!
                expandedCell?.tag = indexPath.row
            }
            tableView.beginUpdates()
            tableView.endUpdates()
        }
    }
}
