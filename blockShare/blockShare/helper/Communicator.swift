//
//  Communicator.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation
import Alamofire

//typealias DoneHandler<T> = (T) -> Void
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
    
//    func doGet<T: Codable>(_ urlString: String, responseType: T.Type, completion: @escaping DoneHandler<T>) {
//        // 構建您的 API 請求 URL
//        guard let targetURL = URL(string: urlString) else {
//            return
//        }
//        print("\(targetURL)")
//        var request = URLRequest(url: targetURL)
//        request.httpMethod = "GET"
//        let config = URLSessionConfiguration.default
//        let session = URLSession(configuration: config)
//
//        let task = session.dataTask(with: request) { data, response, error in
//            if let error  = error{
//                print("Download fail: \(error)")
//                return
//            }
//            guard let data = data,
//                  let response = response as? HTTPURLResponse else{
//                assertionFailure("Invalid data or response.")
//                return
//            }
////            let responseString = String(data: data, encoding: .utf8)
////            print(responseString)
//            //練習方便，實際運用不需要
//            if response.statusCode == 200 {
//                do {
//                    let decoder = JSONDecoder()
//                    let result = try decoder.decode(T.self, from: data)
//                    completion(result)
//                } catch {
//                    print("Error decoding JSON: \(error.localizedDescription)")
//                }
//            }
//        }
//        task.resume()
//        session.finishTasksAndInvalidate()
//    }
    
//    func doPost(_ urlString: String, parameters: [String: Any], completion: @escaping (Bool) -> Void) {
//        guard let finalurl = URL(string: urlString) else {
//            return
//        }
//        var request = URLRequest(url: finalurl)
//        request.httpMethod = "POST"
//
//
//        do {
//                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
//
//                let task = URLSession.shared.dataTask(with: request) { data, response, error in
//                    if let error = error {
//                        print("Error uploading data: \(error)")
//                        completion(false)
//                        return
//                    }
//
//                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
//                        print("Response data: \(responseString)")
//                        if responseString.contains("successfully") {
//                            completion(true)
//                        } else {
//                            completion(false)
//                        }
//                    }
//                }
//                task.resume()
//            } catch {
//                print("Error encoding user data: \(error)")
//                completion(false)
//            }
//
//    }
    func doGet<T>(_ urlString: String, parameters: [String:Any], completion:  @escaping DoneHandler<T>){
        AF.request(urlString,
                   method: .get,
                   parameters: parameters,
                   encoding: URLEncoding.default).responseDecodable {
            (response: DataResponse<serverResult<T>, AFError>) in
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
            self.handleResponse(response: response, completion: completion)
        }
    }
    
    private func handleResponse<T>(response: DataResponse<serverResult<T>, AFError>, completion: DoneHandler<T>?){
        print(response);
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
