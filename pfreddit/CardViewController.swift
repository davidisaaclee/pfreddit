//
//  CardViewController.swift
//  pfreddit
//
//  Created by David Lee on 11/17/15.
//  Copyright © 2015 David Lee. All rights reserved.
//

import UIKit

@IBDesignable class CardViewController: UIViewController {
	
	@IBOutlet var contentView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
	
	init () {
		super.init(nibName: "CardViewController", bundle: nil)
		NSBundle.mainBundle().loadNibNamed("CardViewController", owner: self, options: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func reloadPostData(p: Post) {
		titleLabel.text = p.metadata.title
		
		switch p.content {
		case .Image(let img):
			contentView.image = img.image
		case .Text(let txt):
			print("TODO: text post", txt)
		}
	}
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
