//
//  ViewController.swift
//  WeatherApp1
//
//  Created by Serhii CHORNONOH on 6/5/19.
//  Copyright © 2019 Serhii CHORNONOH. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import NVActivityIndicatorView
import CoreLocation
import RecastAI


class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var dayLabel: UILabel!
    
    @IBOutlet weak var conditionImageView: UIImageView!
    @IBOutlet weak var conditionLabel: UILabel!
    
    @IBOutlet weak var tempreratureLabel: UILabel!
    @IBOutlet weak var backgroundView: UIView!
    
    @IBOutlet weak var weatherInTextField: UITextField!
    let bot = RecastAIClient(token: "0a66a3cbe0f5dd9a855774a0040a8123")
    
    @IBOutlet weak var liveUpdateButton: UIButton!
    
    let gradientLayer = CAGradientLayer()
    
    let apiKey = "5a9e8705559d3bc8a0bed71ecad8731a"
    var lat = 11.344533
    var lon = 104.33322
    var activityIndicator: NVActivityIndicatorView!
    let locationManager = CLLocationManager()
    
    var liveUpdate = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backgroundView.layer.addSublayer(gradientLayer)
        
        let indicatorSize: CGFloat = 70
        let indicatorFrame = CGRect(x: (view.frame.width-indicatorSize)/2, y: (view.frame.height-indicatorSize)/2, width: indicatorSize, height: indicatorSize)
        activityIndicator = NVActivityIndicatorView(frame: indicatorFrame, type: .lineScale, color: UIColor.white, padding: 20.0)
        activityIndicator.backgroundColor = UIColor.black
        view.addSubview(activityIndicator)
        
        locationManager.requestWhenInUseAuthorization()
        
        activityIndicator.startAnimating()
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.startUpdatingLocation()
        }
        self.weatherInTextField.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        setBlueGradientBackground()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if liveUpdate == true {
            let location = locations[0]
            lat = location.coordinate.latitude
            lon = location.coordinate.longitude
            //lat = 50.4501
            //lon = 30.524

            getWeather(lat: lat, lon: lon, locationName: nil)
        }
    }
    
    func getWeather(lat: Double, lon: Double, locationName: String?) {
        Alamofire.request("http://api.openweathermap.org/data/2.5/weather?lat=\(lat)&lon=\(lon)&appid=\(apiKey)&units=metric").responseJSON {
            response in
            self.activityIndicator.stopAnimating()
            if let responseStr = response.result.value {
                let jsonResponse = JSON(responseStr)
                let jsonWeather = jsonResponse["weather"].array![0]
                let jsonTemp = jsonResponse["main"]
                let iconName = jsonWeather["icon"].stringValue
                
                if locationName == nil {
                    let newLocationName = "\(jsonResponse["name"].stringValue), \(jsonResponse["sys"]["country"].stringValue)"
                     self.locationLabel.text = newLocationName
                } else {
                    self.locationLabel.text = locationName
                }
                
                self.conditionImageView.image = UIImage(named: iconName)
                self.conditionLabel.text = jsonWeather["main"].stringValue
                self.tempreratureLabel.text = "\(Int(round(jsonTemp["temp"].doubleValue)))"
                print("http://api.openweathermap.org/data/2.5/weather?lat=\(self.lat)&lon=\(self.lon)&appid=\(self.apiKey)&units=metric")
                print(jsonResponse)
                
                let date = Date()
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "EEEE"
                self.dayLabel.text = dateFormatter.string(from: date)
                
                let suffix = iconName.suffix(1)
                if (suffix == "n") {
                    self.setGreyGradientBackground()
                } else {
                    self.setBlueGradientBackground()
                }
            }
        }
    }
    
    func setBlueGradientBackground(){
        let topColor = UIColor(red: 95.0/255.0, green: 165.0/255.0, blue: 1.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 114.0/255.0, blue: 184.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func setGreyGradientBackground(){
        let topColor = UIColor(red: 151.0/255.0, green: 151.0/255.0, blue: 151.0/255.0, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 72.0/255.0, green: 72.0/255.0, blue: 72.0/255.0, alpha: 1.0).cgColor
        gradientLayer.frame = view.bounds
        gradientLayer.colors = [topColor, bottomColor]
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField.text!.isEmpty {
            weatherInTextField.placeholder = "Unknown Place"
            return false
        } else {
            liveUpdate = false
            liveUpdateButton.setImage(UIImage(named: "thermometer0"), for: .normal)
            makeRequest(request: textField.text!)
            textField.resignFirstResponder()
            return true
        }
    }
    
    func makeRequest(request: String) {
        self.bot.textRequest(request, successHandler: successHandler, failureHandle: failureHandle)
    }
    
    func successHandler(_ response : Response) {
        
        if let location = response.get(entity: "location") {
            print("\n\n\(location)\n")
            getWeather(lat: location["lat"]! as! Double,
                       lon: location["lng"]! as! Double,
                       locationName: "\((location["raw"])!), \(String(describing: location["country"]!).uppercased())")
            weatherInTextField.placeholder = "Success"
            weatherInTextField.text = ""
        } else {
            weatherInTextField.placeholder = "I can't get this location"
            weatherInTextField.text = ""
        }
        
    }
    func failureHandle(_ error : Error) {
        weatherInTextField.placeholder = "Technical Works"
        weatherInTextField.text = ""
    }
    @IBAction func liveUpdateButton(_ sender: UIButton) {
        switch liveUpdate {
        case true:
            liveUpdate = false
            sender.setImage(UIImage(named: "thermometer0"), for: .normal)
        default:
            liveUpdate = true
            sender.setImage(UIImage(named: "thermometer1"), for: .normal)
        }
    }
    
}
