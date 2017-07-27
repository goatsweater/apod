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

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // set the status bar icon
        if let statusButton = statusItem.button {
            statusButton.image = NSImage(named: "SpaceIcon")
            statusButton.action = #selector(togglePhotoInfo(_:))
        }
        
        // assign the popover
        popover.contentViewController = PhotoInfoViewController.loadFromNib()
        
        // monitor for mouse clicks outside the popover to close it
        eventMonitor = EventMonitor(mask: [.leftMouseDown, .rightMouseDown]) { [unowned self] event in
            if self.popover.isShown {
                self.closePopover(sender: event)
            }
        }
        
        // create a menu for the status item
        //createStatusMenu()
        
        // Hide the preferences window
        //togglePreferencesWindow(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
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
    
    func togglePreferencesWindow(_ sender: Any?) {
        
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        let preferencesWindowController = storyboard.instantiateController(withIdentifier: "PhotoInfo") as! NSWindowController
        //let preferencesWindowController = storyboard.instantiateInitialController() as! NSWindowController
        
        if (preferencesWindowController.window?.isVisible)! {
            preferencesWindowController.close()
            NSApplication.shared().setActivationPolicy(.accessory)
        } else {
            NSApplication.shared().setActivationPolicy(.regular)
            NSApp.activate(ignoringOtherApps: true)
            preferencesWindowController.showWindow(sender)
        }
    }
    
    func createStatusMenu() {
        
        // create the menu for when the item is clicked
        let statusMenu = NSMenu()
        
        statusMenu.addItem(withTitle: "Photo Info", action: #selector(togglePreferencesWindow(_:)), keyEquivalent: "i")
        
        statusMenu.addItem(NSMenuItem.separator())
        
        statusMenu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        statusItem.menu = statusMenu
    }

}

