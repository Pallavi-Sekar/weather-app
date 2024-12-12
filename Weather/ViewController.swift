//
//  ViewController.swift
//  Weather
//
//  Created by Pallavi on 2024-11-15.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var cityName: UILabel!
    @IBOutlet weak var weatherDescription: UILabel!
    @IBOutlet weak var weatherIcon: UIImageView!
    @IBOutlet weak var temperature: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var windSpeed: UILabel!
    
    
    let locationManager = CLLocationManager()
    //api key from open weather app
        let apiKey = "560d89ce912529ed3a69944cf8e8bb90"
        
    
        override func viewDidLoad() {
            super.viewDidLoad()
            
            // configuration of Location Manager
            locationManager.delegate = self
            locationManager.requestWhenInUseAuthorization()
            locationManager.startUpdatingLocation()
        }
        
        // location Manager Delegate
        func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            guard let location = locations.first else { return }
            locationManager.stopUpdatingLocation() // Stop updates to save battery
            fetchWeatherData(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        }
        
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to find user's location: \(error.localizedDescription)")
        }
        
        // fetch weather data from open weather app
        func fetchWeatherData(latitude: Double, longitude: Double) {
            let urlString = "https://api.openweathermap.org/data/2.5/weather?lat=\(latitude)&lon=\(longitude)&appid=\(apiKey)&units=metric"
            
            guard let url = URL(string: urlString) else { return }
            
            URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
                if let error = error {
                    print("Error fetching data: \(error.localizedDescription)")
                    return
                }
                
                guard let data = data else {
                    return
                }
                
                do {
                    let decoder = JSONDecoder()
                    let weatherData = try decoder.decode(WeatherResponse.self, from: data)
                    DispatchQueue.main.async {
                        self?.updateUI(with: weatherData)
                    }
                } catch {
                    print("Error decoding JSON: \(error.localizedDescription)")
                }
            }.resume()
        }
        
        // update ui
    func updateUI(with weatherData: WeatherResponse) {
        cityName.text = weatherData.name
        weatherDescription.text = weatherData.weather.first?.description.capitalized
        temperature.text = "\(weatherData.main.temp) °C"
        humidity.text = "Humidity: \(weatherData.main.humidity)%"
        windSpeed.text = "Wind Speed: \(weatherData.wind.speed) m/s"
        
        // weather icon should be updated as per the weather
        if let icon = weatherData.weather.first?.icon {
            let iconUrlString = "https://openweathermap.org/img/wn/\(icon)@2x.png"
            if let iconUrl = URL(string: iconUrlString) {
                URLSession.shared.dataTask(with: iconUrl) { [weak self] data, response, error in
                    if let error = error {
                        print("Error loading weather icon: \(error.localizedDescription)")
                        return
                    }
                    
                    guard let data = data, let image = UIImage(data: data) else { return }
                    
                    DispatchQueue.main.async {
                        self?.weatherIcon.image = image
                    }
                }.resume()
            }
        }
    }
    }

    // weather data models
    struct WeatherResponse: Codable {
        let main: Main
        let weather: [Weather]
        let wind: Wind
        let name: String
    }

    struct Main: Codable {
        let temp: Double
        let humidity: Double
    }

    struct Weather: Codable {
        let description: String
        let icon: String
    }

    struct Wind: Codable {
        let speed: Double
    }
