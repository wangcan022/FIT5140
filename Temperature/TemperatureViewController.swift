//
//  TemperatureViewController.swift
//  Assignment4
//
//  Created by Can Wang on 10/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//  Reference from: https://medium.com/@OsianSmith/creating-a-line-chart-in-swift-3-and-ios-10-2f647c95392e

import Foundation
import Charts

// temperature view controller
class TemperatureViewController: UIViewController{
    
    @IBOutlet weak var chartView: LineChartView!
    @IBOutlet weak var currTempLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var desLabel: UILabel!
    
    // refresh button
    @IBAction func onClickRefresh(_ sender: Any) {
        self.historyList = [History]()
        viewDidLoad()
    }
    
    var historyList = [History]()
    
    override open func viewDidLoad()
    {
        super.viewDidLoad()
        downloadTempData()
        // Do any additional setup after loading the view.
    }
    
    func viewWillAppear()
    {
        self.chartView.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
    }
    
    // download Temperature Data from server
    func downloadTempData() {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/temp")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
            else{
                self.parseTempData(jsonString: data!)
                //print(self.historyList.last.moisture ?? "112")
                //print(self.historyList.count)
            }
        }
        task.resume()
        
    }
    
    // transform JSON data to String and stored in objects
    func parseTempData(jsonString: Data){
        
        do{
            let result = try JSONSerialization.jsonObject(with: jsonString, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dataArray = result as! NSArray
            for data in (dataArray as NSArray as! [NSDictionary])
            {
                let dataToBeAdd = History()
                //dataToBeAdd.moisture = data.object(forKey: "Moisture") as? String
                //dataToBeAdd.illumination = data.object(forKey: "Illumination") as? String
                dataToBeAdd.temperature = data.object(forKey: "celsius") as? Int
                self.historyList.append(dataToBeAdd)
            }
            
            if (self.historyList.last?.temperature != nil){
                //self.showActivityIndicatory()
                let currentTemp = self.historyList.last?.temperature
                DispatchQueue.main.async(execute: {
                    self.currTempLabel.text = "Current Temperature: \(currentTemp ?? 0)ºC"
                })
                
                if (currentTemp! <= 0){
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "cold")
                        self.desLabel.text = "It`s cold now, you need to warm your plant."
                    })
                    
                }else {
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "warm")
                        self.desLabel.text = "The temperature condition is OK."
                    })
                    
                }
                DispatchQueue.main.async(execute: {
                    let ys1 = Array(1..<11).map { x in return self.tempData(x: x) }
                
                    let yse1 = ys1.enumerated().map { x, y in return ChartDataEntry(x: Double(x), y: y) }
                
                    let data = LineChartData()
                    let ds1 = LineChartDataSet(values: yse1, label: "Temperature")
                    ds1.colors = [NSUIColor.red]
                    data.addDataSet(ds1)
                
                    self.chartView.data = data
                
                    self.chartView.backgroundColor = UIColor.white
                    self.chartView.gridBackgroundColor = NSUIColor.white
                
                    self.chartView.chartDescription?.text = "Latest 10 Values"
                })
            }
        }
        catch let error as NSError{
            print("JSON Serialization Error: \(error)")
        }
    }
    func tempData(x:Int) -> Double{
        var tempValue:Double
        tempValue = Double(historyList[historyList.count-(11-x)].temperature!)
        return tempValue
    }
}


