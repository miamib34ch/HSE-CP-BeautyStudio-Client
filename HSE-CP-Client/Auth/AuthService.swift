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

        var request: URLRequest?
        if isItLogin {
            request = createEnterRequest(login: login, password: password, endPoint: "/login")
        } else {
            request = createEnterRequest(login: login, password: password, endPoint: "/registration")
        }
        guard let request = request else { return }
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)

        self.task = task
        task.resume()
    }

    private static func createEnterRequest(login: String, password: String, endPoint: String) -> URLRequest? {
        guard let url = URL(string: serverURL + endPoint) else { return nil }

        // Создаём тело запроса
        let json = ["login": login, "pass": password]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        // Создаём запрос
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        return request
    }
}
