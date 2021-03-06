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
    @IBOutlet weak var downloadHDCheckbox: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // is the HD image option selected?
        if UserDefaults.standard.bool(forKey: "downloadHDImage") == true {
            downloadHDCheckbox.setNextState()
        }
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
                    UserDefaults.standard.set(openPanel.urls.first, forKey: "savepath")
                    if openPanel.urls.first?.absoluteString != nil {
                        self.downloadPathTextField.stringValue = (openPanel.urls.first?.absoluteString)!
                    }
                }
            } else if result == NSFileHandlingPanelCancelButton {
                let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0]
                UserDefaults.standard.set(picturesDirectory, forKey: "savepath")
            }
        })
    }
    
    @IBAction func downloadHDImageCheckboxPressed(_ sender: NSButton) {
        switch sender.state {
        case NSOnState:
            UserDefaults.standard.set(true, forKey: "downloadHDImage")
        default:
            UserDefaults.standard.set(false, forKey: "downloadHDImage")
        }
    }
}
