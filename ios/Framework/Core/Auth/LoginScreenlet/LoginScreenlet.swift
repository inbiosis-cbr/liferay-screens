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


@objc public protocol LoginScreenletDelegate {

	optional func screenlet(screenlet: BaseScreenlet,
			onLoginResponseUserAttributes attributes: [String:AnyObject])

	optional func screenlet(screenlet: BaseScreenlet,
			onLoginError error: NSError)

	optional func onScreenletCredentialsSaved(screenlet: BaseScreenlet)
	optional func onScreenletCredentialsLoaded(screenlet: BaseScreenlet)

}


public class LoginScreenlet: BaseScreenlet, AuthBasedType {

	//MARK: Inspectables

	@IBInspectable public var authMethod: String? = AuthMethod.Email.rawValue {
		didSet {
			copyAuth(source: self, target: screenletView)
		}
	}

	@IBInspectable public var saveCredentials: Bool = false {
		didSet {
			(screenletView as? AuthBasedType)?.saveCredentials = self.saveCredentials
		}
	}

	@IBInspectable public var companyId: Int64 = 0


	@IBOutlet public weak var delegate: LoginScreenletDelegate?


	public var viewModel: LoginViewModel {
		return screenletView as! LoginViewModel
	}


	//MARK: BaseScreenlet

	override internal func onCreated() {
		super.onCreated()
		
		copyAuth(source: self, target: screenletView)

		if SessionContext.loadSessionFromStore() {
			viewModel.userName = SessionContext.currentUserName!
			viewModel.password = SessionContext.currentPassword!

			delegate?.onScreenletCredentialsLoaded?(self)
		}
	}

	override internal func createInteractor(#name: String?, sender: AnyObject?) -> Interactor? {

		switch name! {
		case "login-action":
			return createLoginInteractor()
		case "oauth-action":
			return createOAuthInteractor()
		default:
			return nil
		}
	}

	private func createLoginInteractor() -> LoginInteractor {
		let interactor = LoginInteractor(screenlet: self)

		interactor.onSuccess = {
			self.delegate?.screenlet?(self,
					onLoginResponseUserAttributes: interactor.resultUserAttributes!)

			if self.saveCredentials {
				if SessionContext.storeSession() {
					self.delegate?.onScreenletCredentialsSaved?(self)
				}
			}
		}

		interactor.onFailure = {
			self.delegate?.screenlet?(self, onLoginError: $0)
			return
		}

		return interactor
	}

	private func createOAuthInteractor() -> OAuthInteractor {
		let interactor = OAuthInteractor(
				screenlet: self,
				consumerKey: "14a728c9-a39e-4a03-aa88-0a2c149d7545",
				consumerSecret: "437cc660383e99a4b1ed8f5d4243a72a",
				callbackURL: "http://192.168.40.158:8080/")

		interactor.onSuccess = {
			self.delegate?.screenlet?(self,
					onLoginResponseUserAttributes: interactor.resultUserAttributes!)

/*TODO is it possible to store oauth tokens?
			if self.saveCredentials {
				if SessionContext.storeSession() {
					self.delegate?.onScreenletCredentialsSaved?(self)
				}
			}
*/
		}

		interactor.onFailure = {
			self.delegate?.screenlet?(self, onLoginError: $0)
			return
		}

		return interactor
	}


}
