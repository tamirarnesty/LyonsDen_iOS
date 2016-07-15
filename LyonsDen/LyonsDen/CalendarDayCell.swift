//
//  KDCalendarDayCell.swift
//  KDCalendar
//
//  Created by Michael Michailidis on 02/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//
//  Commented by Inal Gotov

import UIKit

// The colour of a default cell
let cellColorDefault = UIColor(red: 0.0078, green: 0.1647, blue: 0.3922, alpha: 0.5)
// The colour of today's cell
let cellColorToday = UIColor(red: 0.0078, green: 0.1647, blue: 0.3922, alpha: 1)
// The colour of the border of a cell
let borderColor = UIColor(red: 0.9961, green: 0.7765, blue: 0.2784, alpha: 0.9)

// This class is used for the manipulation of an individual day cell of the calendar
class CalendarDayCell: UICollectionViewCell {
    
    // The count of events in a day
    var eventsCount = 0 {
        // didSet - Something that is called right after the value has been set
        // Horizontally adds dots for each event in the day
        didSet {
            for sview in self.dotsView.subviews {
                sview.removeFromSuperview()
            }
            
            let stride = self.dotsView.frame.size.width / CGFloat(eventsCount+1)
            let viewHeight = self.dotsView.frame.size.height
            let halfViewHeight = viewHeight / 2.0
            
            for _ in 0..<eventsCount {
                let frm = CGRect(x: (stride+1.0) - halfViewHeight, y: 0.0, width: viewHeight, height: viewHeight)
                let circle = UIView(frame: frm)
                circle.layer.cornerRadius = halfViewHeight
                circle.backgroundColor = borderColor
                self.dotsView.addSubview(circle)
            }
        }
    }
    
    // The value representing whether the dayCell represents today
    var isToday : Bool = false {
        // Changes the colour of the cell, to today's colors if true, otherwise default colors
        didSet {
            if isToday == true {
                self.pBackgroundView.backgroundColor = cellColorToday
            }
            else {
                self.pBackgroundView.backgroundColor = cellColorDefault
            }
        }
    }
    
    // The value representing whether the dayCell is selected
    override var selected : Bool {
        // Changes the border whenever it is selected
        didSet {
            if selected == true {
                self.pBackgroundView.layer.borderWidth = 2.0
            }
            else {
                self.pBackgroundView.layer.borderWidth = 0.0
            }
        }
    }
    
    // lazy - allocated and processed only when used, not when created. (Efficiency)
    // The background view of the dayCell
    lazy var pBackgroundView : UIView = {
        var vFrame = CGRectInset(self.frame, 3.0, 3.0)  // The frame of the view
        let view = UIView(frame: vFrame)                // The view
        
        view.layer.cornerRadius = 4.0                   // The round radious of the view's rectangle
        view.layer.borderColor = borderColor.CGColor    // The border color of the view's rectangle
        view.layer.borderWidth = 0.0                    // The border width of the view's rectangle
        
        view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)    // Position of the view's center (set in according to the parent)
        view.backgroundColor = cellColorDefault         // The view's background color
        
        return view
    }()
    
    // The UILabel that appears on the dayCell
    lazy var textLabel : UILabel = {
        let lbl = UILabel()     // Text Label
        lbl.textAlignment = NSTextAlignment.Center  // Text Allignment
        lbl.textColor = borderColor     // TEXT COLOR!!!!
        
        return lbl
    }()
    
    // The dot that represents that the day has an event
    lazy var dotsView : UIView = {
        let frm = CGRect(x: 8.0, y: self.frame.size.width - 10.0 - 4.0, width: self.frame.size.width - 16.0, height: 8.0)   // The dot's frame
        let dv = UIView(frame: frm)     // The 'View' of the dot
        
        return dv
    }()

    // The initializer(constructor) of the dayCell
    override init(frame: CGRect) {
        super.init(frame: frame)    // Call parent initializer
        
        self.addSubview(self.pBackgroundView)   // Add background to the dayCell view
        self.textLabel.frame = self.bounds      // Set textLabel's size to the size of the dayCell
        self.addSubview(self.textLabel)         // Add the textLabel
        self.addSubview(dotsView)               // Add the events dot, if any
    }

    // I still dont know what that is
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
