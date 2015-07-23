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


@objc public class ATLoader : NSObject {

	private var groupId: Int64
	private var appId: String

	private var contentCache: [String: String] = [:]

	private var lastUserSegmentIds = [Int64]()

	public init(groupId: Int64, appId: String) {
		self.groupId = groupId
		self.appId = appId

		super.init()
	}

	public class func computeUserContext() -> [String:String] {
		var result = [String:String]()

		if SessionContext.hasSession {
			result["userId"] = (SessionContext.userAttribute("userId") as! Int).description
		}

		// device
		result["os-name"] = "ios"
		result["os-version"] = NSProcessInfo.processInfo().operatingSystemVersionString

		result["locale"] = NSLocale.currentLocaleString

		// more...

		return result
	}

	public func clearCache() {
		contentCache.removeAll(keepCapacity: true)
	}

	public func clearCache(#key: String) {
		contentCache.removeValueForKey(key)
	}

	public func hasContentCached(#placeholderId: String) -> Bool {
		return contentCache[placeholderId] != nil
	}

	public func belongsToSegment(segmentId: Int64) -> Bool {
		return contains(lastUserSegmentIds, segmentId)
	}

	public func content(#placeholderId: String,
			result: (String?, NSError?) -> Void) {

		content(placeholderId: placeholderId, context: [:], result: result)
	}

	public func content(#placeholderId: String,
			context: [String:String],
			result: (String?, NSError?) -> Void) {

		if let cachedValue = contentCache[placeholderId] {
			result(cachedValue, nil)
		}
		else {
			loadContent(placeholderId: placeholderId, context: context, result: result)
		}
	}

	public func loadContent(
			#placeholderId: String,
			result: (String?, NSError?) -> Void) {
		loadContent(placeholderId: placeholderId, context: [:], result: result)
	}

	public func loadContent(
			#placeholderId: String,
			context: [String:String],
			result: (String?, NSError?) -> Void) {

		let operation = ATLoadPlaceholderOperation()

		operation.groupId = (groupId != 0) ? groupId : LiferayServerContext.groupId

		operation.appId = appId
		operation.placeholderIds = [placeholderId]

		operation.userContext = ((ATLoader.computeUserContext() + context) as! [String:String])

		// TODO retain-cycle on operation?
		operation.onComplete = {
			if let error = $0.lastError {
				result(nil, error)
			}
			else {
				let loadOp = $0 as! ATLoadPlaceholderOperation

				let placeholderId = loadOp.placeholderIds!.first!
				let resultMap = loadOp.firstResultForPlaceholderId(placeholderId)
				self.lastUserSegmentIds = resultMap?.segmentIds ?? self.lastUserSegmentIds

				if let customContent = resultMap?.customContent {
					var localizedContent = customContent[NSLocale.currentLanguageString] ?? customContent["en_US"]
					self.contentCache[placeholderId] = localizedContent
					result(localizedContent, nil)
				}
				else {
					// no error, no content
					result(nil, nil)
				}
			}
		}

		if !operation.validateAndEnqueue() {
			result(nil, NSError.errorWithCause(.AbortedDueToPreconditions))
		}
	}

}
