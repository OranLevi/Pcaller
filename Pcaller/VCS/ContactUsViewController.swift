//
//  ContactUsViewController.swift
//  Pcaller
//
//  Created by Oran Levi on 27/12/2022.
//

import UIKit
import WebKit

enum WebViewUrls: String {
    case ratingApp = "https://forms.gle/HstTbo7Di7PKE2HP8"
    case contactUs = "https://forms.gle/DwytvWG9ZVPHeyQQ9"
}

class ContactUsViewController: UIViewController {

    @IBOutlet weak var contactUsWebView: WKWebView!
    
    static var urlWeb = URL(string: WebViewUrls.contactUs.rawValue)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUrl()
    }
    
    @IBAction func refreshButton(_sender: Any){
        contactUsWebView.reload()
    }

    @IBAction func doneButton(_ sender: Any) {
        dismiss(animated: true)
    }
    
    func loadUrl() {
        let url = URL(string: "\(ContactUsViewController.urlWeb)")!
        contactUsWebView.load(URLRequest(url: url))
        contactUsWebView.allowsBackForwardNavigationGestures = true
    }
}
