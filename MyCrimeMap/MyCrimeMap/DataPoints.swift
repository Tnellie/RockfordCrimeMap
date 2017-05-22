//
//  DataPoints.swift
//  MyCrimeMap
//
//  Created by Trevor Nelson on 5/20/17.
//  Copyright © 2017 Trevor Nelson. All rights reserved.
//

import UIKit
// Add imports
import MapKit
import Contacts

// Add MKAnnoations
class DataPoints: NSObject,MKAnnotation{
    
    // Add Variables
    let title:String?
    let locationName:String!
    let district:String!
    let coordinate:CLLocationCoordinate2D
    
    init(title:String,locationName:String,district:String,coordinate:CLLocationCoordinate2D){
        self.title = title
        self.locationName = locationName
        self.district = district
        self.coordinate = coordinate
        super.init()
    }

    // Add fromDataArray func
    class func fromDataArray(_ dataDictionary:NSDictionary!)->DataPoints?{
        // var errors: NSError?
        var latitude:Double = 0.0
        var longitude:Double = 0.0
        
        let date:String! = dataDictionary["occurred_on_date"] as! String
        let time:String! = dataDictionary["occurred_on_time"] as! String
        
        let location:NSDictionary! = dataDictionary.object(forKey: "geom") as! NSDictionary!
        if location != nil{
            let type:String! = location.object(forKey: "type") as! String!
            if type == "Point"
            {
                let coordinates:NSArray! = location.object(forKey: "coordinates") as! NSArray
                latitude = Double(coordinates[1] as! NSNumber)
                longitude = Double(coordinates[0] as! NSNumber)
            }
        }
        
        let pddDistrict = dataDictionary["offense_description"] as! String
        
        let titleForPoint:String! = "\(date):\(time)"
        let subtitleForPoint:String! = "\("crime"):\(pddDistrict)"
        let location2d:CLLocationCoordinate2D = CLLocationCoordinate2D.init(latitude: latitude, longitude: longitude)
        
        return DataPoints.init(title: titleForPoint, locationName: subtitleForPoint, district: pddDistrict, coordinate: location2d)
    }
    // Add subtitle function
    var subtitle:String?{
        return locationName
    }
    
}
