//
//  PhotoInfoController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-26.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa

class PhotoInfoController {
    var photoInfo: PhotoInfo?
    
    var imageDataExpired: Bool {
        // no photo info yet
        guard let lastPhoto = photoInfo?.date else {
            return true
        }
        
        // unknown last download
        guard let lastDownload = UserDefaults.standard.value(forKey: "lastdownload") as? Date else {
            return true
        }
        
        if (lastDownload.timeIntervalSince(lastPhoto)) < TimeInterval(-86400.0) {
            return true
        } else {
            // more than a day has passed
            return false
        }
        
    }
    
    // get the most recent photo information from NASA
    func fetchPhotoInfo(completion: @escaping (PhotoInfo?) -> Void) {
        // don't bother if the last fetch was today
        
        if imageDataExpired == true {
            let serviceURL = Bundle.main.object(forInfoDictionaryKey: "ServiceURL") as! String
            
            let baseURL = URL(string: serviceURL)
            let query: [String: String] = [
                "api_key": UserDefaults.standard.value(forKey: "apikey") as! String,
                ]
            
            let apodURL = baseURL?.withQueries(query)!
            let task = URLSession.shared.dataTask(with: (apodURL)!) { (data, response, error) in
                if let data = data,
                    let rawJSON = try?
                        JSONSerialization.jsonObject(with: data),
                    let json = rawJSON as? [String: String],
                    let photoInfo = PhotoInfo(json: json) {
                    completion(photoInfo)
                } else {
                    print("Either no data was returned, or data was not serialized.")
                    print("Error: \(String(describing: error))")
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
    func downloadPhoto(to directory: URL) {
        // where to save the image
        if let photoInfo = self.photoInfo {
            let imageUrl = directory.appendingPathComponent(photoInfo.url.lastPathComponent)
            
            let image = NSImage(contentsOf: photoInfo.url)
            if let bits = image?.representations.first as? NSBitmapImageRep {
                let data = bits.representation(using: .JPEG, properties: [:])
                do {
                    try data?.write(to: imageUrl)
                    
                    // save the last download date to avoid duplicate downloads
                    let now = Date()
                    UserDefaults.standard.set(now, forKey: "lastdownload")
                    
                    // update the desktop background
                    setBackgroundImage(to: imageUrl)
                } catch {
                    print("Error saving latest image")
                }
            }
        }
    }
    
    // set the desktop background to the corresponding image
    func setBackgroundImage(to imageUrl: URL) {
        let workspace = NSWorkspace()
        if let screen = NSScreen.main() {
            try? workspace.setDesktopImageURL(imageUrl, for: screen, options: [:])
        }
    }
}
