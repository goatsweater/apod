//
//  PhotoInfo.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-23.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Foundation

struct PhotoInfo {
    var title: String
    var description: String
    var url: URL
    var copyright: String?
    var type: String
    var date: Date?
    var api_version: String?
    var hdurl: URL
    
    struct PropertyKey {
        static let title = "title"
        static let description = "explanation"
        static let url = "url"
        static let hdurl = "hdurl"
        static let date = "date"
        static let copyright = "copyright"
        static let type = "media_type"
        static let api_version = "service_version"
    }
    
    init?(json: [String: String]) {
        guard let title = json[PropertyKey.title],
            let description = json[PropertyKey.description],
            let type = json[PropertyKey.type],
            let dateString = json[PropertyKey.date],
            let hdUrlString = json[PropertyKey.hdurl],
            let hdurl = URL(string: hdUrlString),
            let urlString = json[PropertyKey.url],
            let url = URL(string: urlString) else { return nil }
        
        self.title = title
        self.description = description
        self.url = url
        self.type = type
        self.hdurl = hdurl
        self.copyright = json[PropertyKey.copyright]
        self.api_version = json[PropertyKey.api_version]
        
        // convert the date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        self.date = dateFormatter.date(from: dateString)
    }
}
