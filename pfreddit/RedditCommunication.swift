//
//  RedditCommunication.swift
//  pfreddit
//
//  Created by David Lee on 11/19/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import UIKit

enum RedditOrdering: String {
	case Hot = "hot"
	case Top = "top"
}

class RedditCommunication {
	class func loadPostsFromSubreddit(subreddit: String, ordering: RedditOrdering, callback: ([Post]? -> Any)) {
		let urlString = "https://www.reddit.com/r/\(subreddit)/\(ordering.rawValue	).json"
		let requestURLOpt = NSURL(string: urlString)
		
		guard let requestURL = requestURLOpt else {
			callback(nil)
			return
		}
		
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		// personal modhash
		config.HTTPAdditionalHeaders = [ "X-Modhash": "nzjp7svpla5650b2dc97a11c44c687e52a6d757777171cb5e3" ]
		let urlSession = NSURLSession.sharedSession()
		
		let dataTask = urlSession.dataTaskWithRequest(NSURLRequest(URL: requestURL), completionHandler: { data, response, err -> Void in
			let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
			let stories = json["data"]["children"]
			
			let postsOpts = stories.map { (str, storyJson) -> Post? in
				guard let title = storyJson["data"]["title"].string else {
					print("Could not retrieve post title.")
					return nil
				}
				guard let imgURLString = storyJson["data"]["thumbnail"].string else {
					print("Could not retrieve post content.")
					return nil
				}
				guard let imgData = NSData.init(contentsOfURL: NSURL(string: imgURLString)!) else {
					print("Could not parse post content.")
					return nil
				}
				guard let img = UIImage(data: imgData) else {
					print("Could not parse content as image.")
					return nil
				}
				
				guard let url = storyJson["data"]["url"].string else {
					print("Could not retrieve post URL.")
					return nil
				}
				let imgurId = ImgurCommunication.imgurIdFromURL(url)
				if let imgurImgId = imgurId["image"] {
					ImgurCommunication.getDirectLink(imgurImgId, callback: {
						(lnk, id, error) -> Void in
						print("Got link", lnk)
					})
				}
				
				return Post(metadata: PostMetadata(title: title),
					content: Content.Image(ImageContent(image: img)))
			}
			callback(postsOpts.flatMap { $0 })
		})
		dataTask.resume()
	}
}