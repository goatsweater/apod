//
//  PhotoInfoController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-26.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa
import os.log

class PhotoInfoController {
    var photoInfo: PhotoInfo?
    let log = OSLog(subsystem: "com.goatsweater.apod", category: "PhotoInfoController")
    
    // image data is good for one day
    var imageDataExpired: Bool {
        // no photo info yet
        guard let lastPhoto = photoInfo?.date else {
            os_log("%@: no photo info yet", log: log, type: .debug, #function)
            return true
        }
        
        // unknown last download
        guard let lastDownload = UserDefaults.standard.value(forKey: "lastdownload") as? Date else {
            os_log("%@: unknown last download", log: log, type: .debug, #function)
            return true
        }
        
        // time interval is more than a day
        guard lastDownload.timeIntervalSince(lastPhoto) < TimeInterval(-86400.0) else {
            os_log("%@: time interval expired", log: log, type: .debug, #function)
            return true
        }
        
        // this appears to be a still relevant photo
        return false
    }
    
    // get the most recent photo information from NASA
    func fetchPhotoInfo(completion: @escaping (PhotoInfo?) -> Void) {
        os_log("%@", log: log, type: .debug, #function)
        // don't bother if the last fetch was today
        
        if imageDataExpired == true {
            let serviceURL = Bundle.main.object(forInfoDictionaryKey: "ServiceURL") as! String
            
            let baseURL = URL(string: serviceURL)
            let query: [String: String] = [
                "api_key": UserDefaults.standard.string(forKey: "apikey")!,
                ]
            
            let apodURL = baseURL?.withQueries(query)!
            os_log("Fetching image from %@", log: log, type: .debug, (apodURL?.absoluteString)!)
            let task = URLSession.shared.dataTask(with: (apodURL)!) { (data, response, error) in
                if let data = data,
                    let rawJSON = try?
                        JSONSerialization.jsonObject(with: data),
                    let json = rawJSON as? [String: String],
                    let photoInfo = PhotoInfo(json: json) {
                    completion(photoInfo)
                } else {
                    os_log("Error trying to serialize JSON response: %@", log: self.log, type: .error, error.debugDescription)
                    
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
    func downloadPhoto(to directory: URL) {
        os_log("%@ at %@", log: log, type: .debug, #function, directory.absoluteString)
        
        // where to save the image
        if let photoInfo = self.photoInfo {
            let useHDImage = UserDefaults.standard.bool(forKey: "downloadHDImage") 
            let imageUrl = useHDImage == true ? photoInfo.hdurl : photoInfo.url
            
            os_log("Fetch image from %@", log: log, type: .debug, imageUrl.absoluteString)
            let image = NSImage(contentsOf: imageUrl)
            let saveUrl = directory.appendingPathComponent(imageUrl.lastPathComponent)
            if let bits = image?.representations.first as? NSBitmapImageRep {
                let data = bits.representation(using: .JPEG, properties: [:])
                do {
                    os_log("Save image to %@", saveUrl.path)
                    try data?.write(to: saveUrl)
                    
                    // remove the previously downloaded image
                    removeLastDownload()
                    
                    // save the last download date to avoid duplicate downloads
                    let now = Date()
                    UserDefaults.standard.set(now, forKey: "lastdownload")
                    UserDefaults.standard.set(saveUrl, forKey: "lastImage")
                    
                    // update the desktop background
                    setBackgroundImage(to: saveUrl)
                } catch {
                    os_log("Error saving downloaded image: %@", log: log, type: .error, error.localizedDescription)
                }
            }
        }
    }
    
    // set the desktop background to the corresponding image
    func setBackgroundImage(to imageUrl: URL) {
        os_log("%@ to %@", log: log, type: .debug, #function, imageUrl.absoluteString)
        let workspace = NSWorkspace()
        if let screen = NSScreen.main() {
            try? workspace.setDesktopImageURL(imageUrl, for: screen, options: [:])
        }
    }
    
    // remove the previous downloaded file
    func removeLastDownload() {
        os_log("%@", log: log, type: .debug, #function)
        if let lastDownload = UserDefaults.standard.url(forKey: "lastImage") {
            do {
            try FileManager.default.removeItem(at: lastDownload)
            } catch {
                os_log("Error removing file at %@: %@", log: log, type: .error, lastDownload.absoluteString, error.localizedDescription)
            }
        }
    }
}
