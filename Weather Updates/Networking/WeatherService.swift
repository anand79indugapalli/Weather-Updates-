//
//  WeatherService.swift
//  Weather Updates
//
//  Created by Anand Indugapalli on 27/07/24.
//

import Foundation
import Combine

enum NetworkServiceError: Error {
    case invalidURL
    case networkError(Error)
    case serverError(Int)
    case decodingError(Error)
    case unknownError
    
    var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "The URL is invalid. Please check the URL and try again."
            case .networkError(let error):
                return "Network error occurred: \(error.localizedDescription). Please check your internet connection and try again."
            case .serverError(let statusCode):
                return "Server error occurred with status code \(statusCode). Please try again later."
            case .decodingError(let error):
                return "Failed to decode the response: \(error.localizedDescription). Please try again."
            case .unknownError:
                return "An unknown error occurred. Please try again."
            }
        }
}

class NetworkService {
    private let session = URLSession.shared
    
    // Generic fetch function using Combine
    func fetch<T: Decodable>(from url: URL, responseType: T.Type) -> Future<T, NetworkServiceError> {
        Future { promise in
            self.session.dataTask(with: url) { data, response, error in
                if let error = error {
                    promise(.failure(.networkError(error)))
                    return
                }
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    promise(.failure(.unknownError))
                    return
                }
                
                switch httpResponse.statusCode {
                case 200:
                    do {
                        let decodedObject = try self.decode(T.self, from: data ?? Data())
                        promise(.success(decodedObject))
                    } catch {
                        promise(.failure(.decodingError(error)))
                    }
                case 400, 404, 500...599:
                    promise(.failure(.serverError(httpResponse.statusCode)))
                default:
                    promise(.failure(.unknownError))
                }
            }.resume()
        }
    }
    
    // Generic decode method
    private func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T {
        let decoder = JSONDecoder()
        return try decoder.decode(T.self, from: data)
    }
}
