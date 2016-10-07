//
//  KDCalendarHeaderView.swift
//  KDCalendar
//
//  Created by Michael Michailidis on 07/04/2015.
//  Modified by Inal Gotov on 12/07/2016
//  Added buttons for scrolling
//
//  Copyright (c) 2015 Karmadust. All rights reserved.
//
//  Commented and Modified by Inal Gotov

import UIKit

// This class is used for the manipulation of the header of this calendar
class CalendarHeaderView: UIView {
    let colorMain = colorNavigationText
    
    // The label that represent the month
    lazy var monthLabel : UILabel = {
        let lbl = UILabel()                                 // Create label
        lbl.textAlignment = NSTextAlignment.center          // Center the text allignment
        lbl.font = UIFont(name: "Helvetica", size: 20.0)    // Helvetica the font with size 20
        lbl.textColor = self.colorMain                      // Paint the text gray
        
        lbl.isUserInteractionEnabled = true
        
        let doubleTapListener = UITapGestureRecognizer(target: self, action: #selector(resetDate))
        doubleTapListener.numberOfTapsRequired = 2
        doubleTapListener.numberOfTouchesRequired = 1
        lbl.addGestureRecognizer(doubleTapListener)
        
        self.addSubview(lbl)                                // Add the label to the header
        return lbl
    }()
    
    // The label that represents the days of the week
    lazy var dayLabelContainerView : UIView = {
        let v = UIView()                                        // Create the day's view
        let formatter : DateFormatter = DateFormatter()     // Create a day's formatter
        
        for index in 1...7 {
            let day : NSString = formatter.weekdaySymbols[index % 7] as NSString    // Create the string containing the day's letter
            let weekdayLabel = UILabel()                                    // Create the label the will hold the day of the week
            
            weekdayLabel.font = UIFont(name: "Helvetica", size: 14.0)       // Helvetica the label's font with size 14
            weekdayLabel.text = day.substring(to: 2).uppercased()     // Set the text of the label to the first two letters of the weekday in caps
            weekdayLabel.textColor = self.colorMain                         // Paint the text gray
            weekdayLabel.textAlignment = NSTextAlignment.center             // Center the text allignment
            v.addSubview(weekdayLabel)                                      // Add the label to the day's view
        }
        
        self.addSubview(v)      // Add the day's view to the header
        return v
    }()
    
    // Create a header in the given rectangle
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    // I still dont know what this is for
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Lays out the subviews(header parts) of this view
    override func layoutSubviews() {
        super.layoutSubviews()      // Calls the superversion of this method
        
        var frm = self.bounds       // Create an instance of this view's boundaries
        // Increase it vertically
        frm.origin.y += 5.0
        frm.size.height = 40.0
        self.monthLabel.frame = frm
        // Create a label for a single day of the week
        var labelFrame = CGRect(x: 0.0, y: self.bounds.size.height / 2.0, width: self.bounds.size.width / 7.0, height: self.bounds.size.height / 2.0)
        for lbl in self.dayLabelContainerView.subviews {
            lbl.frame = labelFrame                          // Set the size of a single day in the 'days of the week' view
            labelFrame.origin.x += labelFrame.size.width    // Move the counter a bit
        }
        
        // Extra Code from this point on.
        self.addSubview (createNavigationArrow(withFrame: CGRect(x: 5, y: 15, width: 25, height: 25),
                                                      image: (UIImage(named: "LeftButton")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!,
                                                      tag: 0))
        self.addSubview (createNavigationArrow(withFrame: CGRect(x: self.frame.width - 30, y: 15, width: 25, height: 25),
                                                       image: (UIImage(named: "RightButton")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate))!,
                                                       tag: 1))
    }
    
    func createNavigationArrow(withFrame frame:CGRect, image:UIImage, tag:Int) -> UIButton {
        let button = UIButton(frame: frame)
        
        button.setImage(image, for: UIControlState())
        button.tintColor = self.colorMain
        button.tag = tag
        button.alpha = 0.7  // Visuals
        button.addTarget(CalendarView(), action: #selector(CalendarView.changeMonth), for: .touchUpInside)
        
        return button
    }
    
    func resetDate () {
        (superview as! CalendarView).resetDate()
    }
}
