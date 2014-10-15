//
//  ViewController.swift
//  Atmosphere
//
//  Created by ryohey on 2014/10/15.
//  Copyright (c) 2014年 covelline. All rights reserved.
//

import UIKit
import CoreLocation
import Alamofire

class ViewController: UIViewController, CLLocationManagerDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    let locationManager = CLLocationManager()
    let cities = "2715459,3675605,2510137,3169592,2617034,1608269,3430863,2781161,4889668,3448545,2665902,787526,3060835,1175678,3181359,1690320,4844184,2988082,5033762,315985,261715,3449319,3178578,2759407,2337352,2264341,684477,111822,2738159,3689187,490466,2661689,5263301,5238190,1805515,5868651,922773,259824,2657770,3172796,2633982,3004513,1807234,295982,5205806,3149533,1525798,589922,668104,203717,2997493,1257751,483696,251948,3393106,518944,1697799,4864315,3522886,1701874,2893939,3179920,517836,2386042,3179013,5137600,3066595,2930432,2509598,3522795,3692072,1507059,2983141,2978618,5370006,2657844,4643005,2643661,3163872,727462,4902559,3668268,362004,4710963,666922,5243712,6243776,679886,4529292,2517894,5364729,378502,1221808,1258293,4746457,3465737,5146831,3144733,4431283,2972350"
    
    var items: Array<NSDictionary> = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        
        locationManager.desiredAccuracy = 1000; // 1km
        locationManager.distanceFilter = 1000;
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .Authorized, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .NotDetermined:
            locationManager.requestWhenInUseAuthorization()
            break
        case .Denied, .Restricted:
            showYouShouldChangeSettingAlert()
            break
        }
    }
    
    func showYouShouldChangeSettingAlert() {
        
        let alert = UIAlertController(title: "位置情報サービスの利用を許可してください", message: nil, preferredStyle: UIAlertControllerStyle.Alert)
        
        let settingAction = UIAlertAction(title: "設定", style: UIAlertActionStyle.Default) { (action) -> Void in
            let url = NSURL(string:UIApplicationOpenSettingsURLString)
            UIApplication.sharedApplication().openURL(url)
        }
        alert.addAction(settingAction)
        
        let cancelAction = UIAlertAction(title: "キャンセル", style: UIAlertActionStyle.Cancel, nil)
        alert.addAction(cancelAction)
        
        showViewController(alert, sender: self)
    }
    
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        
        switch status {
        case .Authorized, .AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
            break
        case .Denied, .NotDetermined, .Restricted:
            showYouShouldChangeSettingAlert()
            break
        }
    }
    
    func locationManager(manager: CLLocationManager!, didFailWithError error: NSError!) {
        
    }
    
    func locationManagerDidPauseLocationUpdates(manager: CLLocationManager!) {
        
    }
    
    func locationManagerDidResumeLocationUpdates(manager: CLLocationManager!) {
        
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        let location = (locations as NSArray).lastObject as CLLocation
        
        println(location.coordinate.latitude)
        println(location.coordinate.longitude)
        
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/group", parameters:[
            "units": "metric",
            "id": cities
            ])
            .responseJSON { [unowned self] (request, response, json, error) in
                println(request)
                println(json)
                println(error)
                let dict = json as NSDictionary
                self.items = dict["list"] as Array<NSDictionary>
                self.tableView.reloadData()
        }
        
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters:[
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude])
            .responseJSON { (request, response, json, error) in
                println(request)
                println(json)
                println(error)
        }
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell") as UITableViewCell
        
        
        let item = items[indexPath.row]
        cell.textLabel?.text = item["name"] as String!
        
        let weathers = item["weather"] as NSArray
        let weather = weathers.firstObject as NSDictionary
        cell.detailTextLabel?.text = weather["description"] as String!
        
        return cell
    }
}

