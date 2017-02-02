/**
* Copyright (c) 2000-present Liferay, Inc. All rights reserved.
*
* This library is free software; you can redistribute it and/or modify it under
* the terms of the GNU Lesser General Public License as published by the Free
* Software Foundation; either version 2.1 of the License, or (at your option)
* any later version.
*
* This library is distributed in the hope that it will be useful, but WITHOUT
* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
* FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public License for more
* details.
*/
import UIKit
import LiferayScreens


class BlogDisplayScreenletViewController: UIViewController, BlogsEntryDisplayScreenletDelegate {

	
	//MARK: IBOutlet
	
	@IBOutlet weak var screenlet: BlogsEntryDisplayScreenlet? {
		didSet {
			screenlet?.delegate = self
		}
	}
	@IBOutlet weak var blogClassPKLabel: UITextField? {
		didSet {
			blogClassPKLabel?.text = LiferayServerContext.stringPropertyForKey("blogDisplayClassPK")
		}
	}
	@IBOutlet weak var loadButton: UIButton? {
		didSet {
			loadButton?.replaceAttributedTitle(NSLocalizedString("load-button", comment: "LOAD"),
			                                   forState: .normal)
		}
	}

	
	//MARK: IBAction
	
	@IBAction func loadBlog(_ sender: AnyObject) {
		if let classPK = Int(blogClassPKLabel?.text ?? "") {
			screenlet?.classPK = Int64(classPK)
			screenlet?.load()
		}
	}

	
	//MARK: BlogsEntryDisplayScreenletDelegate
	
	func screenlet(_ screenlet: BlogsEntryDisplayScreenlet, onBlogEntryError error: NSError) {
		LiferayLogger.logDelegateMessage(args: error)
		screenlet.isHidden = true
	}
	
	func screenlet(_ screenlet: BlogsEntryDisplayScreenlet, onBlogEntryResponse blogEntry: BlogsEntry) {
		LiferayLogger.logDelegateMessage(args: blogEntry)
		screenlet.isHidden = false
	}
}
