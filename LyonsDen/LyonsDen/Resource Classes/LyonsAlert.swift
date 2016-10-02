//
//  LyonsAlert.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-10-01.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//

import Foundation

class LyonsAlert {
    var alertView:UIAlertController
    var loadingWheel:UIActivityIndicatorView!
    
    init (withTitle title:String, subtitle:String, style:UIAlertControllerStyle) {
        alertView = UIAlertController(title: title, message: subtitle, preferredStyle: style)
        loadingWheel = nil
    // MARK: VISUAL CUSTOMIZATIONS
        // Change text colors (you can change font too!)
        let font = UIFont(name: "Hapna Mono", size: 17)
        let font2 = UIFont(name: "Hapna Mono", size: 14)
        alertView.setValue(NSAttributedString(string: title, attributes: [NSFontAttributeName : font, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedTitle")
        alertView.setValue(NSAttributedString(string: subtitle, attributes: [NSFontAttributeName : font2, NSForegroundColorAttributeName : UIColor.black]), forKey: "attributedMessage")
    }
    
    func showIn (_ initiator:UIViewController) {
        initiator.present(alertView, animated: true) {}
//        initiator.present(alertView, animated: true, completion:  )
        // Change text color of buttons, has to be done after added, otherwise color changes back after first press
        alertView.view.tintColor = colorAccent
        
        if let textFields = alertView.textFields {
            for textField in textFields {
                // To make the textfield have no background (code specific to UIAlertController)
                let container:UIView! = textField.superview!
                let effectView = container.superview?.subviews.first
                if effectView is UIVisualEffectView {
                    container.backgroundColor = UIColor.clear
                    effectView?.removeFromSuperview()
                }
            }
        }
    }
    
    func addLoadingWheel () {
        let wheel = UIActivityIndicatorView(frame: alertView.view.bounds)
        wheel.activityIndicatorViewStyle = .gray
        wheel.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        loadingWheel = wheel
        alertView.view.addSubview(loadingWheel)
        loadingWheel.isUserInteractionEnabled = false
        loadingWheel.startAnimating()
    }
    
    func stopAnimating () {
        loadingWheel.stopAnimating()
        loadingWheel.removeFromSuperview()
    }
    
    func addAction (_ action:UIAlertAction) {
        alertView.addAction(action)
    }
    
    func addTextFieldWithPlaceHolder (_ placeHolder:String) {
        alertView.addTextField { (textField) in
            textField.keyboardAppearance = UIKeyboardAppearance.dark
            textField.borderStyle = UITextBorderStyle.none
            textField.placeholder = placeHolder
            textField.autocorrectionType = UITextAutocorrectionType.no
            textField.textColor = accentColor
            textField.textAlignment = NSTextAlignment.center
        }
    }
}
