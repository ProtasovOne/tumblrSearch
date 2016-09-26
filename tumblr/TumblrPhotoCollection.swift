//
//  tumblrPhotoCollection.swift
//  tumblr
//
//  Created by appleseed on 21.09.16.
//  Copyright © 2016 Dacadoo. All rights reserved.
//

import Foundation
import UIKit

class TumblrPhotoCollection: UICollectionViewController
{
    
    // set reuse id in main.storyboard
    private let tumblrCellReuseID = "tumblrCellReuseID"
    
    private let sectionInsets = UIEdgeInsets(top: 50.0, left: 20.0, bottom: 50.0, right: 20.0)
    
    private var searches = [TumblrSearchResults]()
    private let tumblr = Tumblr()
    
    func photoForIndexPath(indexPath: NSIndexPath) -> TumblrPhoto
    {
        return searches[indexPath.section].searchResults[indexPath.row]
    }
    
    
    // Data Source methods
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return searches.count
    }
    
    override func collectionView(collectionView: UICollectionView,numberOfItemsInSection section: Int) -> Int
    {
        return searches[section].searchResults.count
    }
    
    override func collectionView(collectionView: UICollectionView,cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(
                    tumblrCellReuseID,
                    forIndexPath: indexPath) as! TumblrPhotoCell
            
            let tumblrPhoto = photoForIndexPath(indexPath)
            cell.backgroundColor = UIColor.blackColor()
            cell.imageView.image = tumblrPhoto.thumbnail
            
            return cell
    }
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AffiliationDetail", let destination = segue.destinationViewController as? TumblrDetailViewController {
            if let cell = sender as? TumblrPhotoCell, indexPath = collectionView!.indexPathForCell(cell) {
                let tumblrPhoto = photoForIndexPath(indexPath)
                destination.fruit = tumblrPhoto
            }
        }
    }
}

extension TumblrPhotoCollection: UITextFieldDelegate
{
    
    func textFieldShouldReturn(textField: UITextField) -> Bool
    {
        let activityIndicator = UIActivityIndicatorView(
            activityIndicatorStyle: .Gray)
        textField.addSubview(activityIndicator)
        activityIndicator.frame = textField.bounds
        activityIndicator.startAnimating()
        
        guard let searchText = textField.text where searchText != ""
        else {
                activityIndicator.removeFromSuperview()
                return false
             }
        
        print(searchText)
        
        tumblr.searchtumblrForTerm(searchText) {// call back
            results, error in
            
            activityIndicator.removeFromSuperview()
            if error != nil
            {
                print("Error searching : \(error)")
            }
            
            if results != nil
            {
                print("Found \(results!.searchResults.count) matching \(results!.searchTerm)")
                self.searches.insert(results!, atIndex: 0)
                self.collectionView?.reloadData()
            }
        }
        textField.text = nil
        textField.resignFirstResponder()
        return true
    }
}


extension TumblrPhotoCollection: UICollectionViewDelegateFlowLayout
{
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize
    {
        
        let tumblrPhoto =  photoForIndexPath(indexPath)
        
        if var size = tumblrPhoto.thumbnail?.size
        {
            size.width = 300
            size.height += 10
            size.height /= 2
            size.width /= 2
            return size
        }
        return CGSize(width: 100, height: 100)
    }
    
    
    func collectionView(collectionView: UICollectionView,layout collectionViewLayout: UICollectionViewLayout,insetForSectionAtIndex section: Int)
        -> UIEdgeInsets
    {
        return sectionInsets
    }
}