//
//  KDCalendarFlowLayout.swift
//  KDCalendar
//
//  Created by Michael Michailidis on 02/04/2015.
//  Copyright (c) 2015 Karmadust. All rights reserved.
//
//  Commented by Inal Gotov

import UIKit

// This class is used as a costumized version of UICollectionView's FlowLayout
class CalendarFlowLayout: UICollectionViewFlowLayout {
    
    // Returns an array of UIColectionViewAttributes for each subview/component in a given rectangle
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        // Call the super version of this method while changing certaim parameters for the outputted array
        // Whatever is in the closure (brackets) is called for each item of the array
        return super.layoutAttributesForElements(in: rect)?.map {
            attrs in
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes     // Create a copy of the original attribute
            self.applyLayoutAttributes(attrscp)                                 // Recreatethis attribute to be appropriate for this layout
            return attrscp                                                      // Return
        }
    }
    
    // Performs the same operations as the method above with the only difference of
    // being able to select an item using its array index
    // May return nil.
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        if let attrs = super.layoutAttributesForItem(at: indexPath) {
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
        return nil
    }
    
    // Resizes and repositions the given attributes on the layout
    func applyLayoutAttributes(_ attributes : UICollectionViewLayoutAttributes) {
        if attributes.representedElementKind != nil {   // If this attribute is not associated with anything, return
            return
        }
        if let collectionView = self.collectionView {   // If this view has a layout
            let stride = (self.scrollDirection == .horizontal) ? collectionView.frame.size.width : collectionView.frame.size.height // Calculate the offSet multiplier
            let offset = CGFloat((attributes.indexPath as NSIndexPath).section) * stride                                 // Calculate the offSet
            var xCellOffset : CGFloat = CGFloat((attributes.indexPath as NSIndexPath).item % 7) * self.itemSize.width    // Calculate x position
            var yCellOffset : CGFloat = CGFloat((attributes.indexPath as NSIndexPath).item / 7) * self.itemSize.height   // Calculate y position
            if(self.scrollDirection == .horizontal) {   // If direction is - then add offset to the x coordinate
                xCellOffset += offset;
            } else {                                    // If direction is | then add offset to the y coordinate
                yCellOffset += offset
            }
            attributes.frame = CGRect(x: xCellOffset, y: yCellOffset, width: self.itemSize.width, height: self.itemSize.height)  // Change attribute size and position
        }
    }
}
