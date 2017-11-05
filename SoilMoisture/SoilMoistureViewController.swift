//
//  SoilMoistureViewController.swift
//  Assignment4
//
//  Created by Can Wang on 10/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://github.com/jamesdouble/JDProgressRoundView

import Foundation
import UIKit

// moisture view controller
class SoilMoistureViewController: UIViewController {

    var historyList = [History]()
    var roundview: ProcessRoundView!

    
    @IBOutlet weak var currMoistureLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var moistureView: UIView!
    @IBOutlet weak var currStatusLabel: UILabel!
    
    // refresh button
    @IBAction func onClickRefresh(_ sender: Any) {
        self.historyList = [History]()
        self.showActivityIndicatory()
        viewDidLoad()
    }
    
    // stop watering button
    @IBAction func onClickStop(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        if (currStatusLabel.text == "Current Status: AUTO-OFF"){
            let alertController = UIAlertController(title: "Warning!", message: "Auto watering has already been closed!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else{
            let alertController = UIAlertController(title: "Congratulations!", message: "Auto watering is closed!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            endToWater()
            currStatusLabel.text = "Current Status: AUTO-OFF"
        }

    }
    
    // start watering button
    @IBAction func onClickWater(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        if(currStatusLabel.text == "Current Status: AUTO-ON"){
            let alertController = UIAlertController(title: "Warning!", message: "Auto watering has already been choosen!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else {
            if (historyList.last?.moisture != nil){
                if ((historyList.last?.moisture?.integerValue)! <= 500){
                    let alertController = UIAlertController(title: "Congratulations!", message: "Watering is processing! It will stop watering when the moisture level is over standard.", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                    startToWater()
                    currStatusLabel.text = "Current Status: AUTO-ON"
                }else{
                    let alertController = UIAlertController(title: "Warning!", message: "The moisture level is over standard, don`t water too much!", preferredStyle: UIAlertControllerStyle.alert)
                    alertController.addAction(okAction)
                    self.present(alertController, animated: true, completion: nil)
                }
                
            }else {
                let alertController = UIAlertController(title: "Warning!", message: "Please be patient while the system is downloading data from sensor.", preferredStyle: UIAlertControllerStyle.alert)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadingView.hidesWhenStopped = true
        self.loadingView.activityIndicatorViewStyle =
            UIActivityIndicatorViewStyle.whiteLarge
        self.historyList = [History]()
        for view in moistureView.subviews{
            view.removeFromSuperview()
        }
        downloadMoistureData()
        if(currStatusLabel.text != "Current Status: AUTO-ON"){
            currStatusLabel.text = "Current Status: AUTO-OFF"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download Moisture Data from server
    func downloadMoistureData() {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/moisture")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
            else{
                self.parseMoistureData(jsonString: data!)
                //print(self.historyList.last?.moisture ?? "112")
                //print(self.historyList.count)
            }
        }
        task.resume()
        
    }
    
    // transform JSON data to String and stored in objects
    func parseMoistureData(jsonString: Data){
        
        do{
            let result = try JSONSerialization.jsonObject(with: jsonString, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dataArray = result as! NSArray
            for data in (dataArray as NSArray as! [NSDictionary])
            {
                let dataToBeAdd = History()
                dataToBeAdd.moisture = data.object(forKey: "Moisture") as? String
                //dataToBeAdd.illumination = data.object(forKey: "Illumination") as? Double
                //dataToBeAdd.temperature = data.object(forKey: "Temperature") as? Double
                self.historyList.append(dataToBeAdd)
            }
            
            if (self.historyList.last?.moisture != nil){
                //self.showActivityIndicatory()
                let currentMoisture = self.historyList.last?.moisture
                DispatchQueue.main.async(execute: {
                    self.currMoistureLabel.text = "Current Moisture: \(currentMoisture ?? "0")"
                })
                
                if ((currentMoisture?.integerValue)! <= 500){
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "dry")
                        self.desLabel.text = "It`s dry now, you need water your plant."
                    })
                    
                }else {
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "wet")
                        self.desLabel.text = "The moisture condition is OK."
                    })
                }
                DispatchQueue.main.async(execute: {
                    let currentProgress = (self.historyList.last?.moisture?.doubleValue)!/10
                    self.roundview = ProcessRoundView(frame: self.moistureView.frame, howtoincrease: .Water, ProgressColor:  UIColor(red: 0.11, green: 0.88, blue: 0.95, alpha: 1.0), BorderWidth: 13, progress: CGFloat(currentProgress))
                    self.roundview.frame.origin = self.moistureView.bounds.origin
                    self.moistureView.addSubview(self.roundview)//draw round view and pass data
                     })
                self.hideActivityIndicator()
            }
        }
        catch let error as NSError{
            print("JSON Serialization Error: \(error)")
        }
    }
    
    // show loading view
    func showActivityIndicatory(){
        DispatchQueue.main.async(execute: {
            self.loadingView.startAnimating()
        })
    }
    
    // stop loading view
    func hideActivityIndicator() {
        DispatchQueue.main.async(execute: {
            self.loadingView.stopAnimating()
        })
    }
    
    // controll to start watering
    func startToWater()
    {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/setautowatering?instruction=1")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
        }
        task.resume()
    }
    
    // controll to stop watering
    func endToWater()
    {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/setautowatering?instruction=0")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
        }
        task.resume()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
