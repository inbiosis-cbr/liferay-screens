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

#if LIFERAY_SCREENS_FRAMEWORK
	import LRMobileSDK
#endif


public struct PlaceholderMapping {
	var className: String?
	var classPK: Int64?
	var customContent: [String:String]?
	var priority: Int
	var segmentIds: [Int64]?

	init?(className: String?,
			classPK: Int64?,
			customContent: [String:String]?,
			priority: Int?,
			segments: [AnyObject]?) {

		if customContent != nil && (className == nil || classPK == nil) {
			return nil
		}
		if priority == nil {
			return nil
		}

		self.className = className
		self.classPK = classPK
		self.customContent = customContent
		self.priority = priority!

		segmentIds =
				(segments ?? [])
					.map    { $0 as? Int }
					.filter { $0 != nil }
					.map    { Int64($0!) }
	}
}


public class ATLoadPlaceholderOperation: ServerOperation {

	public var appId: String?
	public var groupId: Int64?
	public var placeholderIds: [String]?
	public var userContext: [String : String]?

	public var results: [String:[PlaceholderMapping]]?


	//MARK: ServerOperation

	override func validateData() -> Bool {
		var valid = super.validateData()

		valid = valid && (appId ?? "" != "")
		valid = valid && (groupId != nil)
		valid = valid && !(placeholderIds ?? []).isEmpty
		valid = valid && !(userContext ?? [:]).isEmpty

		return valid
	}

	override internal func doRun(#session: LRSession) {
		let service = LRScreensmobileService_v62(session: session)

		lastError = nil

		let result = service.getContentWithAppId(appId!,
				groupId: groupId!,
				placeholderIds: placeholderIds!,
				userContext: userContext!,
				serviceContext: nil,
				error: &lastError)

		if lastError == nil {
			results = [:]

			let resultList = result as! [[String:AnyObject]]
			for content in resultList {
				if let placeholderMap = PlaceholderMapping(
						className: content["className"] as? String,
						classPK: content["classPK"].map { $0 as! Int }.map { Int64($0) },
						customContent: content["customContent"] as? [String:String],
						priority: content["campaignId"] as? Int,
						segments: content["userSegmentIds"] as? [AnyObject]) {

					let placeholder = content["placeholderId"] as! String
					if results?[placeholder] == nil {
						results?[placeholder] = []
					}

					results?[placeholder]?.append(placeholderMap)
				}
				else {
					println("Wrong audience targeting mapping: \(content)")
				}
			}

			for (placeholder, items) in results! {
				if items.count > 1 {
					var sorted = items
					sorted.sort { $0.priority > $1.priority }
					results?[placeholder] = sorted
				}
			}
		}
	}

	public func firstResultForPlaceholderId(placeholderId: String) -> PlaceholderMapping? {
		return self.results?[placeholderId]?.first
	}

}
