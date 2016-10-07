//
//  InfotViewController.swift
//  LyonsDen
//
//  The InfoViewContrller will be used for displaying announcements and other info.
//  To use, first set the values of title, info and image (only this can be nil) and then segue into it.
//
//  Created by Inal Gotov on 2016-06-30.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

// This crap works!!!

// This crap really works!!!

import UIKit

class InfoViewController: UIViewController {
    // The text for the title label
    var eventTitle:String = "This is an announcement"
    // The text for the description label
    var eventInfo:String? = "This is what the announcement is about"
    // The text for the date label
    var eventDate:String? = "This is when the announcement is"
    // The text for the location label
    var eventLocation:String? = "This is where the announcement is"
    // The image for the announcement
    var eventImage: UIImage?
    // Title label
    @IBOutlet var titleView: UILabel!
    // Description label Text View
    @IBOutlet var infoView: UITextView!
    // Announcemnet image
    @IBOutlet var imageView: UIImageView!
    // Date label
    @IBOutlet var dateView: UILabel!
    // Location label
    @IBOutlet var locationView: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.tintColor = colorNavigationText
        
        titleView.text = eventTitle  // Set title text
        infoView.text = eventInfo    // Set description text
        if let img = eventImage {     // If an announcemnt image is present
            imageView.image = img       // Set the image
            // Move the title label to the side, if not already moved (Removes the additional constraint)
            self.view.removeConstraint(NSLayoutConstraint(item: titleView.superview!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -8))
            imageView.isHidden = false    // Show the image
        } else {    // If not announcement image is present
            imageView.isHidden = true     // Hide the image just in case
            // Move the title label to the left side (Add an additional constraint)
            self.view.addConstraint(NSLayoutConstraint(item: titleView.superview!, attribute: NSLayoutAttribute.leading, relatedBy: NSLayoutRelation.equal, toItem: titleView, attribute: NSLayoutAttribute.leading, multiplier: 1, constant: -8))
        }
        
        if let date = eventDate {
            dateView.isHidden = false     // Just in case
            dateView.text = date
        } else {
            dateView.isHidden = true
        }
        
        if let location = eventLocation {
            locationView.isHidden = false     // Just in case
            locationView.text = location
        } else {
            locationView.isHidden = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
