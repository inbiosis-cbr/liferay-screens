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

class LoginView_flat7: LoginView {

	@IBOutlet var titleLabel: UILabel?
	@IBOutlet var subtitleLabel: UILabel?
	@IBOutlet var usernamePlaceholder: UILabel?
	@IBOutlet var passwordPlaceholder: UILabel?

	override public func onSetTranslations() {
		let bundle = NSBundle(forClass: self.dynamicType)

		titleLabel!.text = NSLocalizedString("theme-flat7-login-title", tableName: "flat7", bundle: bundle, value: "", comment: "")
		subtitleLabel!.text = NSLocalizedString("theme-flat7-login-subtitle", tableName: "flat7", bundle: bundle, value: "", comment: "")
		usernamePlaceholder!.text = NSLocalizedString("theme-flat7-login-email", tableName: "flat7", bundle: bundle, value: "", comment: "")
		passwordPlaceholder!.text = NSLocalizedString("theme-flat7-login-password", tableName: "flat7", bundle: bundle, value: "", comment: "")

		let str = loginButton!.attributedTitleForState(UIControlState.Normal)
		let translated = NSLocalizedString("theme-flat7-login-login", tableName: "flat7", bundle: bundle, value: "", comment: "")
		let newStr = NSMutableAttributedString(attributedString: str)
		newStr.replaceCharactersInRange(NSMakeRange(0, str.length), withString:translated)
		loginButton!.setAttributedTitle(newStr, forState: UIControlState.Normal)

		userNameField!.placeholder = "";
		passwordField!.placeholder = "";
	}

	override func setUserName(userName: String) {
		super.setUserName(userName)
		showPlaceholder(usernamePlaceholder!, show:userName == "")
	}

	func textField(textField: UITextField!, shouldChangeCharactersInRange range: NSRange, replacementString string: String!) -> Bool {

		let newText = textField.text.bridgeToObjectiveC().stringByReplacingCharactersInRange(range, withString:string)

		let placeHolder = textField == userNameField ? usernamePlaceholder : passwordPlaceholder

		showPlaceholder(placeHolder!, show:newText == "")

		return true
	}

	private func showPlaceholder(placeholder:UILabel, show:Bool) {
		UIView.animateWithDuration(0.4, animations: {
			placeholder.alpha = show ? 1.0 : 0.0
		})
	}

}
