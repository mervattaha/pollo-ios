//
//  NetworkManager.swift
//  Clicker
//
//  Created by Matthew Coufal on 10/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum APIResponse<T> {
    case value(T)
    case error(Error)
}

enum PolloError: Error {
    case invalidResponse
}

struct APIData<T: Codable>: Codable {
    let node: Node<T>
    
    enum CodingKeys: String, CodingKey {
        case node = "data"
    }
}

struct Node<T: Codable>: Codable {
    let value: T
    
    enum CodingKeys: String, CodingKey {
        case value = "node"
    }
}

class NetworkManager {

    static let host: String = Keys.hostURL.value + "/api/v2"
    static let headers: HTTPHeaders = ["Authorization": "Bearer \(User.userSession?.accessToken ?? "")"]

    class func createDraft(text: String, options: [String], completionHandler: @escaping ((APIResponse<Draft>) -> Void)) {

        let route: String = "/drafts"
        let encoding: ParameterEncoding = JSONEncoding.default
        let parameters: Parameters = ["text": text, "options": options]
        let urlString = "\(host)\(route)"
        guard let url = URL(string: urlString) else { return }
        Alamofire.request(url, method: .post, parameters: parameters, encoding: encoding, headers: headers)
            .responseData { response in
                if let error = response.error {
                    completionHandler(.error(error))
                } else if let data = response.data {
                    let jsonDecoder = JSONDecoder()
                    do {
                        let apiData = try jsonDecoder.decode(APIData<Draft>.self, from: data)
                        let draft = apiData.node.value
                        completionHandler(.value(draft))
                    } catch {
                        completionHandler(.error(PolloError.invalidResponse))
                    }
                } else {
                    completionHandler(.error(PolloError.invalidResponse))
                }
        }


    }

}


