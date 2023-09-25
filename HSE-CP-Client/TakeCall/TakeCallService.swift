//
//  TakeCallService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import UIKit

struct PhoneResult: Codable {
    let phone: String
}

struct MsgResult: Codable {
    let msg: String
}

final class TakeCallService {
    private var task: URLSessionTask?
    
    private var createPhoneRequest: URLRequest {
        let token = AuthStorage().token ?? ""
        let url = URL(string: serverURL + "/phone")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    func fetchPhone(completion: @escaping(Result<PhoneResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createPhoneRequest
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    func sendNote(procedureName: String,
                  massage: String?,
                  phone: String,
                  completion: @escaping(Result<MsgResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createNoteRequest(procedureName: procedureName, massage: massage, phone: phone)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }

    private func createNoteRequest(procedureName: String, massage: String?, phone: String) -> URLRequest {
        let token = AuthStorage().token ?? ""
        
        var urlComponents = URLComponents(string: serverURL + "/note")!
        urlComponents.queryItems = [
            URLQueryItem(name: "ProcedureName", value: procedureName),
            URLQueryItem(name: "massage", value: massage),
            URLQueryItem(name: "phone", value: phone)
        ]
        let url = urlComponents.url!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
}
