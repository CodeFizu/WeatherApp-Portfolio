//
//  ContentView.swift
//  WeatherApp
//
//  Created by Hafizuddin Nordin.
//

import SwiftUI

struct ContentView: View {
    @StateObject var viewModel = WeatherViewModel()
    @State private var isTitleAnimating = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // Gradient background from blue to white
                // 青から白へのグラデーション背景
                LinearGradient(gradient: Gradient(colors: [
                    Color(red: 0.1, green: 0.3, blue: 0.7),
                    Color(red: 0.6, green: 0.8, blue: 1.0)
                ]), startPoint: .top, endPoint: .bottom)
                .edgesIgnoringSafeArea(.all)
                
                ScrollView {
                    VStack(spacing: 20) {
                        // City input field
                        // 都市名入力フィールド
                        TextField("Enter city name / 都市名を入力", text: $viewModel.city)
                            .textFieldStyle(.plain)
                            .padding()
                            .background(Color.white.opacity(0.8))
                            .cornerRadius(12)
                            .shadow(radius: 3)
                            .padding(.horizontal)
                            .submitLabel(.search)
                            .onSubmit {
                                viewModel.fetchWeather()
                            }
                        
                        // Search button
                        // 検索ボタン
                        Button(action: {
                            // Hide keyboard and fetch weather
                            // キーボードを隠して天気を取得
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                            viewModel.fetchWeather()
                        }) {
                            HStack {
                                Image(systemName: "magnifyingglass")
                                Text("Get Weather / 天気を取得")
                            }
                            .font(.headline)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                            .shadow(radius: 3)
                        }
                        .padding(.horizontal)
                        .disabled(viewModel.city.isEmpty)
                        
                        // Loading indicator
                        // ローディングインジケーター
                        viewModel.isLoading ? ProgressView()
                            .scaleEffect(1.5)
                            .padding() : nil
                        
                        // Error message
                        // エラーメッセージ
                        if let errorMessage = viewModel.errorMessage {
                            Text(errorMessage)
                                .foregroundColor(.red)
                                .padding()
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity)
                                .background(Color.white.opacity(0.7))
                                .cornerRadius(10)
                                .padding(.horizontal)
                        }
                        
                        // Weather display
                        // 天気表示
                        if let weather = viewModel.weather {
                            WeatherView(weather: weather, cityName: viewModel.city)
                                .transition(.opacity.combined(with: .scale))
                        }
                        
                        Spacer()
                    }
                    .padding(.top, 30)
                }
            }
            
            .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem(placement: .principal) {
                                HStack(spacing: 10) {
                                    Image(systemName: "cloud.sun.fill")
                                        .symbolRenderingMode(.multicolor)
                                    
                                    // Testing out animations
                                    // アニメーション試し
                                    VStack(spacing: 2) {
                                        Text("WEATHER")
                                            .font(.title2.weight(.black))
                                            .scaleEffect(isTitleAnimating ? 1.05 : 1.0)
                                        
                                        Text("天気アプリ")
                                            .font(.caption.weight(.medium))
                                    }
                                    .foregroundColor(.white)
                                }
                                .onAppear {
                                    withAnimation(.easeInOut(duration: 1.5).repeatForever()) {
                                        isTitleAnimating = true
                                    }
                                }
                            }
                        }
        }
    }
}

struct WeatherView: View {
    let weather: WeatherResponse
    let cityName: String
    
    var body: some View {
        VStack(spacing: 16) {
            Text(cityName)
                .font(.title2)
                .fontWeight(.semibold)
            
            // Main weather info
            // 主要な天気情報
            HStack(spacing: 20) {
                if let icon = weather.weather.first?.icon {
                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                        image.resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                    } placeholder: {
                        ProgressView()
                    }
                }
                
                VStack(alignment: .leading) {
                    Text(String(format: "%.1f°C", weather.main.temp))
                        .font(.system(size: 42, weight: .bold))
                    
                    Text(weather.weather.first?.description.capitalized ?? "N/A")
                        .font(.title3)
                }
            }
            .padding(.vertical)
            
            // Additional weather details
            // 追加の天気詳細
            VStack(spacing: 12) {
                WeatherDetailRow(icon: "thermometer", label: "Feels like / 体感温度", value: String(format: "%.1f°C", weather.main.feelsLike))
                
                WeatherDetailRow(icon: "humidity", label: "Humidity / 湿度", value: "\(weather.main.humidity)%")
                
                WeatherDetailRow(icon: "wind", label: "Wind / 風速", value: String(format: "%.1f m/s", weather.wind.speed))
                
                WeatherDetailRow(icon: "barometer", label: "Pressure / 気圧", value: "\(weather.main.pressure) hPa")
            }
            .padding()
            .background(Color.white.opacity(0.3))
            .cornerRadius(15)
            .padding(.horizontal)
        }
        .padding()
        .background(Color.white.opacity(0.2))
        .cornerRadius(20)
        .shadow(radius: 10)
        .padding(.horizontal)
        .padding(.bottom, 20)
    }
}

struct WeatherDetailRow: View {
    let icon: String
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .frame(width: 30)
            Text(label)
                .font(.subheadline)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    ContentView()
}
