//
//  TumblerPhotoCell.swift
//  tumblr
//
//  Created by appleseed on 21.09.16.
//  Copyright © 2016 Dacadoo. All rights reserved.
//

import Foundation
import UIKit

class TumblrPhotoCell: UICollectionViewCell
{
    @IBOutlet weak var imageView: UIImageView!
    
    private let SHADOW_COLOR: CGFloat = 157.0 / 255.0
    
    override func awakeFromNib()
    {
        layer.cornerRadius = 5.0
        layer.borderColor = UIColor(
            red: SHADOW_COLOR,
            green: SHADOW_COLOR,
            blue: SHADOW_COLOR,
            alpha: 0.1).CGColor
        
        layer.borderWidth = 2.0
    }
}
