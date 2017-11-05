//
//  IlluminationViewController.swift
//  Assignment4
//
//  Created by Can Wang on 10/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//

import UIKit

//illumination view controller
class IlluminationViewController: UIViewController {

    @IBOutlet weak var currIlluLabel: UILabel!
    @IBOutlet weak var desLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var colorImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    // refresh button
    @IBAction func onClickRefresh(_ sender: Any) {
        self.historyList = [History]()
        viewDidLoad()
    }

    // turn on light button
    @IBAction func onClickTurnOnLight(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        if (statusLabel.text == "Current Status: ON"){
            let alertController = UIAlertController(title: "Warning!", message: "The light has already been turned on!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else {
            let alertController = UIAlertController(title: "Congratulations!", message: "The light is on now!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            turnOnLight()
            statusLabel.text = "Current Status: ON"
        }
    }
    
    // turn off light button
    @IBAction func onClickTurnOffLight(_ sender: Any) {
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default)
        if (statusLabel.text == "Current Status: OFF"){
            let alertController = UIAlertController(title: "Warning!", message: "The light has already been turned off!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
        }else if (statusLabel.text == "Current Status: ON"){
            let alertController = UIAlertController(title: "Congratulations!", message: "The light is off now!", preferredStyle: UIAlertControllerStyle.alert)
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            turnOffLight()
            statusLabel.text = "Current Status: OFF"
        }
    }
    
    var historyList = [History]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRGBData()
        if (statusLabel.text != "Current Status: ON"){
            statusLabel.text = "Current Status: OFF"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // download RGB Data from server
    func downloadRGBData() {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/rgb")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
            else{
                self.parseRGBData(jsonString: data!)
                //print(self.historyList.last?.moisture ?? "112")
                //print(self.historyList.count)
            }
        }
        task.resume()
        
    }
    
    // transform JSON data to String and stored in objects
    func parseRGBData(jsonString: Data){
        
        do{
            let result = try JSONSerialization.jsonObject(with: jsonString, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dataArray = result as! NSArray
            for data in (dataArray as NSArray as! [NSDictionary])
            {
                let dataToBeAdd = History()
                //dataToBeAdd.moisture = data.object(forKey: "Moisture") as? String
                //dataToBeAdd.illumination = data.object(forKey: "Illumination") as? String
                dataToBeAdd.red = data.object(forKey: "Red") as? Double
                dataToBeAdd.green = data.object(forKey: "Green") as? Double
                dataToBeAdd.blue = data.object(forKey: "Blue") as? Double
                self.historyList.append(dataToBeAdd)
            }
            
            if (self.historyList.last?.blue != nil){
                //self.showActivityIndicatory()
                let currentIllu = self.historyList.last
                let currentRed = currentIllu?.red
                let currentGreen = currentIllu?.green
                let currentBlue = currentIllu?.blue
                DispatchQueue.main.async(execute: {
                    self.colorImageView.backgroundColor = UIColor(red: CGFloat(currentRed!/65535*3), green: CGFloat(currentGreen!/65535*3), blue: CGFloat(currentBlue!/65535*3), alpha: 1)
                })
                let currentIlluValue = 0.2126 * currentRed! + 0.7152 * currentGreen! + 0.0722 * currentBlue!
                DispatchQueue.main.async(execute: {
                    self.currIlluLabel.text = "Current Illumination: \(String(Int(currentIlluValue)))lx"
                })
                
                if (currentIlluValue <= 250){
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "moon")
                        self.desLabel.text = "It`s dark now, you need to turn on your lights."
                    })
                    
                }else {
                    DispatchQueue.main.async(execute: {
                        self.imageView.image = #imageLiteral(resourceName: "sun")
                        self.desLabel.text = "The illumination condition is OK."
                    })
                    
                }
            }
        }
        catch let error as NSError{
            print("JSON Serialization Error: \(error)")
        }
    }
    
    // controll to turn on light
    func turnOnLight()
    {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/setlight?instruction=1")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
        }
        task.resume()
    }
    
    // controll to turn off light
    func turnOffLight()
    {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/setlight?instruction=0")!
        
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
