//
//  AppDelegate.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-23.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    // create a status item
    let statusItem = NSStatusBar.system().statusItem(withLength: NSSquareStatusItemLength)
    let popover = NSPopover()
    var eventMonitor: EventMonitor?
    var downloadTimer: Timer?
    var lastDownload = Date()

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set the status bar icon
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "SpaceIcon")
            statusButton.action = #selector(togglePhotoInfo(_:))
        }
        
        // assign the popover
        popover.contentViewController = PhotoInfoViewController.loadFromNib()
        
        // register defaults in UserDefaults
        registerInitialDefaults()
        
        // monitor for mouse clicks outside the popover to close it
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        // begin downloads photos
        getDailyPhoto()
        // and keep downloading every day
        downloadTimer = startTimer()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        downloadTimer?.invalidate()
    }
    
    func showPopover(sender: Any?) {
        if let button = statusItem.button {
            popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            eventMonitor?.start()
        }
    }
    
    func closePopover(sender: Any?) {
        popover.performClose(sender)
        eventMonitor?.stop()
    }
    
    func togglePhotoInfo(_ sender: NSStatusBarButton) {
        if popover.isShown {
            self.closePopover(sender: sender)
        } else {
            self.showPopover(sender: sender)
        }
    }
    
    func registerInitialDefaults() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let initialValues: [String: Any] = [
            "apikey": "DEMO_KEY",
            "savepath": "",
            "keepImages": 3,
            "lastdownload": dateFormatter.date(from: "2017-01-01") ?? Date()
        ]
        UserDefaults.standard.register(defaults: initialValues)
    }

    func startTimer() -> Timer {
        let secondsPerDay = 86400
        let timer = Timer.scheduledTimer(timeInterval: TimeInterval(secondsPerDay), target: self, selector: #selector(self.getDailyPhoto), userInfo: nil, repeats: true)
        return timer
    }
    
    @objc func getDailyPhoto() {
        // get the latest photo information
        let pic = PhotoInfoController()
        pic.fetchPhotoInfo { (photoInfo) in
            if let photoInfo = photoInfo {
                DispatchQueue.main.async {
                    pic.photoInfo = photoInfo
                }
                
                // download the appropriate photo
                let downloadDirectory = UserDefaults.standard.value(forKey: "savepath")
                let path = URL(fileURLWithPath: downloadDirectory as! String)
                
                pic.downloadPhoto(to: path)
            }
        }
    }
}

