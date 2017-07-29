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
    
    let photoInfoController = PhotoInfoController()
    
    class func loadFromNib() -> PhotoInfoViewController {
        let storyboard = NSStoryboard(name: "Main", bundle: nil)
        return storyboard.instantiateController(withIdentifier: "PhotoInfoViewController") as! PhotoInfoViewController
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the label values
        photoInfoController.fetchPhotoInfo { (photoInfo) in
            if let photoInfo = photoInfo {
                DispatchQueue.main.async {
                    self.titleTextField.stringValue = photoInfo.title
                    self.descriptionTextField.stringValue = photoInfo.description
                    
                    if let photoDate = photoInfo.date {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        formatter.locale = Locale.current
                        
                        self.photoDateTextField.stringValue = "Taken: \(formatter.string(from: photoDate))"
                    } else {
                        self.photoDateTextField.isHidden = true
                    }
                    
                    if let copyright = photoInfo.copyright {
                        self.copyrightTextField.stringValue = "Copyright: \(copyright)"
                    } else {
                        self.copyrightTextField.isHidden = true
                    }
                }
            }
        }
    }
    
    // Quit the app when the user asks
    @IBAction func quitButtonPushed(_ sender: NSButton) {
        NSApplication.shared().terminate(sender)
    }
    
    // Download the image to the user's Pictures folder
    func downloadPhoto(with photoInfo: PhotoInfo) {
        // where to save the image
        let picturesDirectory = FileManager.default.urls(for: .picturesDirectory, in: .userDomainMask)[0]
        let apodDirectory = picturesDirectory.appendingPathComponent("apod", isDirectory: true)
        let imageUrl = apodDirectory.appendingPathComponent(photoInfo.url.lastPathComponent)
        
        let image = NSImage(contentsOf: photoInfo.url)
        if let bits = image?.representations.first as? NSBitmapImageRep {
            let data = bits.representation(using: .JPEG, properties: [:])
            try? data?.write(to: imageUrl)
        }
    }
    
}
