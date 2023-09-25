//
//  ProfileVisitsService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import Foundation

struct Visit: Codable {
    let idVisit: Int
    let date: String

    enum CodingKeys: String, CodingKey {
        case idVisit = "IdVisit"
        case date = "Date"
    }
}

final class ProfileVisitsService {
    private var task: URLSessionTask?
    
    static let shared = ProfileVisitsService()
    var visits: [Visit] = []
    
    private var createVisitsRequest: URLRequest {
        let token = AuthStorage().token ?? ""
        let url = URL(string: serverURL + "/visit")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
    private init() { }
    
    func fetchVisits(completion: @escaping(Result<[Visit], Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createVisitsRequest
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: saveVisits, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func saveVisits(visits: [Visit]) {
        ProfileVisitsService.shared.visits = visits
    }
}
