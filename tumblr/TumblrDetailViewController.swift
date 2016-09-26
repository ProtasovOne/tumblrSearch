//
//  TumblrDetailViewController.swift
//  tumblr
//
//  Created by appleseed on 26.09.16.
//  Copyright © 2016 Dacadoo. All rights reserved.
//

import Foundation
import UIKit

class TumblrDetailViewController: UIViewController{
@IBOutlet weak var imageView: UIImageView!

var fruit: TumblrPhoto?

override func viewDidLoad() {
    super.viewDidLoad()
    
    if let fruit = fruit {
        navigationItem.title = fruit.photoID.capitalizedString
        imageView.image = fruit.thumbnail
       imageView.frame = imageView .displayedImageBounds()
    }
}

override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
}
}
extension UIImageView {
    
    func displayedImageBounds() -> CGRect {
        
        let boundsWidth = bounds.size.width
        let boundsHeight = bounds.size.height
        let imageSize = image!.size
        let imageRatio = imageSize.width / imageSize.height
        let viewRatio = boundsWidth / boundsHeight
        if ( viewRatio > imageRatio ) {
            let scale = boundsHeight / imageSize.height
            let width = scale * imageSize.width
            let topLeftX = (boundsWidth - width) * 0.5
            return CGRectMake(topLeftX, 0, width, boundsHeight)
        }
        let scale = boundsWidth / imageSize.width
        let height = scale * imageSize.height
        let topLeftY = (boundsHeight - height) * 0.5
        return CGRectMake(0,topLeftY, boundsWidth,height)
    }
}