//
//  APIClient.swift
//  Dark Sky
//
//  Created by Micah Lanier on 2/20/17.
//  Copyright © 2017 Micah Lanier. All rights reserved.
//

import Foundation

public let NetworkingErrorDomain = ""
public let MissingHTTPResponseError: Int = 10
public let UnexpectedResponseError: Int = 20

typealias JSON = [String : AnyObject]
typealias JSONTaskCompletion = (JSON?, HTTPURLResponse?, NSError) -> Void
typealias JSONTask = URLSessionDataTask

enum APIResult<T> {
    case Success(T)
    case Failure(NSError)
}

protocol APIClient {
    var configuration: URLSessionConfiguration { get }
    var session: URLSession { get }
    
    init(withConfig: URLSessionConfiguration)

    func JSONTaskWithRequest(request: URLRequest, completion: JSONTaskCompletion) -> JSONTask
    func fetch<T>(request: URLRequest, parse: (JSON) -> T?, completion: (APIResult<T>) -> Void)
}

extension APIClient {
    func JSONTaskWithRequest(request: URLRequest, completion: @escaping JSONTaskCompletion) -> JSONTask {
        let task = session.dataTask(with: request) { data, response, error in
            guard let httpResponse = response as? HTTPURLResponse else {
                let userInfo = [
                    NSLocalizedDescriptionKey: NSLocalizedString("Missing HTTP Response", comment: "")
                ]

                let error = NSError(domain: NetworkingErrorDomain, code: MissingHTTPResponseError, userInfo: userInfo)
                completion(nil, nil, error)
                return
            }

            if data == nil {
                if let error = error {
                    completion(nil, httpResponse, error as NSError)
                }
            } else {
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let json = try JSONSerialization.jsonObject(with: data!, options: []) as? [String : AnyObject]
                        completion(json, httpResponse, error as! NSError)
                    } catch let error  as NSError {
                        completion(nil, httpResponse, error)
                    }
                default:
                    print("Received HTTP Response: \(httpResponse.statusCode) - not handled")
                }
            }
        }

        return task
    }


    func fetch<T>(request: URLRequest, parse: (JSON) -> T?, completion: (APIResult<T>) -> Void) {
        let task = JSONTaskWithRequest(request: request) { json, response, error in
            guard let json = json else {
                completion(.Failure(error))
                return
            }

            if let value = parse(json) {
                completion(.Success(value))
            } else {
                let error = NSError(domain: NetworkingErrorDomain, code: UnexpectedResponseError, userInfo: nil)
                completion(.Failure(error))
            }
        }

        task.resume()
    }



}


