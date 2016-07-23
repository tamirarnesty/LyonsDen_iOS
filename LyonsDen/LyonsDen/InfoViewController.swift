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
    static var title:String = "This is an announcement"
    // The text for the description label
    static var info:String? = "This is what the announcement is about"
    // The image for the announcement
    static var image: UIImage? 
    // Title label
    @IBOutlet var titleLabel: UILabel!
    // Description label Text View
    @IBOutlet var infoView: UITextView!
    // Announcemnet image
    @IBOutlet var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        titleLabel.text = InfoViewController.title  // Set title text
        infoView.text = InfoViewController.info    // Set description text
        if let img = InfoViewController.image {     // If an announcemnt image is present
            imageView.image = img       // Set the image
            // Move the title label to the side, if not already moved (Removes the additional constraint)
            self.view.removeConstraint(NSLayoutConstraint(item: titleLabel.superview!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -8))
            imageView.hidden = false    // Show the image
        } else {    // If not announcement image is present
            imageView.hidden = true     // Hide the image just in case
            // Move the title label to the left side (Add an additional constraint)
            self.view.addConstraint(NSLayoutConstraint(item: titleLabel.superview!, attribute: NSLayoutAttribute.Leading, relatedBy: NSLayoutRelation.Equal, toItem: titleLabel, attribute: NSLayoutAttribute.Leading, multiplier: 1, constant: -8))
        }
    }
    
    static func setupViewController (title:String, info:String?, image:UIImage?) {
        InfoViewController.title = title
        InfoViewController.info = info
        InfoViewController.image = image
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}