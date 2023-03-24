//
//  VisitDetailService.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 24.03.2023.
//

import Foundation

struct SingleVisit: Codable {
    let date: String
    let cost, saleSize: Int
    let responsePriceInVisits: [ResponsePriceInVisit]

    enum CodingKeys: String, CodingKey {
        case date = "Date"
        case cost = "Cost"
        case saleSize = "SaleSize"
        case responsePriceInVisits = "ResponsePriceInVisits"
    }
}

struct ResponsePriceInVisit: Codable {
    let idProcedure, cost: Int
    let procedureName: String

    enum CodingKeys: String, CodingKey {
        case idProcedure = "IdProcedure"
        case cost = "Cost"
        case procedureName = "ProcedureName"
    }
}

final class VisitDetailService {
    
    private var task: URLSessionTask?
    
    func fetchVisitById(id: Int, completion: @escaping(Result<SingleVisit, Error>) -> Void) {
        assert(Thread.isMainThread)
        task?.cancel()
        
        let request = createVisitRequest(id: id)
        
        let task = URLSession.shared.objectTask(for: request, saveDataFunc: { _ in }, completion: completion)
        
        self.task = task
        task.resume()
    }
    
    private func createVisitRequest(id: Int) -> URLRequest {
        let token = AuthStorage().token ?? ""
        let url = URL(string: serverURL + "/visit/\(id)")!

        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        return request
    }
    
}
