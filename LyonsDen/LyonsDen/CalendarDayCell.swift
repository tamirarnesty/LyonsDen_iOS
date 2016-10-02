//
//  KDCalendarDayCell.swift
//  KDCalendar
//
//  Created by Michael Michailidis on 02/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//
//  Commented and Modified by Inal Gotov

import UIKit

// This class is used for the manipulation of an individual day cell of the calendar
class CalendarDayCell: UICollectionViewCell {
    let colorCellDefault = colorEventViewBackground.withAlphaComponent(0.5)
    let colorCellEvent = colorEventViewBackground.withAlphaComponent(0.85)
    let colorTodayDot = colorWhiteText
    let colorBorder = colorNavigationBar
    let colorCellText = colorWhiteText
    
    
    // New scheme:
    // Regular cells stay the same
    // Event cells get less opaque bg
    // Today's cell gets a dot
    // Selected get border
    
    var containsEvent = false {
        didSet {
            pBackgroundView.backgroundColor = colorCellDefault
            if containsEvent == true {
                pBackgroundView.backgroundColor = colorCellEvent
            }
        }
    }
    
    // The value representing whether the dayCell represents the current date
    var isToday : Bool = false {
        // Changes the colour of the cell, to today's colors if true, otherwise default colors
        didSet {
            for sview in self.dotsView.subviews {
                sview.removeFromSuperview()
            }
            
            if isToday == true {
                let stride = self.dotsView.frame.size.width / 2
                let viewHeight = self.dotsView.frame.size.height
                let halfViewHeight = viewHeight / 2.0
                
                let circle = UIView(frame: CGRect(x: (stride+1.0) - halfViewHeight, y: 0.0, width: viewHeight, height: viewHeight))
                circle.layer.cornerRadius = halfViewHeight
                circle.backgroundColor = colorTodayDot
                self.dotsView.addSubview(circle)
            }
        }
    }
    
    // The value representing whether the dayCell is selected
    override var isSelected : Bool {
        // Changes the border whenever it is selected
        didSet {
            if isSelected == true {
                self.pBackgroundView.layer.borderWidth = 2.5
            }
            else {
                self.pBackgroundView.layer.borderWidth = 0.0
            }
        }
    }
    
    // lazy - allocated and processed only when used, not when created. (Efficiency)
    // The background view of the dayCell
    lazy var pBackgroundView : UIView = {
        var vFrame = self.frame.insetBy(dx: 3.0, dy: 3.0)  // The frame of the view
        let view = UIView(frame: vFrame)                // The view
        
        view.layer.cornerRadius = (view.frame.height)/2                   // The round radious of the view's rectangle
        view.layer.borderColor = self.colorBorder.cgColor    // The border color of the view's rectangle
        view.layer.borderWidth = 0.0                    // The border width of the view's rectangle
        
        view.center = CGPoint(x: self.bounds.size.width * 0.5, y: self.bounds.size.height * 0.5)    // Position of the view's center (set in according to the parent)
        view.backgroundColor = self.colorCellDefault         // The view's background color
        
        return view
    }()
    
    // The UILabel that appears on the dayCell
    lazy var textLabel : UILabel = {
        let lbl = UILabel()     // Text Label
        lbl.textAlignment = NSTextAlignment.center  // Text Allignment
        lbl.textColor = self.colorCellText     // TEXT COLOR!!!!
        
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

    // Intergration with IB, doesnt work?
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
}
