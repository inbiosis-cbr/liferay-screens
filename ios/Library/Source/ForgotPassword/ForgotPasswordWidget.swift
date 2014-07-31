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

@objc protocol ForgotPasswordWidgetDelegate {

	optional func onForgotPasswordResponse(newPasswordSent:Bool)
	optional func onForgotPasswordError(error: NSError)

}

@IBDesignable class ForgotPasswordWidget: BaseWidget {

	@IBInspectable var anonymousApiUserName: String?
	@IBInspectable var anonymousApiPassword: String?

	@IBOutlet var delegate: ForgotPasswordWidgetDelegate?


	private typealias ResetClosureType = (String, LRMwuserService_v6201, (NSError)->()) -> (Void)

	//TODO support resetClosure by userId
	private let resetClosures = [
		AuthType.Email.toRaw(): resetPasswordWithEmail,
		AuthType.ScreenName.toRaw(): resetPasswordWithScreenName]

	private var resetClosure: ResetClosureType?

	
	public func setAuthType(authType:AuthType) {
		forgotPasswordView().setAuthType(authType.toRaw())

		resetClosure = resetClosures[authType.toRaw()]
	}


    // BaseWidget METHODS


	override func onCreate() {
		setAuthType(AuthType.Email)

		forgotPasswordView().usernameField!.text = LiferayContext.instance.currentSession?.username
	}

	override func onCustomAction(actionName: String?, sender: UIControl) {
		sendForgotPasswordRequest(forgotPasswordView().usernameField!.text)
	}

	override func onServerError(error: NSError) {
		delegate?.onForgotPasswordError?(error)

		hideHUDWithMessage("Error requesting password!", details: error.localizedDescription)
	}

	override func onServerResult(result: [String:AnyObject]) {
		if let resultValue:AnyObject = result["result"] {
			let newPasswordSent = resultValue as Bool

			delegate?.onForgotPasswordResponse?(newPasswordSent)

			let userMessage = newPasswordSent ? "New password generated" : "New password reset link sent"

			hideHUDWithMessage(userMessage, details: "Check your email inbox")
		}
		else {
			var errorMsg:String? = result["error"]?.description

			if !errorMsg {
				errorMsg = result["exception.localizedMessage"]?.description
			}

			hideHUDWithMessage("An error happened", details: errorMsg)
		}
    }


	private func forgotPasswordView() -> ForgotPasswordView {
		return widgetView as ForgotPasswordView
	}

	private func sendForgotPasswordRequest(username:String) {
		if !anonymousApiUserName || !anonymousApiPassword {
			println(
				"ERROR: The credentials to use for anonymous API calls must be set in order to use " +
					"ForgotPasswordWidget")

			return
		}

		showHUDWithMessage("Sending password request...", details:"Wait few seconds...")

		let session = LiferayContext.instance.createSession(anonymousApiUserName!, password: anonymousApiPassword!)

		session.callback = self

		let companyId: CLongLong = (LiferayContext.instance.companyId as NSNumber).longLongValue

		resetClosure!(username, LRMwuserService_v6201(session: session)) {error in
			self.onFailure(error)
		}
	}
}

func resetPasswordWithEmail(email:String, service:LRMwuserService_v6201, onError:(NSError)->()) {
	let companyId = (LiferayContext.instance.companyId as NSNumber).longLongValue

	var outError: NSError?

	service.sendPasswordByEmailAddressWithCompanyId(companyId, emailAddress: email, serviceContext:nil, error: &outError)

	if let error = outError {
		onError(error)
	}
}

func resetPasswordWithScreenName(screenName:String, service:LRMwuserService_v6201, onError:(NSError)->()) {
	let companyId = (LiferayContext.instance.companyId as NSNumber).longLongValue

	var outError: NSError?

	service.sendPasswordByScreenNameWithCompanyId(companyId, screenName: screenName, serviceContext:nil, error: &outError)

	if let error = outError {
		onError(error)
	}
}