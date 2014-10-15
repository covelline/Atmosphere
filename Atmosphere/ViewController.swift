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

class ViewController: UIViewController, CLLocationManagerDelegate {
    let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        Alamofire.request(.GET, "http://api.openweathermap.org/data/2.5/weather", parameters:[
            "lat": location.coordinate.latitude,
            "lon": location.coordinate.longitude])
            .responseJSON { (request, response, json, error) in
                println(request)
                println(json)
                println(error)
        }
    }

}

