//
//  ToastView.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-10-01.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation

class ToastView: UIView {
    // The text displayed in the toast
    var displayText:String
    let parentCenter:CGPoint
    var duration:TimeInterval = 1.1
    
    // The method that draws the view
    override func draw(_ rect: CGRect) {
        // Declare and setup the label
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = label.font.withSize(18)
        label.numberOfLines = 0
        label.textAlignment = NSTextAlignment.center
        label.text = displayText
        label.sizeToFit()
        // Configure toast size
        self.frame.size.width = label.frame.width + 16
        self.frame.size.height = label.frame.height + 16
        // Add label
        self.addSubview(label)
        // Position label
        label.frame.origin.x = 8
        label.frame.origin.y = 8
        // Position Toast
        self.center.x = parentCenter.x
        self.center.y = parentCenter.y
        // Configure colors
        self.backgroundColor = UIColor(white: 0, alpha: 0.25)
        self.alpha = 0
        label.alpha = 0.7
    }
    
    func initiate () {
        // Initiate display animation
        UIView.animate(withDuration: 0.1, animations: { self.alpha = 1 })
        UIView.animate(withDuration: 0.1, delay: duration, options: .allowAnimatedContent, animations: { self.alpha = 0 }, completion: { (completed) in if completed { self.removeFromSuperview() } })
    }
    
    convenience init(inView view:UIView, withText text:String, andDuration duration:Int) {
        // Create the view with an empty frame (overriden later anyway)
        self.init(frame: CGRect.zero, inView: view, withText: text)
        self.duration = TimeInterval(duration)
    }
    
    convenience init(inView view:UIView, withText text:String) {
        // Create the view with an empty frame (overriden later anyway)
        self.init(frame: CGRect.zero, inView: view, withText: text)
    }
    
    init(frame: CGRect, inView view:UIView, withText text:String) {
        // Set variables
        displayText = text
        parentCenter = view.center
        // Crate view with default frame
        super.init(frame: CGRect(x: (view.center.x - (135/2)), y: (view.center.y - (45/2)), width: 135, height: 45))
    }
    
    // This is required
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
