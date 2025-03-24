//
//  WeatherViewModel.swift
//  WeatherApp
//
//  Created by Hafizuddin Nordin.
//

import Foundation

class WeatherViewModel: ObservableObject {
    @Published var weather: WeatherResponse?
    @Published var city: String = "Tokyo"
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    
    private let apiKey: String = {
        Bundle.main.object(forInfoDictionaryKey: "OPENWEATHER_API_KEY") as? String ?? ""
    }()
    private let baseURL = "https://api.openweathermap.org/data/2.5/weather"
    
    func fetchWeather() {
        // First check if city is empty
        // まず都市名が空かどうかを確認
        guard !city.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "Please enter a city name / 都市名を入力してください"
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        // Create mapping for Japanese cities
        // 日本語の都市名と英語名のマッピング
        let japaneseCities = [
            "東京": "Tokyo",
            "大阪": "Osaka",
            "京都": "Kyoto",
            "横浜": "Yokohama",
            "名古屋": "Nagoya",
            "福岡": "Fukuoka"
        ]
        
        // Use mapped English name if available, otherwise use original input
        // マッピングがあれば英語名を使用そうでなければ入力された名前を使用
        let searchCity = japaneseCities[city] ?? city
        
        // Properly encode the city name
        // 都市名を適切にエンコード
        guard let encodedCity = searchCity.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else {
            errorMessage = "Invalid city name / 無効な都市名です"
            isLoading = false
            return
        }
        
        // Construct URL with Japanese language support
        // 日本語対応のURLを構築
        let urlString = "\(baseURL)?q=\(encodedCity)&appid=\(apiKey)&units=metric&lang=ja"
        
        // Debug print to verify URL
        // デバッグ用にURLを表示
        print("Request URL: \(urlString)")
        
        guard let url = URL(string: urlString) else {
            errorMessage = "Invalid URL / 無効なURLです"
            isLoading = false
            return
        }
        
        // Make API request
        // APIリクエストを実行
        URLSession.shared.dataTask(with: url) { data, response, error in
            DispatchQueue.main.async {
                self.isLoading = false
                
                // Handle network errors
                // ネットワークエラーを処理
                if let error = error {
                    self.errorMessage = "Network error: \(error.localizedDescription) / ネットワークエラー"
                    return
                }
                
                // Check HTTP status code / HTTPステータスコードを確認
                if let httpResponse = response as? HTTPURLResponse,
                   !(200...299).contains(httpResponse.statusCode) {
                    self.errorMessage = "Server error (code: \(httpResponse.statusCode)) / サーバーエラー"
                    return
                }
                
                // Check if data exists
                // データの存在を確認
                guard let data = data else {
                    self.errorMessage = "No data received / データを取得できませんでした"
                    return
                }
                
                // Debug print raw response
                // 生のレスポンスを表示（デバッグ用）
                if let responseString = String(data: data, encoding: .utf8) {
                    print("API Response: \(responseString)")
                }
                
                // Parse the weather data
                // 天気データを解析
                do {
                    let result = try JSONDecoder().decode(WeatherResponse.self, from: data)
                    self.weather = result
                } catch {
                    self.errorMessage = "Failed to decode weather data / 天気データの解析に失敗しました"
                    print("Decoding Error: \(error)")
                }
            }
        }.resume()
    }
}
