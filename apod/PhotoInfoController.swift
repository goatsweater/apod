//
//  PhotoInfoController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-26.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Cocoa

class PhotoInfoController {
    
    // get the most recent photo information from NASA
    func fetchPhotoInfo(completion: @escaping (PhotoInfo?) -> Void) {
        let defaults = UserDefaults.standard
        let serviceURL = Bundle.main.object(forInfoDictionaryKey: "ServiceURL") as! String
        
        let baseURL = URL(string: serviceURL)
        let query: [String: String] = [
            "api_key": defaults.value(forKey: "apikey") as! String,
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
    
    func downloadPhoto(with photoInfo: PhotoInfo, to directory: URL) {
        // where to save the image
        let imageUrl = directory.appendingPathComponent(photoInfo.url.lastPathComponent)
        
        let image = NSImage(contentsOf: photoInfo.url)
        if let bits = image?.representations.first as? NSBitmapImageRep {
            let data = bits.representation(using: .JPEG, properties: [:])
            try? data?.write(to: imageUrl)
        }
    }
}
