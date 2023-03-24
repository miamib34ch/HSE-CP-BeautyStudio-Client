//
//  AuthService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import Foundation

struct AuthResponseBody: Decodable {
    let token: String
    let role: String
}

final class AuthService {
    
    private static var task: URLSessionTask?
    
    static func fetchOAuthToken(login: String,
                                password: String,
                                isItLogin: Bool,
                                completion: @escaping(Result<AuthResponseBody, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        var request: URLRequest
        if isItLogin {
            request = createLogin(login: login, password: password)
        }
        else {
            request = createRegistration(login: login, password: password)
        }
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private static func createLogin(login: String, password: String) -> URLRequest {
        
        // Создание URL
        var urlComponents = URLComponents(string: serverURL + "/login")!
        urlComponents.queryItems = [
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "pass", value: password),
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
    
    private static func createRegistration(login: String, password: String) -> URLRequest {
        
        // Создание URL
        var urlComponents = URLComponents(string: serverURL + "/registration")!
        urlComponents.queryItems = [
            URLQueryItem(name: "login", value: login),
            URLQueryItem(name: "pass", value: password)
        ]
        let url = urlComponents.url!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        return request
    }
}
