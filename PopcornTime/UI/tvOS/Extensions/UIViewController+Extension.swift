

import Foundation
import TVMLKitchen


extension UIViewController {
    
    func pctViewDidDisappear(_ animated: Bool) {
        Kitchen.appController.evaluate(inJavaScriptContext: { (context) in
            if let function = context.objectForKeyedSubscript("viewDidDisappear"), !function.isUndefined {
                function.call(withArguments: [])
            }
        })
        self.pctViewDidDisappear(animated)
    }
    
    func pctViewDidAppear(_ animated: Bool) {
        Kitchen.appController.evaluate(inJavaScriptContext: { (context) in
            if let function = context.objectForKeyedSubscript("viewDidAppear"), !function.isUndefined {
                function.call(withArguments: [])
            }
            })
        self.pctViewDidAppear(animated)
    }
    
    func pctFocusedViewDidChange() {
        NotificationCenter.default.post(name: .UIViewControllerFocusedViewDidChange, object: self)
        self.pctFocusedViewDidChange()
    }
    
    open override class func initialize() {
        
        
        if self !== UIViewController.self {
            return
        }
        
        DispatchQueue.once {
            exchangeImplementations(originalSelector: #selector(viewDidDisappear(_:)), swizzledSelector: #selector(pctViewDidDisappear(_:)))
            exchangeImplementations(originalSelector: #selector(viewDidAppear(_:)), swizzledSelector: #selector(pctViewDidAppear(_:)))
            exchangeImplementations(originalSelector: Selector(("focusedViewDidChange")), swizzledSelector: #selector(pctFocusedViewDidChange))
        }
    }
    
    class func exchangeImplementations(originalSelector: Selector, swizzledSelector: Selector) {
        let originalMethod = class_getInstanceMethod(self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }
    
    @nonobjc var templateViewController: UIViewController? {
        guard responds(to: Selector(("templateViewController"))) else { return nil }
        return value(forKey: "templateViewController") as? UIViewController
    }
    
    @nonobjc var isLoadingViewController: Bool {
        guard let templateViewController = templateViewController else { return false }
        return type(of: templateViewController) == NSClassFromString("_TVLoadingViewController")
    }
}
