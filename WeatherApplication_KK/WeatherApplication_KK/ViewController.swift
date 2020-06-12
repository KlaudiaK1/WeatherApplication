//
//  ViewController.swift
//  WeatherApplication_KK
//
//  Created by Student on 12.06.2020.
//  Copyright © 2020 wtm. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var image: UIImageView!
    @IBOutlet weak var min_temp: UILabel!
    @IBOutlet weak var max_temp: UILabel!
    @IBOutlet weak var wind_speed: UILabel!
    @IBOutlet weak var wind_direction: UILabel!
    @IBOutlet weak var air_pressure: UILabel!
    @IBOutlet weak var humidity: UILabel!
    @IBOutlet weak var stateName: UILabel!
    
    @IBOutlet weak var prevButton: UIButton!
    
    @IBOutlet weak var nextButton: UIButton!
    
    var pictures = [String:UIImage]()
    var dayCount : Int = 0
    
    var weathers : [[String :Any]] = [[:]]
    
    @IBAction func prevButton(_ sender: UIButton) {
        if(self.dayCount != 0){
            self.nextButton.isEnabled = true
            self.dayCount = self.dayCount-1
            updateView(day: self.dayCount)
            if(self.dayCount == 0){
                self.prevButton.isEnabled = false
            }
        }
    }
    
    @IBAction func nextButton(_ sender: UIButton) {
        if(self.dayCount == 0){
            self.prevButton.isEnabled = true
        }
        if(self.dayCount != self.weathers.count-1){
            self.dayCount = self.dayCount+1
            updateView(day: self.dayCount)
            if(self.dayCount == self.weathers.count-1){
                self.nextButton.isEnabled = false
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.prevButton.isEnabled = false
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadData()
    }
    
    func updateView(day : Int){
        date.text = String(describing: weathers[day]["applicable_date"]!)
        min_temp.text = String(format:"%.f °C", weathers[day]["min_temp"] as! Double)
        max_temp.text = String(format:"%.f °C", weathers[day]["max_temp"] as! Double)
        wind_speed.text = String(format:"%.2f mph", weathers[day]["wind_speed"] as! Double)
        wind_direction.text = String(format:"%.2f ", weathers[day]["wind_direction"] as! Double)
        air_pressure.text = String(format:"%.f mbar", weathers[day]["air_pressure"] as! Double)
        humidity.text = String(format:"%.f %%", weathers[day]["humidity"] as! Double)
        stateName.text = String(describing: weathers[day]["weather_state_name"]!)
        
        let state = String(describing: weathers[day]["weather_state_abbr"]!)
        if(pictures[state] != nil){
            self.image.image = pictures[state]
        }else{
            downloadImage(state: state)
        }
    }
    
    func downloadImage(state : String) {
        if let url = URL(string: "https://www.metaweather.com/static/img/weather/png/64/\(state).png")  {
            image.contentMode = .scaleAspectFit
            getData(from: url)
            {
                data, response, error in
                guard let data = data, error == nil else { return }
                print(response?.suggestedFilename ?? url.lastPathComponent)
                DispatchQueue.main.async() {
                    self.image.image = UIImage(data: data)
                    self.pictures[String(state)] = UIImage(data: data)
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
    }
    
    
    func downloadData(){
        let url: URL = URL.init(string: "https://www.metaweather.com/api/location/44418/")!
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            do{
                let jsonArray = try? JSONSerialization.jsonObject(with: data!, options:[]) as? [String : Any]
                self.weathers = try! jsonArray??["consolidated_weather"] as? [[String : Any]] as! [[String : Any]]
                
                DispatchQueue.main.async {
                    self.updateView(day: self.dayCount)
                }
            }
        }
        task.resume()
    }
    
}


