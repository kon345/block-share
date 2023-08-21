//
//  Communicator.swift
//  blockShare
//
//  Created by 林裕和 on 2023/8/15.
//

import Foundation

typealias DoneHandler<T> = (T) -> Void

class Communicator{
    static let shared = Communicator()
    private init(){}
    
    func doGet<T: Codable>(_ urlString: String, responseType: T.Type, completion: @escaping DoneHandler<T>) {
        // 構建您的 API 請求 URL
        guard let targetURL = URL(string: urlString) else {
            return
        }
        print("\(targetURL)")
        var request = URLRequest(url: targetURL)
        request.httpMethod = "GET"
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        let task = session.dataTask(with: request) { data, response, error in
            if let error  = error{
                print("Download fail: \(error)")
                return
            }
            guard let data = data,
                  let response = response as? HTTPURLResponse else{
                assertionFailure("Invalid data or response.")
                return
            }
//            let responseString = String(data: data, encoding: .utf8)
//            print(responseString)
            //練習方便，實際運用不需要
            if response.statusCode == 200 {
                do {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(T.self, from: data)
                    completion(result)
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }
        }
        task.resume()
        session.finishTasksAndInvalidate()
    }
    
    func doPost(_ urlString: String, parameters: [String: Any], completion: @escaping (Bool) -> Void) {
        guard let finalurl = URL(string: urlString) else {
            return
        }
        var request = URLRequest(url: finalurl)
        request.httpMethod = "POST"
        
        
        do {
                request.httpBody = try JSONSerialization.data(withJSONObject: parameters)
                
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    if let error = error {
                        print("Error uploading data: \(error)")
                        completion(false)
                        return
                    }
                    
                    if let data = data, let responseString = String(data: data, encoding: .utf8) {
                        print("Response data: \(responseString)")
                        if responseString.contains("successfully") {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    }
                }
                task.resume()
            } catch {
                print("Error encoding user data: \(error)")
                completion(false)
            }
        
    }
}
