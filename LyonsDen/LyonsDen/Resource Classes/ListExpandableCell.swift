//
//  ListExpandableCell.swift
//  LyonsDen
//
//  Created by Inal Gotov on 2016-10-03.
//  Copyright © 2016 William Lyon Mackenize CI. All rights reserved.
//


// GREETINGS FROM XCODE REINSTALL

import Foundation

class ListExpandableCell: UITableViewCell {
    let creatorWidth:CGFloat
    var titleLabel:UILabel!
    var descriptionLabel:UILabel!
    var dateLabel:UILabel!
    var infoButton:UIButton!
    let buttonHandler:(Int) -> Void
    
    var isExpanded = true {
        didSet (newValue) {
            if newValue { print ("Cell is now colapsed") } else { print ("Cell is now expanded") }
            UIView.animate(withDuration: 0.1) { 
                self.descriptionLabel.alpha = (newValue) ? 1 : 0
                self.dateLabel.alpha = (newValue) ? 1 : 0
                self.infoButton.alpha = (newValue) ? 1 : 0
            }
            print (self.frame.height)
        }
    }
    
    init(style: UITableViewCellStyle, reuseIdentifier: String?, index:Int, creatorWidth:CGFloat, buttonHandler:@escaping (Int) -> Void) {
        self.creatorWidth = creatorWidth
        self.buttonHandler = buttonHandler
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.tag = index
        
        self.backgroundColor = UIColor(red: 0.9294, green: 0.9686, blue: 1, alpha: 1.0) /* #edf7ff */
        self.textLabel?.textColor = UIColor.black
        
        titleLabel = UILabel(frame: CGRect(x: 8, y: 2, width: creatorWidth, height: 44))
        titleLabel.textColor = UIColor.black
        self.addSubview(titleLabel)
        
        descriptionLabel = UILabel(frame: CGRect(x: 8, y: 45, width: creatorWidth - 54, height: 60))
        descriptionLabel.textColor = UIColor.black
        descriptionLabel.numberOfLines = 0
        descriptionLabel.font = descriptionLabel.font.withSize(14)
        descriptionLabel.alpha = (!isExpanded) ? 1 : 0
        self.addSubview(descriptionLabel)
        
        dateLabel = UILabel(frame: CGRect(x: 8, y: 113, width: creatorWidth, height: 20))
        dateLabel.textColor = UIColor.black
        dateLabel.alpha = (!isExpanded) ? 1 : 0
        self.addSubview(dateLabel)
        
        infoButton = UIButton(type: UIButtonType.infoLight)
        infoButton.frame = CGRect(x: creatorWidth - 38, y: 148/2, width: 30, height: 30)
        infoButton.tintColor = colorAccent
        infoButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)
        infoButton.alpha = (!isExpanded) ? 1 : 0
        self.addSubview(infoButton)
        print (self.frame.height)
    }
    
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func buttonTapped () {
        buttonHandler(self.tag)
    }
}
