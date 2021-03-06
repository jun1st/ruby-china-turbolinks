import UIKit
import WebKit

protocol EditReplyViewControllerDelegate: class {
    func editReplyViewDidFinished(controller: EditReplyViewController, toURL url: NSURL)
}

class EditReplyViewController: UIViewController {
    var webViewConfiguration: WKWebViewConfiguration?
    var doneButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    weak var delegate: EditReplyViewControllerDelegate?
    var path = ""
    
    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionDone))
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "\(ROOT_URL)\(path)?access_token=\(OAuth2.shared.accessToken)")!))
    }
    
    func actionDone() {
        webView.evaluateJavaScript("$('form[tb=\"edit-reply\"] .btn-primary').click()", completionHandler: nil)
    }
    
    func actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditReplyViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL.path != path {
                dismissViewControllerAnimated(true, completion: nil)
                delegate?.editReplyViewDidFinished(self, toURL: URL)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}
