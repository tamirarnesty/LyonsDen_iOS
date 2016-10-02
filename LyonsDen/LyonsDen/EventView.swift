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
    
    @IBOutlet var labels: [UILabel]!
    
    // Instance of the content View of this class
    var contentView: UIView?

    override func draw(_ rect: CGRect) {
        self.layer.cornerRadius = 8
        self.layer.masksToBounds = true
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor(red: 0.0078, green: 0.1647, blue: 0.3922, alpha: 1).cgColor    // Could not access it from here
        
        if labels[0].isHidden {
            labels[1].frame.origin.y -= (labels[0].frame.height + 8)
            labels[2].frame.origin.y -= (labels[0].frame.height + 8)
            labels[3].frame.origin.y -= (labels[0].frame.height + 8)
        }
        if labels[1].isHidden {
            labels[2].frame.origin.y -= (labels[1].frame.height + 8)
            labels[3].frame.origin.y -= (labels[1].frame.height + 8)
        }
        
//        if labels[2].text != nil && !labels[2].text!.isEmpty {
//            labels[2].text = (labels[2].text! as NSString).substring(from: 11)
//        }
        
        labels[2].clipsToBounds = true
        labels[3].clipsToBounds = true
    }

    convenience init(withFrame frame:CGRect, params: [String?]) {
        var newFrame = frame
        var visibilities:[Bool] = [Bool](repeating: false, count: 2)
        
        newFrame.size.height = 8.0
        if params[0] != nil && !params[0]!.isEmpty {
            newFrame.size.height += 74.0
        } else { visibilities[0] = true }
        if params[1] != nil && !params[1]!.isEmpty {
            newFrame.size.height += 108.0
        } else { visibilities[1] = true }
        if (params[2] != nil && !params[2]!.isEmpty) || (params[3] != nil && !params[3]!.isEmpty) {
            newFrame.size.height += 33.0
        }
        
        self.init(frame: newFrame)
        for h in 0..<params.count {
            labels[h].text = params[h]
        }
        
        labels[0].isHidden = visibilities[0]
        labels[1].isHidden = visibilities[1]
    }
    
    // For creating this view programmatically
    override init(frame: CGRect) {
        // Create the UIView
        super.init(frame: frame)
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
        contentView!.autoresizingMask = [UIViewAutoresizing.flexibleWidth, UIViewAutoresizing.flexibleHeight]
        // Add the custom subview on top of our view (over any custom drawing)
        addSubview(contentView!)
    }
    
    // Load content from the .xib
    func loadViewFromNib() -> UIView! {
        // Declare the bundle of the .xib being used
        let bundle = Bundle(for: type(of: self))
        // Declare the xib instance
        let nib = UINib(nibName: nibName, bundle: bundle)
        // Create the view from the previously declared .xib instance
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! UIView
        // Return the created view
        return view
    }
}
