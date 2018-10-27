//
//  NetworkManager+Session.swift
//  Clicker
//
//  Created by Kevin Chan on 10/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Alamofire
import SwiftyJSON

extension NetworkManager {

    struct GetPollSessionsRequest: APIRequest {
        let route: String
        let method: HTTPMethod = .get
    }

    class func getPollSessions(role: UserRole, completion: @escaping ((Result<[Session]>) -> Void)) {
        let route = "/sessions/all/\(role)"
        let apiRequest = GetPollSessionsRequest(route: route)
    }

}
