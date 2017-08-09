//
//  PhotoInfoViewController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-26.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa

class PhotoInfoViewController: NSViewController {
    @IBOutlet weak var descriptionTextField: NSTextField!
    @IBOutlet weak var copyrightTextField: NSTextField!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var photoDateTextField: NSTextField!
    
    var photoInfoController = PhotoInfoController()
    
    class func loadFromNib() -> PhotoInfoViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "PhotoInfoViewController") as! PhotoInfoViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update photo information
        photoInfoController.fetchPhotoInfo { (photoInfo) in
            if let photoInfo = photoInfo {
                DispatchQueue.main.async {
                    self.photoInfoController.photoInfo = photoInfo
                    
                    self.updateUI()
                }
            }
        }
    }
    
    // Quit the app when the user asks
    @IBAction func quitButtonPushed(_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
    // Display the current file in the Finder
    @IBAction func showFileButtonPushed(_ sender: NSButton) {
        let filePath = UserDefaults.standard.string(forKey: "lastImage")
        if filePath != nil {
            let fileUrl = URL(fileURLWithPath: filePath!)
            NSWorkspace.shared().activateFileViewerSelecting([fileUrl])
        }
    }
    
    // load the latest photo information retrieved
    func updateUI() {
        if photoInfoController.photoInfo != nil {
            self.titleTextField.stringValue = (photoInfoController.photoInfo?.title)!
            self.descriptionTextField.stringValue = (photoInfoController.photoInfo?.description)!
            
            if let photoDate = photoInfoController.photoInfo?.date {
                let formatter = DateFormatter()
                formatter.dateStyle = .medium
                formatter.locale = Locale.current
                
                self.photoDateTextField.stringValue = "Taken: \(formatter.string(from: photoDate))"
            } else {
                self.photoDateTextField.isHidden = true
            }
            
            if let copyright = photoInfoController.photoInfo?.copyright {
                self.copyrightTextField.stringValue = "Copyright: \(copyright)"
            } else {
                self.copyrightTextField.isHidden = true
            }
        }
    }
}
