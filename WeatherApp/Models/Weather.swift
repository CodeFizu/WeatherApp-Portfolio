//
//  Weather.swift
//  WeatherApp
//
//  Created by Hafizuddin Nordin.
//

import Foundation

struct WeatherResponse: Decodable {
    let main: Main
    let weather: [Weather]
    let wind: Wind
    let name: String
}

struct Main: Decodable {
    let temp: Double
    let feelsLike: Double
    let humidity: Int
    let pressure: Int
    
    // Mapping API keys to property names
    private enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case humidity
        case pressure
    }
}

struct Weather: Decodable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}

struct Wind: Decodable {
    let speed: Double
}
