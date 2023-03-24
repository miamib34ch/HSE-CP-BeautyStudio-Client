//
//  URLSessionExtension.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 19.03.2023.
//

import Foundation

extension URLSession {
    
    enum NetworkError: Error {
        case customError(String)
        case errorStatusCode(Int)
        case errorResponse(Error)
    }
    
    final func objectTask<T: Decodable>(for request: URLRequest,
                                        saveDataFunc: @escaping (T) -> Void,
                                        completion: @escaping (Result<T, Error>) -> Void) -> URLSessionTask {
        
        let task = dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                
                // Проверяем, пришла ли ошибка
                if let error = error {
                    completion(.failure(NetworkError.errorResponse(error)))
                    return
                }
                
                // Проверяем, что нам пришёл успешный код ответа
                if let response = response as? HTTPURLResponse,
                   response.statusCode < 200 || response.statusCode >= 300 {
                    completion(.failure(NetworkError.errorStatusCode(response.statusCode)))
                    return
                }
                
                // Возвращаем данные
                guard let data = data else {
                    completion(.failure(NetworkError.customError("Нет данных")))
                    return
                }
                do {
                    let response = try JSONDecoder().decode(T.self, from: data)
                    saveDataFunc(response)
                    completion(.success(response))
                }
                catch {
                    completion(.failure(NetworkError.customError("Не удалось декодировать")))
                }
            }
        }
        return task
    }
}
