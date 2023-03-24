//
//  SingleProcedure.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 23.03.2023.
//

import UIKit

struct SingleProcedure: Codable {
    let idProcedure, cost: Int
    let photoName, procedureInfo: String?
    let procedureName: String
    let idCategorie: Int

    enum CodingKeys: String, CodingKey {
        case idProcedure = "IdProcedure"
        case cost = "Cost"
        case photoName = "PhotoName"
        case procedureName = "ProcedureName"
        case procedureInfo = "ProcedureInfo"
        case idCategorie = "IdCategorie"
    }
}

final class SingleProcedureService {
    private var task: URLSessionTask?
    
    func fetchProcedure(id: Int, completion: @escaping(Result<SingleProcedure, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createProcedureRequest(id: id)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func createProcedureRequest(id: Int) -> URLRequest {
        
        let url = URL(string: serverURL + "/price/\(id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"

        return request
    }
    
}

