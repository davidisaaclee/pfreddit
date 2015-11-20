//
//  ContentTypes.swift
//  pfreddit
//
//  Created by David Lee on 11/17/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import Foundation
import UIKit

// Root datatype for a single post.
struct Post {
	let metadata: PostMetadata
	let content: Content
}

// Enumeration of the different kinds of content that a post can hold.
enum Content {
	case Image(ImageContent)
	case Text(TextContent)
}

// Where things like post title, author, timestamp, etc. are stored
struct PostMetadata {
	let title: String
}


// MARK: - Content types

struct ImageContent {
	let image: UIImage
}

struct TextContent {
	let text: NSString
}