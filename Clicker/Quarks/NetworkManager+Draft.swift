//
//  NetworkManager.swift
//  Clicker
//
//  Created by Kevin Chan on 10/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension NetworkManager {

    struct CreateDraftRequest: APIRequest {
        let route: String = "/drafts"
        let parameters: Parameters
        let method: HTTPMethod = .post
    }

    class func createDraft(text: String, options: [String], completion: @escaping ((Result<Draft>) -> Void)) {
        let parameters: Parameters = ["text": text, "options": options]
        let apiRequest = CreateDraftRequest(parameters: parameters)
        performRequest(for: apiRequest, completion: completion)
    }

}
