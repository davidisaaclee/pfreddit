//
//  ImgurCommunication.swift
//  pfreddit
//
//  Created by David Lee on 11/19/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation


// Let us make Range objects from NSRanges - c'mon Apple
extension String {
	func rangeFromNSRange(nsRange : NSRange) -> Range<String.Index>? {
		let from16 = utf16.startIndex.advancedBy(nsRange.location, limit: utf16.endIndex)
		let to16 = from16.advancedBy(nsRange.length, limit: utf16.endIndex)
		if let from = String.Index(from16, within: self),
			let to = String.Index(to16, within: self) {
				return from ..< to
		}
		return nil
	}
}

class ImgurCommunication {
	class func imgurIdFromURL (URLString: String) -> [String: String] {
		var result: [String: String] = [:]
		
		let contentExt = "(?:jpg|gif|webm)"
		let imageId = ".+"
		let albumId = "[^#]+"
		let galleryId = ".+"
		
		let directPattern = "imgur.com/(\(imageId))(?:\\.\(contentExt))?"
		let albumPattern = "imgur.com/a/(\(albumId))(?:#(\(imageId)))?"
		let galleryPattern = "imgur.com/gallery/(\(galleryId))"
		
		let patternList = [
			galleryPattern,
			albumPattern,
			directPattern
			].map { "(?:\($0))" }
		
		let combinedPattern = patternList.dropFirst().reduce(patternList.first!, combine: { "\($0)|\($1)" })
		var imgurRegexOpt: NSRegularExpression?
		do {
			imgurRegexOpt = try NSRegularExpression(pattern: combinedPattern, options: [])
		} catch {
			print("Invalid regex pattern")
		}
		
		if let imgurRegex = imgurRegexOpt {
			if let match = imgurRegex.firstMatchInString(URLString, options: [], range: NSMakeRange(0, URLString.characters.count)) {
				["full", "gallery", "album", "imageInAlbum", "image"].enumerate().forEach {
					let substring = URLString.substringWithRange(URLString.rangeFromNSRange(match.rangeAtIndex($0.0))!)
					if !substring.isEmpty {
						result[$0.1] = substring
					}
				}
			}
		}
		return result
	}
	
	class func getDirectLinks(id: String) -> Dictionary<String, String> {
		let url = NSURL(string: "https://api.imgur.com/3/image/\(id)")
		let session = NSURLSession.sharedSession()
		let config = NSURLSessionConfiguration.defaultSessionConfiguration()
		config.HTTPAdditionalHeaders = [ "Authentication": "Client-ID 7dff9b51653647a" ]
		let dataTask = session.dataTaskWithRequest(NSURLRequest(URL: url!), completionHandler: { data, response, err -> Void in
			print("completer")
			print(NSString(data: data!, encoding: NSUTF8StringEncoding))
		})
		dataTask.resume()
		
		
		return [:]
	}
}


//ImgurCommunication.getDirectLinks("ZjqZSsel")
ImgurCommunication.imgurIdFromURL("https://i.imgur.com/a/asdflkjsdf")