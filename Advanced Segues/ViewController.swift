//
//  ViewController.swift
//  Advanced Segues
//
//  Created by Ravi Inder Manshahia on 10/11/18.
//  Copyright © 2018 Ravi Inder Manshahia. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    var placeToVisit = ""
    var addPlace = false
    var citiesArray = [String]()

    @IBOutlet weak var map: MKMapView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("Place to Visit is" , placeToVisit)
        
        if addPlace
        {
            addLongPressGestureRecogniser()
            if let objArray = UserDefaults.standard.object(forKey: "city") as? [String]
            {
                citiesArray = objArray
            }
            
        }
        else
        {
            forwardGeocodeAndUpdateMap()
        }
        
        
    }
    
    func addLongPressGestureRecogniser()
    {
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(longPressAction(gestureRecogniser:)))
        uilpgr.minimumPressDuration = 2.0
        map.addGestureRecognizer(uilpgr)
        
    }
    
    @objc func longPressAction(gestureRecogniser : UIGestureRecognizer)
    {
        let touchPoint = gestureRecogniser.location(in: self.map)
        let location2d = map.convert(touchPoint, toCoordinateFrom: self.map)
        
        let annotation = MKPointAnnotation()
        annotation.title = "New place"
        annotation.subtitle = "I Will go here"
        annotation.coordinate = location2d
        
        map.addAnnotation(annotation)
        
        print("Lat : \(location2d.latitude) and Long : \(location2d.longitude)")
        
        //reverse Geocode to
        let location = CLLocation(latitude: location2d.latitude, longitude: location2d.longitude)
        let geocoder = CLGeocoder()
        
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if error == nil {
                if let placemark = placemarks?[0]
                {
                    if let cityName = placemark.subAdministrativeArea
                    {
                        if self.citiesArray.contains(cityName)
                        {
                            print("City Already Exists in DB")
                        }
                        else
                        {
                            self.citiesArray.append(cityName)
                            UserDefaults.standard.setValue(self.citiesArray, forKey: "city")
                            print(placemark.subAdministrativeArea!)
                        }
                        

                    }
                    else
                    {
                        print("Sub ADministrative ARea not found")
                    }
                
                    print("CXomplete placemark is ", placemark)
                }
            }
            else {
                print("Error in Reverse Geocoding is ",error!)
            }
        }
    }

    func forwardGeocodeAndUpdateMap()
    {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(placeToVisit) { (placemarks, error) in
            if error == nil
            {
                if let placemark = placemarks?[0]
                {
                    
                    let latDelta = 0.05
                    let longDelta = 0.05
                    
                    let span = MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: longDelta)
                    let region = MKCoordinateRegionMake((placemark.location?.coordinate)!, span)
                    
                    self.map.setRegion(region, animated: true)
                    print("Placemark is ",placemark)
                    
                    let annotation = MKPointAnnotation()
                    annotation.title = self.placeToVisit
                    annotation.coordinate = (placemark.location?.coordinate)!
                    
                    self.map.addAnnotation(annotation)
                }
            }
            else
            {
                print("Error ::", error)
            }
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

