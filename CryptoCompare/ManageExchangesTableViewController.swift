//
//  ManageExchangesTableViewController.swift
//  CryptoCompare
//
//  Created by YAGYANK CHADHA on 27/9/17.
//  Copyright © 2017 YAGYANK CHADHA. All rights reserved.
//

import UIKit

class ManageExchangesTableViewController: UITableViewController {
    
    //MARK: Properties
    
    var exchangesArray = [ExchangesSettingTab]()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        //Set table footer to avoid extra rows
        self.tableView.tableFooterView = UIView(frame: CGRect.zero)
        self.updateSettings()
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewWillAppear(_ animated: Bool) {
        

        
    }
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows

        return 5
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "manageExchangesCell")
        
        return cell!
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
    
    func updateSettings()  {
        let userDefaults = UserDefaults.standard
        userDefaults.removeObject(forKey: "exchanges")
        
        let isAtleastOneExchange = userDefaults.object(forKey: "exchanges") as? NSData


        
        if isAtleastOneExchange == nil {
            var exchangeId = Int()
            var exchangeName = String()

            var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/CryptoCompare/API/master/included_sites.json")!)
            request.httpMethod = "GET"
            //        request.httpBody = exchanges
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) //as! [String:AnyObject]
                let exchanges = responseJSON as? [String:Any]
                for key in (exchanges?.keys)! {
                    let val = exchanges?[key] as? [String:Any]
                    exchangeId = val?["id"] as! Int
                    exchangeName = key as! String
                    var currencies = [String]()
                    var allowExchange = [Bool]()
                    for cur in (val?["currency"])! as! [Any] {
                        currencies.append(cur as! String)
                        allowExchange.append(false)
                    }
                let exchangeDetail = ExchangesSettingTab(name: exchangeName, id: exchangeId, allowExchange: allowExchange, currency: currencies)
                self.exchangesArray.append(exchangeDetail)
                }
                self.exchangesArray.remove(at: 2)
                userDefaults.setValue(NSKeyedArchiver.archivedData(withRootObject: self.exchangesArray), forKey: "exchanges")
                userDefaults.synchronize()
                let a: [ExchangesSettingTab]
                a = NSKeyedUnarchiver.unarchiveObject(with: (userDefaults.object(forKey: "exchanges") as! NSData) as Data) as! [ExchangesSettingTab]
                    for x in a {
                        print(x.id, x.allowExchange, x.currency)
                    }
                print("Yagyank")

            }
            task.resume()
        }
        else {
            exchangesArray = NSKeyedUnarchiver.unarchiveObject(with: (userDefaults.object(forKey: "exchanges") as! NSData!) as Data!) as! [ExchangesSettingTab]
            var exchangeId = Int()
            var exchangeName = String()
            
            var request = URLRequest(url: URL(string: "https://raw.githubusercontent.com/CryptoCompare/API/master/included_sites.json")!)
            request.httpMethod = "GET"
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: []) //as! [String:AnyObject]
                let exchanges = responseJSON as? [String:Any]
                for key in (exchanges?.keys)! {
                    let val = exchanges?[key] as? [String:Any]
                    exchangeId = val?["id"] as! Int
                    exchangeName = key as! String
                    var isExchangeAvailable = self.findExchange(exchangeId: exchangeId)
                    if isExchangeAvailable == false {
                        var currencies = [String]()
                        var allowExchange = [Bool]()
                        for cur in (val?["currency"])! as! [Any] {
                            currencies.append(cur as! String)
                            allowExchange.append(false)
                        }
                        let exchangeDetail = ExchangesSettingTab(name: exchangeName, id: exchangeId, allowExchange: allowExchange, currency: currencies)
                        self.exchangesArray.append(exchangeDetail)
                    } else {
                        var currencies = [String]()
                        for cur in (val?["currency"])! as! [Any] {
                            currencies.append(cur as! String)
                        }
                        self.findCurrencies(exchangeId: exchangeId, currencies: currencies)
                    }

                }
                
                userDefaults.setValue(NSKeyedArchiver.archivedData(withRootObject: self.exchangesArray), forKey: "exchanges")
                userDefaults.synchronize()
                                let a: [ExchangesSettingTab]
                                a = NSKeyedUnarchiver.unarchiveObject(with: (userDefaults.object(forKey: "exchanges") as! NSData) as Data) as! [ExchangesSettingTab]
                                    for x in a {
                                        print(x.id, x.allowExchange, x.currency)
                                    }
                
            }
            task.resume()
            for x in exchangesArray {
                print(x.id, x.allowExchange, x.currency)
            }
        }
    }
    
    func findExchange(exchangeId: Int) -> Bool {
        
        var found = false
        for val in exchangesArray {
            if exchangeId == val.id {
                found = true
            }
        }
        return found
    }
    
    func findCurrencies(exchangeId: Int, currencies: [String]) {
        
        var found = false
        for (idx,val) in exchangesArray.enumerated() {
            if exchangeId == val.id {
                for currency in currencies {
                    found = false
                    for storedCurrency in val.currency {
                        if currency == storedCurrency {
                            found = true
                            break
                        }
                    }
                    if found == false {
                        exchangesArray[idx].currency.append(currency)
                        exchangesArray[idx].allowExchange.append(false)
                    }
                }
                break
            }
        }
        
    }
    

}
