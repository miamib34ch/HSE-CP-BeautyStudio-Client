//
//  ProceduresListService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import Foundation

struct Procedures: Codable {
    let idProcedure: Int
    let cost: Int
    let photoName: String?
    let procedureName: String

    enum CodingKeys: String, CodingKey {
        case idProcedure = "IdProcedure"
        case cost = "Cost"
        case photoName = "PhotoName"
        case procedureName = "ProcedureName"
    }
}

final class ProceduresListService {
    
    static let shared = ProceduresListService()
    var procedures: [Procedures] = []
    
    private var task: URLSessionTask?
    
    private var createProceduresRequest: URLRequest {
        let url = URL(string: serverURL + "/price")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
    
    private init() { }
    
    func fetchProcedures(completion: @escaping(Result<[Procedures], Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createProceduresRequest
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: saveProcedures, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func saveProcedures(procedures: [Procedures]) {
        ProceduresListService.shared.procedures = procedures
    }
    
}
