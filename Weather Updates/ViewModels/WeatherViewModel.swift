//
//  WeatherViewModel.swift
//  Weather Updates
//
//  Created by Anand Indugapalli on 27/07/24.
//
import Foundation
import Combine

class WeatherViewModel: ObservableObject {
    @Published var weatherData: WeatherData?
    @Published var errorMessage: String?
    
    private var cancellables = Set<AnyCancellable>()
    private let networkService = NetworkService()
    private let apiKey = "9bbaae949c34db80946ece39fcc760f9"
    
    func fetchWeather(for city: String) {
        // Create URL for weather request
        guard let url = createWeatherURL(for: city) else {
            errorMessage = NetworkServiceError.invalidURL.localizedDescription
            return
        }
        
        // Perform network request and handle response
        networkService.fetch(from: url, responseType: WeatherData.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished:
                    break // No action needed for successful completion
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                    self?.weatherData = nil
                }
            }, receiveValue: { [weak self] data in
                self?.weatherData = data
                self?.errorMessage = nil
            })
            .store(in: &cancellables)
    }
    
    private func createWeatherURL(for city: String) -> URL? {
        var components = URLComponents(string: "https://api.openweathermap.org/data/2.5/weather")
        components?.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric")
        ]
        return components?.url
    }
}
