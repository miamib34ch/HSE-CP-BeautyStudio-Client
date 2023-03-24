//
//  SettingsService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import Foundation

final class SettingsService {
    private var task: URLSessionTask?
    
    private var createDelete: URLRequest {
        let token = AuthStorage().token ?? ""
        let url = URL(string: serverURL + "/delete")!

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(token)
        return request
    }
    
    func sendDeleteRequest(completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createDelete
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    func sendUpdateRequest(phone: String?, pass: String?, completion: @escaping(Result<String, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createUpdateRequest(phone: phone, pass: pass)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func createUpdateRequest(phone: String?, pass: String?) -> URLRequest {
        let token = AuthStorage().token ?? ""
        var urlComponents = URLComponents(string: serverURL + "/update")!
        urlComponents.queryItems = []
        if let pass = pass {
            urlComponents.queryItems?.append(URLQueryItem(name: "pass", value: pass))
        }
        
        if let phone = phone {
            urlComponents.queryItems?.append(URLQueryItem(name: "phone", value: phone))
        }
        
        let url = urlComponents.url!
        print(url)
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        print(token)
        return request
    }
}
