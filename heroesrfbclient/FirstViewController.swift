//
//  FirstViewController.swift
//  heroesrfbclient
//
//  Created by sbuglakov on 02/05/16.
//  Copyright © 2016 redetection. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
    
    var server: RFBFramebufferedConnection!
    @IBOutlet var screenView: RFBRectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let server = AppState.sharedInstance.server else {
            self.openConnectScreen()
            return
        }
        self.server = server
        self.screenView.framebuffer = server.framebuffer
        
        server.didUpdatedFrame = { [ weak server] in
            server?.requestScreenUpdate(true)
        }
        server.didUpdatedRect = { [weak self] (rect) in
            if let view = self?.screenView {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    view.setNeedsDisplayInOuterRect(rect)
                })
            }
        }
        server.didErrorOccurred = { [weak self] (error) in
            dispatch_async(dispatch_get_main_queue()) {
                print ("\(error)")
                let alert = UIAlertController(title: "\(error.code)", message: error.localizedDescription, preferredStyle: .Alert)
                alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: { _ in
                    self?.view.window?.rootViewController = UIStoryboard(name: "ConnectToServer", bundle: nil).instantiateInitialViewController()
                }))
                self?.presentViewController(alert, animated: true, completion: nil)
            }
        }
        server.requestScreenUpdate(true)
        
    }

    func openConnectScreen() {
        self.view.window?.rootViewController = UIStoryboard(name: "ConnectToServer", bundle: nil).instantiateInitialViewController()
    }

}
