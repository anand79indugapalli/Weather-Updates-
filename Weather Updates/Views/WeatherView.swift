//
//  WeatherView.swift
//  Weather Updates
//
//  Created by Anand Indugapalli on 27/07/24.
//
import SwiftUI

struct WeatherView: View {
    @StateObject private var viewModel = WeatherViewModel()
    @State private var city: String = ""

    var body: some View {
        VStack {
            TextField("Enter city", text: $city, onCommit: {
                viewModel.fetchWeather(for: city)
            })
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

            if let weatherData = viewModel.weatherData {
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) { // Increased spacing for better layout
                        Text("City: \(weatherData.name)")
                            .font(.headline)
                            .padding(.bottom, 5)
                        HStack {
                            // Display weather icon
                            if let iconCode = weatherData.weather.first?.icon {
                                let iconURL = URL(string: "https://openweathermap.org/img/wn/\(iconCode)@2x.png")
                                AsyncImage(url: iconURL) { image in
                                    image.resizable()
                                        .scaledToFit()
                                        .frame(width: 60, height: 60) // Increased icon size
                                } placeholder: {
                                    Image(systemName: "cloud") // Placeholder icon
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 50, height: 50)
                                        .foregroundColor(.black)
                                }
                            }
                            
                            // Display weather description
                            if let description = weatherData.weather.first?.description {
                                Text("\(description)")
                                    .font(.headline)
                                    .padding(.leading, 10) // Add some space between the icon and description
                            }
                        }
                        Text("Temperature: \(weatherData.main.temp, specifier: "%.1f")°C")
                        Text("Feels Like: \(weatherData.main.feels_like, specifier: "%.1f")°C")
                        Text("Min Temperature: \(weatherData.main.temp_min, specifier: "%.1f")°C")
                        Text("Max Temperature: \(weatherData.main.temp_max, specifier: "%.1f")°C")
                        Text("Pressure: \(weatherData.main.pressure) hPa")
                        Text("Humidity: \(weatherData.main.humidity)%")
                        Text("Sea Level: \(weatherData.main.sea_level ?? 0) hPa")
                        Text("Ground Level: \(weatherData.main.grnd_level ?? 0) hPa")
                        Text("Visibility: \(weatherData.visibility / 1000) km")
                        Text("Wind Speed: \(weatherData.wind.speed, specifier: "%.1f") m/s")
                        Text("Wind Direction: \(weatherData.wind.deg)°")
                        Text("Wind Gust: \(weatherData.wind.gust ?? 0, specifier: "%.1f") m/s")
                        Text("Cloud Cover: \(weatherData.clouds.all)%")
                        
                        if let rainAmount = weatherData.rain?.oneHour {
                            Text("Rain (last hour): \(rainAmount, specifier: "%.2f") mm")
                        }
                        
                        Text("Sunrise: \(formatDate(from: weatherData.sys.sunrise))")
                        Text("Sunset: \(formatDate(from: weatherData.sys.sunset))")
                    
                    }
                    .padding()
                    .background(Color.gray)
                    .cornerRadius(20) // Increased corner radius for a more rounded look
                    .shadow(color: .gray.opacity(0.6), radius: 20, x: 0, y: 10) // Enhanced shadow effect
                    .frame(maxWidth: 1000) // Set a maximum width for the view
                    .padding() // Adds padding around the view
                }
            } else if let errorMessage = viewModel.errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            }
        }
        .padding()
        .navigationTitle("Weather Forecast")
    }

    private func formatDate(from timestamp: Int) -> String {
        let date = Date(timeIntervalSince1970: TimeInterval(timestamp))
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
}
