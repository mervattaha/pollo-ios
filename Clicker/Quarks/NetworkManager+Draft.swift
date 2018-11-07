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
        let encoding: ParameterEncoding = JSONEncoding.default
        let method: HTTPMethod = .post
        let parameters: Parameters
    }

    class func createDraft(text: String, options: [String], completion: @escaping ((Result<Draft>) -> Void)) {
        let parameters: Parameters = ["text": text, "options": options]
        let apiRequest = CreateDraftRequest(parameters: parameters)
        performRequest(for: apiRequest, completion: completion)
    }

    struct GetDraftsRequest: APIRequest {
        let route: String = "/drafts"
    }

    class func getDrafts(completion: @escaping ((Result<[Draft]>) -> Void)) {
        let apiRequest = GetDraftsRequest()
        performRequest(for: apiRequest, completion: completion)
    }

}
