//
//  Communicator.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation
import Alamofire

typealias DoneHandler<T: Decodable> = (_ result: serverResult<T>?, _ error: Error?) -> Void
typealias DownloadHandler = (_ data: Data?, _ error: Error?) -> Void

struct responseResult: Decodable{
    var success: Bool
    var errorCode: String?
    enum CodingKeys: String, CodingKey{
        case success = "result"
        case errorCode
    }
}

struct serverResult<T: Decodable>: Decodable{
    var response: responseResult
    var content: T?
}

class Communicator{
    static let shared = Communicator()
    private init(){}
    
    let dataKey = "data"
    
    func downloadImage(urlString: String, completion: @escaping DownloadHandler){
        AF.request(urlString).response { response in
            switch response.result {
            case .success(let result):
                print("Success with: \(result!)")
                completion(result,nil)
            case .failure(let error):
                print("Fail with: \(error)")
                completion(nil, error)
            }
        }
    }
    
    func doGet<T>(_ urlString: String, parameters: [String:Any], completion:  @escaping DoneHandler<T>){
        AF.request(urlString,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default).responseDecodable {
            (response: DataResponse<serverResult<T>, AFError>) in
            if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
                print("Received Data: \(dataString)")
            }
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    func doPost<T>(_ urlString: String, parameters: [String:Any], completion: DoneHandler<T>?){
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters),
              let jsonString = String(data: jsonData, encoding: .utf8)
        else{
            assertionFailure("Encode JSON Failed!")
            return
        }
        print("jsonString: \(jsonString)")
        let finalParameters = [dataKey: jsonString]
        
        AF.request(urlString,
                   method: .post,
                   parameters: finalParameters,
                   encoding: URLEncoding.default).responseDecodable {
            (response: DataResponse<serverResult<T>, AFError>) in
            if let data = response.data, let dataString = String(data: data, encoding: .utf8) {
                print("Received Data: \(dataString)")
            }
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    private func handleResponse<T>(response: DataResponse<serverResult<T>, AFError>, completion: DoneHandler<T>?){
        switch response.result {
        case .success(let result):
            print("Success with: \(result)")
            completion?(result,nil)
        case .failure(let error):
            print("Fail with: \(error)")
            completion?(nil, error)
        }
    }
}
