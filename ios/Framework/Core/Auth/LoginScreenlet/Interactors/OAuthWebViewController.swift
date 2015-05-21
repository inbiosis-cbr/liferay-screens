//
//  OAuthWebViewController.swift
//  LiferayScreens
//
//  Created by jmWork on 21/05/15.
//  Copyright (c) 2015 Liferay. All rights reserved.
//

import UIKit

class OAuthWebViewController: UIViewController, UIWebViewDelegate {

	@IBOutlet weak var webView: UIWebView!

	var onAuthorized: (String -> Void)?

	private let URL: NSURL

	init(URL: NSURL, themeName: String) {

		//TODO move this method to NSBundle+discovery
		func bundleForXib(nibName: String) -> NSBundle? {
			let bundles = allBundles(
					currentClass: OAuthWebViewController.self,
					currentTheme: "default");

			for bundle in bundles {
				if bundle.pathForResource(nibName, ofType:"nib") != nil {
					return bundle
				}
			}

			return nil
		}

		var nibName = "OAuthWebViewController_\(themeName)"
		var bundle = bundleForXib(nibName)
		if bundle == nil {
			nibName = "OAuthWebViewController_default"
			bundle = bundleForXib(nibName)
		}

		self.URL = URL

		super.init(
				nibName: nibName,
				bundle: bundle)
	}

	required init(coder aDecoder: NSCoder) {
		URL = NSURL()

		super.init(coder: aDecoder)
	}

	override func viewWillAppear(animated: Bool) {
		webView.delegate = self
		webView.loadRequest(NSURLRequest(URL: URL))
	}

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

	@IBAction func closeAction(sender: AnyObject) {
		self.dismissViewControllerAnimated(true, completion: nil)
	}

	func webView(webView: UIWebView,
			shouldStartLoadWithRequest request: NSURLRequest,
			navigationType: UIWebViewNavigationType) -> Bool {

		let URL = request.URL?.absoluteString

		if URL?.rangeOfString("oauth_verifier=") != nil {
			let params = LROAuth.extractRequestParams(URL!) as [NSObject:AnyObject]
			onAuthorized?(params["oauth_verifier"] as! String)
			return false
		}

		return true
	}


}
