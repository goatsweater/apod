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
    let log = OSLog(subsystem: "com.goatsweater.apod", category: "Controller")
    
    // image data is good for one day
    var imageDataExpired: Bool {
        // no photo info yet
        guard let lastPhoto = photoInfo?.date else {
            os_log("no photo info yet", log: log, type: .debug, "")
            return true
        }
        
        // unknown last download
        guard let lastDownload = UserDefaults.standard.value(forKey: "lastdownload") as? Date else {
            os_log("unknown last download", log: log, type: .debug, "")
            return true
        }
        
        // time interval is more than a day
        guard lastDownload.timeIntervalSince(lastPhoto) < TimeInterval(-86400.0) else {
            os_log("time interval expired", log: log, type: .debug, "")
            return true
        }
        
        // this appears to be a still relevant photo
        return false
    }
    
    // get the most recent photo information from NASA
    func fetchPhotoInfo(completion: @escaping (PhotoInfo?) -> Void) {
        os_log("fetchPhotoInfo", log: log, type: .debug, "")
        // don't bother if the last fetch was today
        
        if imageDataExpired == true {
            let serviceURL = Bundle.main.object(forInfoDictionaryKey: "ServiceURL") as! String
            
            let baseURL = URL(string: serviceURL)
            let query: [String: String] = [
                "api_key": UserDefaults.standard.string(forKey: "apikey")!,
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
                    os_log("Error trying to serialize JSON response: %s", log: self.log, type: .error, error.debugDescription)
                    
                    completion(nil)
                }
            }
            task.resume()
        }
    }
    
    func downloadPhoto(to directory: URL) {
        os_log("downloadPhoto at %s", log: log, type: .debug, directory.absoluteString)
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
                    
                    removeLastDownload()
                    UserDefaults.standard.set(imageUrl, forKey: "lastImage")
                    
                    // update the desktop background
                    setBackgroundImage(to: imageUrl)
                } catch {
                    os_log("Error saving downloaded image: %s", log: log, type: .error, imageUrl.absoluteString)
                }
            }
        }
    }
    
    // set the desktop background to the corresponding image
    func setBackgroundImage(to imageUrl: URL) {
        os_log("setBackgroundImage to %s", log: log, type: .debug, imageUrl.absoluteString)
        let workspace = NSWorkspace()
        if let screen = NSScreen.main() {
            try? workspace.setDesktopImageURL(imageUrl, for: screen, options: [:])
        }
    }
    
    // remove the previous downloaded file
    func removeLastDownload() {
        os_log("removeLastDownload", log: log, type: .debug, "")
        if let lastDownload = UserDefaults.standard.url(forKey: "lastImage") {
            do {
            try FileManager.default.removeItem(at: lastDownload)
            } catch {
                os_log("Error removing file at %s", log: log, type: .error, lastDownload.absoluteString)
            }
        }
    }
}
