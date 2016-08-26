//
//  EventView.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-07-15.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import UIKit

class EventView: UIView {
    // Name holder for the .xib of this file
    let nibName:String = "EventVisual"
    // Instance of the Title Label of this class
    @IBOutlet var titleLabel: UILabel!
    // Instance of the Description Label of this class
    @IBOutlet var infoLabel: UILabel!
    // Instance of the Time Label of this class
    @IBOutlet var timeLabel: UILabel!
    // Instance of the Location Label of this class
    @IBOutlet var locationLabel: UILabel!
    // Instance of the content View of this class
    var contentView: UIView?
    
    override func drawRect(rect: CGRect) {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 0.0078, green: 0.1647, blue: 0.3922, alpha: 1).CGColor    // Could not access it from here
        
        locationLabel.clipsToBounds = true
        timeLabel.clipsToBounds = true
    }
    
    // For creating this view programmatically
    override init(frame: CGRect) {
        // Create the UIView
        super.init(frame: CGRectMake(frame.origin.x, frame.origin.y, frame.width, 316))
        // Create the content View of this UIView
        xibSetup()
    }
    
    // For creating this view with an Interface Builder
    required init?(coder aDecoder: NSCoder) {
        // Create the UIView
        super.init(coder: aDecoder)
        // Create the content View of this UIView
        xibSetup()
    }
    
    // The credits for the following code go to Garfbargle@ http://stackoverflow.com/a/37668821
    // Partially commented by Inal Gotov
    
    // Create the contentView of this UIView
    func xibSetup() {
        // Create the contents
        contentView = loadViewFromNib()
        // Use bounds not frame or it'll be set off
        contentView!.frame = bounds
        // Make the view stretch with parent view
        contentView!.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        // Add the custom subview on top of our view (over any custom drawing)
        addSubview(contentView!)
    }
    
    // Load content from the .xib
    func loadViewFromNib() -> UIView! {
        // Declare the bundle of the .xib being used
        let bundle = NSBundle(forClass: self.dynamicType)
        // Declare the xib instance
        let nib = UINib(nibName: nibName, bundle: bundle)
        // Create the view from the previously declared .xib instance
        let view = nib.instantiateWithOwner(self, options: nil)[0] as! UIView
        // Return the created view
        return view
    }
}
