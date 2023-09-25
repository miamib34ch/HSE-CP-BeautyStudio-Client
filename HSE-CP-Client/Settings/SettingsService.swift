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
        return request
    }

    func sendDeleteRequest(completion: @escaping(Result<MsgResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        let request = createDelete
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        self.task = task
        task.resume()
    }

    func sendUpdateRequest(phone: String?, pass: String?, completion: @escaping(Result<MsgResult, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        guard let request = createUpdateRequest(phone: phone, pass: pass) else { return }
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        self.task = task
        task.resume()
    }

    private func createUpdateRequest(phone: String?, pass: String?) -> URLRequest? {
        let token = AuthStorage().token ?? ""
        guard let url = URL(string: serverURL + "/update") else { return nil }

        // Создаём тело запроса
        let json = ["phone": phone, "pass": pass]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)

        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        return request
    }
}
