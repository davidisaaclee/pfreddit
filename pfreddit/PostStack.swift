//
//  PostStack.swift
//  pfreddit
//
//  Created by David Lee on 11/17/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

class PostStack: NSObject {
	private var _stack: [Post]
	var stack: [Post] {
		get {
			return _stack
		}
	}
	
	override init() {
		_stack = []
		super.init()

		RedditCommunication.loadPostsFromSubreddit("all", ordering: RedditOrdering.Hot, callback: { maybePosts -> Void in
			print("Got posts: ", maybePosts)
			if maybePosts != nil {
				self.pushPosts(maybePosts!)
			}
		})
	}
	
//	func loadPostsFromReddit() {
//		let requestURL = NSURL(string: "https://www.reddit.com/r/all/hot.json")
//		
//		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
//		// personal modhash
//		config.HTTPAdditionalHeaders = [ "X-Modhash": "nzjp7svpla5650b2dc97a11c44c687e52a6d757777171cb5e3" ]
//		let urlSession = NSURLSession.sharedSession()
//		let dataTask = urlSession.dataTaskWithRequest(NSURLRequest(URL: requestURL!), completionHandler: { data, response, err -> Void in
//			let json = JSON(data: data!, options: NSJSONReadingOptions.AllowFragments, error: nil)
//			let stories = json["data"]["children"]
//			
//			let postsOpts = stories.map { (str, storyJson) -> Post? in
//				guard let title = storyJson["data"]["title"].string else {
//					print("Could not retrieve post title.")
//					return nil
//				}
//				guard let imgURLString = storyJson["data"]["thumbnail"].string else {
//					print("Could not retrieve post content.")
//					return nil
//				}
//				guard let imgData = NSData.init(contentsOfURL: NSURL(string: imgURLString)!) else {
//					print("Could not parse post content.")
//					return nil
//				}
//				guard let img = UIImage(data: imgData) else {
//					print("Could not parse content as image.")
//					return nil
//				}
//				
//				return Post(metadata: PostMetadata(title: title),
//										content: Content.Image(ImageContent(image: img)))
//			}
//			self.pushPosts(postsOpts)
//		})
//		dataTask.resume()
//	}
	
	func pushPosts(posts: [Post]) {
		_stack += posts
	}
	
	func pop() {
		_stack.removeFirst()
	}
}
