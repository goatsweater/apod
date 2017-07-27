//
//  PhotoInfoController.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-26.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Foundation

class PhotoInfoController {
    
    // get the most recent photo information from NASA
    func fetchPhotoInfo(completion: @escaping (PhotoInfo?) -> Void) {
        let baseURL = URL(string: "https://api.nasa.gov/planetary/apod")!
        let query: [String: String] = [
            "api_key": "DEMO_KEY",
            ]
        
        let apodURL = baseURL.withQueries(query)!
        let task = URLSession.shared.dataTask(with: apodURL) { (data, response, error) in
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
