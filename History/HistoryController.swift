//
//  HistoryController.swift
//  Assignment4
//
//  Created by Can Wang on 31/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//

import UIKit

// history table view controller
class HistoryController: UITableViewController {

    var historyList = [History]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadHistoryData()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return historyList.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        
        let s: History = self.historyList[indexPath.row]
        cell.moistureLabel.text = "moisture: \(s.moisture ?? "0")"
        //cell.moistureLabel.text = "moisture: 500"
        let red = s.red
        let green = s.green
        let blue = s.blue
        let illuValue = 0.2126 * red! + 0.7152 * green! + 0.0722 * blue!
        cell.illuminationLabel.text = "illumination: \(illuValue)lx"
        cell.tempLabel.text = "temperature: \(s.temperature ?? 0)ºC"
        cell.moistureLabel.textColor = UIColor.white
        cell.illuminationLabel.textColor = UIColor.white
        cell.tempLabel.textColor = UIColor.white
        let image = #imageLiteral(resourceName: "data2")
        cell.backgroundView = UIImageView(image: image)
        return cell
    }

    // download All Data from server
    func downloadHistoryData() {
        var url: URL
        url = URL(string: "http://172.20.10.5:8080/all")!
        
        let task = URLSession.shared.dataTask(with: url){
            data, response, error in
            if(error != nil){
                print("URL Error has occured: \(error!)")
            }
            else{
                self.parseHistoryData(jsonString: data!)
                //print(self.historyList.last?.moisture ?? "112")
                self.tableView.reloadData()
            }
        }
        task.resume()

    }
    
    // transform JSON data to String and stored in objects
    func parseHistoryData(jsonString: Data)
    {
        do{
            let result = try JSONSerialization.jsonObject(with: jsonString, options: JSONSerialization.ReadingOptions.mutableContainers)
            let dataArray = result as! NSArray
            for data in (dataArray as NSArray as! [NSDictionary])
            {
                if(data.object(forKey: "celsius") != nil || data.object(forKey: "Red") != nil || data.object(forKey: "Moisture") != nil){
                    let dataToBeAdd = History()
                    dataToBeAdd.moisture = data.object(forKey: "Moisture") as? String
                    dataToBeAdd.red = data.object(forKey: "Red") as? Double
                    dataToBeAdd.green = data.object(forKey: "Green") as? Double
                    dataToBeAdd.blue = data.object(forKey: "Blue") as? Double
                    dataToBeAdd.temperature = data.object(forKey: "celsius") as? Int
                    historyList.append(dataToBeAdd)
                }
            }
        }
        catch let error as NSError{
            print("JSON Serialization Error: \(error)")
        }
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
