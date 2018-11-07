//
//  NetworkManager.swift
//  Clicker
//
//  Created by Matthew Coufal on 10/27/18.
//  Copyright © 2018 CornellAppDev. All rights reserved.
//

import Alamofire
import SwiftyJSON

enum Result<T> {
    case value(T)
    case error(Error)
}

enum IntermediaryResult<T: Codable> {
    case value(APIData<T>)
    case error(Error)
}

enum PolloError: Error {
    case invalidResponse
}

enum PolloAPIVersion {
    case version(Int)
    case none
}

struct APIResponse<T: Codable>: Codable {
    let data: APIData<T>
    let success: Bool
}

struct APIData<T: Codable>: Codable {
    let node: T?
    let nodes: [Node<T>]?
    let edges: [PolloEdge<T>]?
}

struct PolloEdge<T: Codable>: Codable {
    let cursor: String
    let node: Node<T>
}

struct Node<T: Codable>: Codable {
    let value: T
    
    enum CodingKeys: String, CodingKey {
        case value = "node"
    }
}

protocol APIRequest {
    var route: String { get }
    var parameters: Parameters { get }
    var method: HTTPMethod { get }
    var encoding: ParameterEncoding { get }
}

extension APIRequest {
    var parameters: Parameters {
        return [:]
    }

    var method: HTTPMethod {
        return .get
    }

    var encoding: ParameterEncoding {
        return JSONEncoding.default
    }
}

class NetworkManager {

    static let host: String = Keys.hostURL.value + "/api"
    static let apiVersion: PolloAPIVersion = .version(2)
    static let headers: HTTPHeaders = ["Authorization": "Bearer \(User.userSession?.accessToken ?? "")"]

    class func getBaseURL() -> String {
        switch apiVersion {
        case .version(let version):
            return "\(host)/v\(version)"
        case .none:
            return host
        }
    }

    class func performRequest<T: Codable>(for apiRequest: APIRequest, completion: ((Result<T>) -> Void)?) {
        alamofireRequest(for: apiRequest) { (intermediaryResult: IntermediaryResult<T>) in
            switch intermediaryResult {
            case .value(let apiData):
                handleAPIData(apiData, completion: completion)
            case .error(let error):
                completion?(.error(error))
            }
        }
    }

    class func performRequest<T: Codable>(for apiRequest: APIRequest, completion: ((Result<[T]>) -> Void)?) {
        alamofireRequest(for: apiRequest) { (intermediaryResult: IntermediaryResult<T>) in
            switch intermediaryResult {
            case .value(let data):
                handleAPIData(data, completion: completion)
            case .error(let error):
                completion?(.error(error))
            }
        }
    }

    private class func handleAPIData<T: Codable>(_ apiData: APIData<T>, completion: ((Result<T>) -> Void)?) {
        if let node = apiData.node {
            completion?(.value(node))
        }
    }

    private class func handleAPIData<T: Codable>(_ apiData: APIData<T>, completion: ((Result<[T]>) -> Void)?) {
        if let edges = apiData.edges {
            let nodes = edges.map { $0.node.value }
            completion?(.value(nodes))
        }
    }

    private class func alamofireRequest<T: Codable>(for apiRequest: APIRequest, completion: ((IntermediaryResult<T>) -> Void)?) {
        let urlString = "\(getBaseURL())\(apiRequest.route)"
        guard let url = URL(string: urlString) else { return }
        Alamofire.request(url, method: apiRequest.method, parameters: apiRequest.parameters, encoding: apiRequest.encoding, headers: headers).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let decoder = JSONDecoder()
                    let apiResponse = try decoder.decode(APIResponse<T>.self, from: data)
                    let responseData = apiResponse.data
                    completion?(.value(responseData))
                } catch {
                    completion?(.error(PolloError.invalidResponse))
                }
            case .failure(let error):
                completion?(.error(error))
            }
        }
    }

}


