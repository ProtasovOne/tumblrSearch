//
//  TumblrSearch.swift
//  tumblr
//
//  Created by appleseed on 21.09.16.
//  Copyright © 2016 Dacadoo. All rights reserved.
//
import Foundation
import UIKit

struct TumblrSearchResults
{
    let searchTerm : String
    let searchResults : [TumblrPhoto]
}

class TumblrPhoto : Equatable
{
    var thumbnail : UIImage?
    var largeImage : UIImage?
    let photoID : String
    let photoUrl: String
    
    init (photoID:String, photoUrl:String)
    {
        self.photoID = photoID
        self.photoUrl = photoUrl
    }
    
    func tumblrImageURL(size:String = "m") -> NSURL
    {
        return NSURL(string:photoUrl)!
    }
    
    func loadLargeImage(completion: (tumblrPhoto:TumblrPhoto, error: NSError?) -> Void)
    {
        let loadURL = tumblrImageURL("b")
        let loadRequest = NSURLRequest(URL:loadURL)
        
        let task = NSURLSession
            .sharedSession()
            .dataTaskWithRequest(
            loadRequest) { data, response, error in
                
                if error != nil {
                    completion(tumblrPhoto: self, error: error)
                    return
                }
                
                if data != nil {
                    let returnedImage = UIImage(data: data!)
                    self.largeImage = returnedImage
                    completion(tumblrPhoto: self, error: nil)
                    return
                }
                
                completion(tumblrPhoto: self, error: nil)
        }
        
        task.resume()
    }
    
    func sizeToFillWidthOfSize(size:CGSize) -> CGSize
    {
        if thumbnail == nil {
            return size
        }
        
        let imageSize = thumbnail!.size
        var returnSize = size
        
        let aspectRatio = imageSize.width / imageSize.height
        
        returnSize.height = returnSize.width / aspectRatio
        
        if returnSize.height > size.height {
            returnSize.height = size.height
            returnSize.width = size.height * aspectRatio
        }
        
        return returnSize
    }
    
}

func == (lhs: TumblrPhoto, rhs: TumblrPhoto) -> Bool
{
    return lhs.photoID == rhs.photoID
}

class Tumblr
{
    let processingQueue = NSOperationQueue()
    
    func searchtumblrForTerm(
        searchTerm: String,
        completion : (results: TumblrSearchResults?, error : NSError?) -> Void)
    {
        guard let searchURL = tumblrSearchURLForSearchTerm(searchTerm)
        else
        {
            print("search URL is nil")
            completion(results: nil, error: nil)
            return
        }
        
        let searchRequest = NSURLRequest(URL: searchURL)
        
        let task = NSURLSession
            .sharedSession()
            .dataTaskWithRequest(searchRequest) {data, response, error in
                
                if error != nil
                {
                    completion(results: nil, error: error)
                    return
                }
                
                var resultsDictionary: NSDictionary?
                do
                {
                    resultsDictionary = try NSJSONSerialization
                        .JSONObjectWithData(
                            data!,
                            options:NSJSONReadingOptions(
                                rawValue: 0)) as? NSDictionary
                }
                catch
                {
                    completion(results: nil, error: nil)
                    return
                }
                
                switch (resultsDictionary!["meta"]!["msg"] as! String)
                {
                case "OK":
                    print("Results processed OK")
                case "fail":
                    let APIError = NSError(domain: "tumblrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:resultsDictionary!["message"]!])
                    completion(results: nil, error: APIError)
                    return
                default:
                    let APIError = NSError(domain: "tumblrSearch", code: 0, userInfo: [NSLocalizedFailureReasonErrorKey:"Uknown API response"])
                    completion(results: nil, error: APIError)
                    return
                }
               
                let photosContainer = resultsDictionary!["response"] as! NSArray
                let tumblrPhotos : [TumblrPhoto] = photosContainer.map {
                    photoDictionary in
                    
                    let photoID = photoDictionary["summary"] as? String ?? ""
                    let photoUrl: String;
                    if photoDictionary["type"]as? String ?? "" != "photo"
                    {
                        photoUrl = "http://66.media.tumblr.com/54cd158b90d726d9b75dceb5f341e2df/tumblr_oe2cfsjUMb1uekk2io1_1280.jpg"
                    }
                    else
                    {
                        photoUrl = photoDictionary["photos"]!![0]["original_size"]!!["url"] as? String ?? ""
                    }

                    let tumblrPhoto = TumblrPhoto(photoID: photoID, photoUrl: photoUrl)
                    
                    let imageData = NSData(contentsOfURL: NSURL(string:tumblrPhoto.photoUrl)!)
                    tumblrPhoto.thumbnail = UIImage(data: imageData!)
                    
                    return tumblrPhoto
                }
                
                dispatch_async(dispatch_get_main_queue(), {
                    completion(results:TumblrSearchResults(searchTerm: searchTerm, searchResults: tumblrPhotos), error: nil)
                })
        }
        task.resume()
    }
    
    private func tumblrSearchURLForSearchTerm(searchTerm:String) -> NSURL?
    {
        guard let escapedTerm = searchTerm
            .stringByTrimmingCharactersInSet(
                NSCharacterSet.whitespaceAndNewlineCharacterSet())
            .stringByAddingPercentEncodingWithAllowedCharacters(
                .URLHostAllowedCharacterSet())
        else
        {
            return nil
        }
        let urlString = "http://api.tumblr.com/v2/tagged?tag=\(escapedTerm)&api_key=CcEqqSrYdQ5qTHFWssSMof4tPZ89sfx6AXYNQ4eoXHMgPJE03U"
        let url = NSURL(string: urlString)
        return url
    }
}
