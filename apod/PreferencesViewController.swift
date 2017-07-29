//
//  PreferencesViewController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-27.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa

class PreferencesViewController: NSViewController {
    @IBOutlet weak var downloadPathTextField: NSTextField!
    @IBOutlet weak var historicalImagesTextField: NSTextField!
    @IBOutlet weak var apiKeyTextField: NSTextField!
    
    let defaults = UserDefaults.standard

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do view setup here.
    }
    
    @IBAction func selectPathButtonPushed(_ sender: NSButton) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        
        openPanel.begin(completionHandler:  { (result) -> Void in
            if result == NSFileHandlingPanelOKButton {
                if openPanel.urls.first != nil {
                    // set the user defaults to have this path
                    self.defaults.set(openPanel.urls.first, forKey: "savepath")
                    if openPanel.urls.first?.absoluteString != nil {
                        self.downloadPathTextField.stringValue = (openPanel.urls.first?.absoluteString)!
                    }
                }
            } else if result == NSFileHandlingPanelCancelButton {
                let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0]
                self.defaults.set(picturesDirectory, forKey: "savepath")
            }
        })
    }
    
    @IBAction func apiKeyTextField(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "apikey")
    }
    @IBAction func historicalImageTextField(_ sender: NSTextField) {
        defaults.set(sender.stringValue, forKey: "keepImages")
    }
}
