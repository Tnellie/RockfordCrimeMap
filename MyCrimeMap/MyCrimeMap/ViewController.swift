//
//  ViewController.swift
//  MyCrimeMap
//
//  Created by Trevor Nelson on 5/20/17.
//  Copyright © 2017 Trevor Nelson. All rights reserved.
//

import UIKit
// Add import statements
import MapKit
import Foundation

// Add MKMapViewDelegate, CLLocationManagerDelegate
class ViewController: UIViewController,MKMapViewDelegate,CLLocationManagerDelegate {

    // Create variables
    var intCount:Int! = 0
    var dataPoints:[DataPoints] = [DataPoints]()
    var crimedate:String!
    var currentValue:Int!
    let startLocation = CLLocation(latitude:  42.288880, longitude: -89.061026	)
    var gameTimer: Timer!
    var strCrimeType = [String]()
    
    // Add objects
    @IBOutlet weak var lblcount: UILabel!
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var lblCrimeRange: UILabel!
    
    @IBAction func btnMe(_ sender: UIBarButtonItem) {
        centermeonmap()
    }
    
    @IBAction func btnList(_ sender: Any) {
        var strShow:String! = ""
        var counts:[String:Int] = [:]
        
        for item in strCrimeType {
            counts[item] = (counts[item] ?? 0) + 1
        }
        
        let objnCountSorted = counts.sorted (by: {$0.value > $1.value})
        
        for (key, value) in objnCountSorted {
            print("\(value): \(key) time(s)")
            strShow = strShow.appending("\(key) (count: \(value))\n")
        }
        
        let messageText = NSMutableAttributedString(
            string: strShow,
            attributes: [
                NSParagraphStyleAttributeName: NSParagraphStyle(),
                NSFontAttributeName: UIFont.systemFont(ofSize: 12.0)
            ]
        )
        
        let alert = UIAlertController(title: "Analytics", message: strShow, preferredStyle: UIAlertControllerStyle.actionSheet)
        alert.setValue(messageText, forKey: "attributedMessage")
        alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func DateSlider(_ sender: UISlider) {
        // Add days ago to label from slider
        currentValue = Int(sender.value)
        if (currentValue == 1){
            lblCrimeRange.text = "\(currentValue!) Day Ago Until Now."
        } else{
            lblCrimeRange.text = "\(currentValue!) Days Ago Until Now."
        }
    }
    
    @IBAction func DateSliderUp(_ sender: UISlider) {
        // Add code to DateSliderUp to determine how far back to get crime json
        currentValue = Int(sender.value)
        let now = Date()
        mapView.removeAnnotations(mapView.annotations)
        var i = 1
        
        while i <= currentValue {
            let daysToAdd = i
            let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -daysToAdd, to: now, options: NSCalendar.Options.init(rawValue: 0))
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            let newDates = dateFormatter.string(from: calculatedDate!)
            crimedate = newDates
            strCrimeType.removeAll()
            loadDataFromSODAApi()
            i = i + 1
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //6 When App loads get formatted date from slider
        //mapView.delegate = self
        //GET DATE
        let now = Date()
        let daysToAdd = 1
        let calculatedDate = (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: -daysToAdd, to: now, options: NSCalendar.Options.init(rawValue: 0))
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let newDates = dateFormatter.string(from: calculatedDate!)
        crimedate = newDates
        
        //centerMapOnLocation(startLocation)
        //checkLocationAuthorizationStatus()
        mapView.delegate = self
        
        
        setUpNavigationBar()
        mapView.showsUserLocation = true
        //centerMapOnLocation(location: locationManager.location!)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(centeronmap), userInfo: nil, repeats: false)
        
        gameTimer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(UpdateCount), userInfo: nil, repeats: true)
    }
    
    // Add four functions
    
    func UpdateCount() {
        lblcount.text = "\(mapView.visibleAnnotations().count.description) visible crimes"
    }
    
    func centermeonmap() {
        let userLocation = mapView.userLocation
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.location!.coordinate, 5000, 5000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func centeronmap() {
        let userLocation = startLocation
        
        let region = MKCoordinateRegionMakeWithDistance(userLocation.coordinate, 18000, 18000)
        
        mapView.setRegion(region, animated: true)
    }
    
    func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
        //mapView.centerCoordinate = userLocation.location!.coordinate
    }
    
    func setUpNavigationBar() {
        self.navigationBar.barTintColor = UIColor.red
        self.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }

    func loadDataFromSODAApi(){
        let session:URLSession! = URLSession.shared
        print(crimedate)
        var strURL:String!
        strURL = "https://data.illinois.gov/resource/ctfx-e3rj.json?occurred_on_date=\(crimedate!)"
        //let url:URL = URL(string:"https://data.illinois.gov/resource/ctfx-e3rj.json?occurred_on_date=\(crimedate)")!
        let url:URL = URL(string:strURL)!
        // intCount = 0
        
        let task = session.dataTask(with: url, completionHandler: {data, response, error in
            guard let actualData = data else{
                return
            }
            do{
                let jsonResult:NSArray = try JSONSerialization.jsonObject(with: actualData, options: JSONSerialization.ReadingOptions.mutableLeaves) as! NSArray
                DispatchQueue.main.async(execute: {
                    for item in jsonResult {
                        self.intCount = self.intCount + 1
                        let dataDictionary = item as! NSDictionary
                        let datapoint:DataPoints! = DataPoints.fromDataArray(dataDictionary)!
                        self.dataPoints.append(datapoint)
                        var thepoint = MKPointAnnotation()
                        thepoint = MKPointAnnotation()
                        thepoint.coordinate = datapoint.coordinate
                        //thepoint.title = datapoint.title!
                        let s1 : String =  (datapoint?.title)!
                        let s2 = s1.replacingOccurrences(of: "Optional(", with: "")
                        let s3 = s2.replacingOccurrences(of: "):", with: " ")
                        let s4 = s3.replacingOccurrences(of: ")", with: "")
                        let s5 = s4.replacingOccurrences(of: "\"", with: "")
                        print(s5)
                        thepoint.title = s5
                        thepoint.subtitle = datapoint.district
                        self.strCrimeType.append(datapoint.district)
                        self.mapView.addAnnotation(thepoint)
                        
                    }
                })
                
            }catch let parseError{
                print("Response Status - \(parseError)")
            }
        })
        // intCount = 0
        
        task.resume()
    }
}

//Add extension MKMapView
extension MKMapView {
    func visibleAnnotations() -> [MKAnnotation] {
        return self.annotations(in: self.visibleMapRect).map { obj -> MKAnnotation in return obj as! MKAnnotation }
    }
}

