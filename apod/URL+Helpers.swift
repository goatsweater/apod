//
//  URL+Helpers.swift
//  apod
//
//  Created by Reginald Maltais on 2017-07-23.
//  Copyright © 2017 Reginald Maltais. All rights reserved.
//

import Foundation
import os.log

extension URL {
    func withQueries(_ queries: [String: String]) -> URL? {
        var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
        if components == nil {
            os_log("Unable to resolve URL components", "")
        }
        components?.queryItems = queries.flatMap {
            URLQueryItem(name: $0.0, value: $0.1)
        }
        return components?.url
    }
}
