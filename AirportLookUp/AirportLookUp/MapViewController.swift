//
//  MapViewController.swift
//  AirportLookUp
//
//  Created by Grover Chen on 4/15/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import Foundation
import UIKit
import CoreLocation
import AddressBookUI
import MapKit
import Alamofire
import BWWalkthrough
import Mapbox

class MapViewController: UIViewController, MGLMapViewDelegate, UIGestureRecognizerDelegate, BWWalkthroughViewControllerDelegate {
    
    @IBOutlet weak var mapView: MGLMapView!
    @IBOutlet weak var locationText: UITextView!
    @IBOutlet weak var airportLocationText: UITextView!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var stroyWebview: UIWebView!
    @IBOutlet weak var close: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationText.layer.zPosition = 1
        airportLocationText.layer.zPosition = 1
        resetButton.layer.zPosition = 1.1
        stroyWebview.layer.zPosition = 1.2
        close.layer.zPosition = 1.3
        
        
        // Set the delegate property of our map view to `self` after instantiating it.
        mapView.delegate = self
        
        if let path = Bundle.main.path(forResource: "index", ofType: "html", inDirectory: "story") {
            stroyWebview.loadRequest(URLRequest(url: URL(fileURLWithPath: path)))
        }
        stroyWebview.allowsInlineMediaPlayback = false
    }
    
    @IBAction func closeStory(_ sender: Any) {
        self.stroyWebview.isHidden = true
        self.close.isHidden = true
    }
    
    // To avoid mapViewDidFinishLoadingMap run multiple times
    var FirstTime = true;
    
    class CustomPointAnnotation: MGLPointAnnotation {
        var willUseImage: Bool = false
    }
    
    class CustomAnnotationView: MGLAnnotationView {
        override func layoutSubviews() {
            super.layoutSubviews()
            
            // Force the annotation view to maintain a constant size when the map is tilted.
            scalesWithViewingDistance = false
            
            // Use CALayer’s corner radius to turn this view into a circle.
            layer.cornerRadius = frame.width / 2
            layer.borderWidth = 2
            layer.borderColor = UIColor.white.cgColor
        }
        
        override func setSelected(_ selected: Bool, animated: Bool) {
            super.setSelected(selected, animated: animated)
            
            // Animate the border width in/out, creating an iris effect.
            let animation = CABasicAnimation(keyPath: "borderWidth")
            animation.duration = 0.1
            layer.borderWidth = selected ? frame.width / 4 : 2
            layer.add(animation, forKey: "borderWidth")
        }
    }
    

    // show tutorial
    @IBAction func showWalkThrough(_ sender: Any) {
        showWalkthrough()
    }

    // reset button in the bottom right corner
    @IBAction func centerUserButton(_ sender: Any) {
        if let location = AppDelegate.instance().userLocation {
            let camera = MGLMapCamera(lookingAtCenter: location.coordinate, fromEyeCoordinate: location.coordinate, eyeAltitude: 15000.0)
            self.mapView.setCamera(camera, animated: true)
            self.mapView.setCenter(location.coordinate, animated: true)
        }
        updateNearestLocation()
    }
    
    // User change location(physcial location)
    func userDidChange(notification: Notification) {
        if let location = AppDelegate.instance().userLocation {
            let camera = MGLMapCamera(lookingAtCenter: location.coordinate, fromEyeCoordinate: location.coordinate, eyeAltitude: 15000.0)
            self.mapView.setCamera(camera, animated: true)
        }
        updateNearestLocation()
    }
    
    // User update map action(drag/zoom)
    func mapView(_ mapView: MGLMapView, regionDidChangeAnimated animated: Bool) {
        updateNearestLocation()
    }
    
    // This delegate method is where you tell the map to load a view for a specific annotation. To load a static MGLAnnotationImage, you would use `-mapView:imageForAnnotation:`.
    func mapView(_ mapView: MGLMapView, viewFor annotation: MGLAnnotation) -> MGLAnnotationView? {
        
        guard annotation is MGLPointAnnotation else {
            return nil
        }
        let reuseIdentifier = "\(annotation.coordinate.longitude)"
        // For better performance, always try to reuse existing annotations.
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier)
        
        // draggable pin
        if annotation is CustomPointAnnotation {
            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                annotationView = CustomAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView!.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
                
                annotationView?.isDraggable = false
                
                // Set the annotation view’s background color to a value determined by its longitude.
                let hue = abs(CGFloat(annotation.coordinate.longitude)) / 100
                annotationView!.backgroundColor = UIColor(hue: hue, saturation: 0.5, brightness: 1, alpha: 1)
                annotationView?.layer.zPosition = 1
            }
            return annotationView
        }
        // closest airport pin
        else if annotation is Airport && (annotation as? Airport)?.color == UIColor.blue {
            // If there’s no reusable annotation view available, initialize a new one.
            if annotationView == nil {
                annotationView = MGLAnnotationView(reuseIdentifier: reuseIdentifier)
                annotationView?.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
                annotationView?.layer.cornerRadius = (annotationView?.frame.size.width)! / 2
                annotationView?.layer.borderWidth = 4.0
                annotationView?.layer.borderColor = UIColor.white.cgColor
                annotationView!.backgroundColor = UIColor(red:0.03, green:0.80, blue:0.69, alpha:1.0)
            }
            return annotationView
        }
        else {
            return annotationView
        }
    }
    
    func mapView(_ mapView: MGLMapView, annotationCanShowCallout annotation: MGLAnnotation) -> Bool {
        return true
    }
    
    func mapView(_ mapView: MGLMapView, leftCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        if (annotation is Airport) {
            // Callout height is fixed; width expands to fit its content.
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
            label.textAlignment = .right
            label.textColor = UIColor(red: 0.81, green: 0.71, blue: 0.23, alpha: 1)
            label.text = (annotation as? Airport)?.GPSCode
            
            return label
        }
        
        return nil
    }
    
    func mapView(_ mapView: MGLMapView, rightCalloutAccessoryViewFor annotation: MGLAnnotation) -> UIView? {
        return UIButton(type: .detailDisclosure)
    }
    
    func mapView(_ mapView: MGLMapView, annotation: MGLAnnotation, calloutAccessoryControlTapped control: UIControl) {
        mapView.deselectAnnotation(annotation, animated: false)
        if let airport = annotation as? Airport {
            performSegue(withIdentifier: "showDetails", sender: airport)
        }
    }
    
    
    func updateNearestLocation() {
        var pinAnnotation = CustomPointAnnotation.init()
        
         //update pin location
        for annotation in self.mapView.annotations! {
            if (annotation is CustomPointAnnotation){
                pinAnnotation = annotation as! CustomPointAnnotation
                pinAnnotation.coordinate = self.mapView.centerCoordinate
                // remove old pin
                self.mapView.removeAnnotation(annotation)

                let display = CLLocation(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
                geoCode(location: display)
                // create draggabel pin according to the mapview center
                self.mapView.addAnnotation(pinAnnotation)
            }
        }
        
        for annotation in (self.mapView.annotations)! {
            if (annotation as? Airport)?.color == UIColor.blue {
                self.mapView.removeAnnotation(annotation)
                (annotation as? Airport)?.color = UIColor.red
                self.mapView.addAnnotation(annotation)
            }
        }
        
        // Calculate the distance of all points
        var userPinLocation = CLLocation.init()
        userPinLocation = CLLocation(latitude: pinAnnotation.coordinate.latitude, longitude: pinAnnotation.coordinate.longitude)
        var minDistance : Double = Double(INT_MAX)
        // new pin to add: minAirport(blue pin)
        var minCoord = CLLocationCoordinate2D.init()
        
        // compute the closest airport annotation
        for annotation in self.mapView.annotations! {
            if !(annotation is CustomPointAnnotation)
            {
                let tmpLocation = CLLocation(latitude: annotation.coordinate.latitude, longitude:annotation.coordinate.longitude)
                let distanceInMeters = userPinLocation.distance(from: tmpLocation)
                
                if distanceInMeters < minDistance {
                    minDistance = distanceInMeters
                    minCoord = annotation.coordinate
                }
            }
        }

        // retrieve the closest airport annotation
        for annotation in self.mapView.annotations! {
            if !(annotation is CustomPointAnnotation) {
                if fabs(annotation.coordinate.longitude - minCoord.longitude) <= 0.1 && fabs(annotation.coordinate.latitude - minCoord.latitude) <= 0.1 {
                    self.mapView.removeAnnotation(annotation)
                    (annotation as? Airport)?.color = UIColor.blue
                    self.airportLocationText.text = "Closest airport: " + ((annotation as? Airport)?.name)!
                    self.mapView.addAnnotation(annotation)
                }
            }
        }
    }
    



    override func prepare(for segue: UIStoryboardSegue, sender: Any?){
        if (segue.identifier == "showDetails") {
            let airport = sender as? Airport
            let details = segue.destination as? AirportViewController
            details?.airport = airport
        }
    }
    
    
    //mapViewDidFinishLoadingMap appears to be unreliable. It sometimes not called at all, especially if the map tiles are already cached, and sometimes it is called multiple times.
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        // display airports in the map
        if FirstTime == true {
            do {
                if let file = Bundle.main.url(forResource: "airports", withExtension: "json") {
                    let data = try Data(contentsOf: file)
                    let json = try JSONSerialization.jsonObject(with: data, options: [])
                    if let object = json as? [String: Any] {
                        if let object_2 = object["airport_list"] as? [String: Any] {
                            for (_, airports) in object_2 {
                                let airports_array = (airports as! NSArray) as Array
                                for each_airport in airports_array {
                                    if let size = each_airport["AP_TYPE"] as? String {
                                        if (size == "large_airport") {
                                            let lon = (each_airport["LONGITUDE"] as! NSString).doubleValue
                                            let lat = (each_airport["LATITUDE"] as! NSString).doubleValue
                                            
                                            let centerCoordinate = CLLocationCoordinate2D(latitude: lat, longitude:lon)

                                            let airport = Airport.init(name: each_airport["NAME"] as? String, GPSCode: each_airport["GPS_CODE"] as? String, Municipality: each_airport["MUNICIPALITY"] as? String, type: each_airport["AP_TYPE"] as? String, color: UIColor.red)
                                            
                                            airport.coordinate = centerCoordinate
                                            airport.title = each_airport["NAME"] as? String
                                            
                                            if (airport.coordinate.longitude != 0 && airport.coordinate.latitude != 0)
                                            {
                                                mapView.addAnnotation(airport)
                                            }
                                            
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            catch {
                print(error.localizedDescription)
            }
            
            let Draggable = CustomPointAnnotation()

            if let location = AppDelegate.instance().userLocation {
                Draggable.coordinate = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
                print ("User Location:")
                print (Draggable.coordinate)
                Draggable.title = "Drag Pin"
                mapView.addAnnotation(Draggable)
                
                let camera = MGLMapCamera(lookingAtCenter: location.coordinate, fromEyeCoordinate: location.coordinate, eyeAltitude: 15000.0)
                self.mapView.setCamera(camera, animated: true)
            }
            FirstTime = false
        }
        else {
        }
    }

    func geoCode(location : CLLocation!){
        /* Only one reverse geocoding can be in progress at a time hence we need to cancel existing
         one if we are getting location updates */
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            print(location)
            
            if error != nil {
                print("Reverse geocoder failed with error" + error!.localizedDescription)
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0]
                let thoroughfare = pm.thoroughfare ?? ""
                let locality = pm.locality ?? ""
                let administrativeArea = pm.administrativeArea ?? ""
                let country = pm.country ?? ""
                let postalCode = pm.postalCode ?? ""
                
                let output = thoroughfare + " " + locality + " " +  administrativeArea + " " +  country + " " + postalCode
                    
                self.locationText.text = output
            }
            else {
                print("Problem with the data received from geocoder")
            }
        })
    }
    

    func showWalkthrough(){
        
        // Get view controllers and build the walkthrough
        let stb = UIStoryboard(name: "Walkthrough", bundle: nil)
        let walkthrough = stb.instantiateViewController(withIdentifier: "walk") as! BWWalkthroughViewController
        let page_zero = stb.instantiateViewController(withIdentifier: "walk0")
        let page_one = stb.instantiateViewController(withIdentifier: "walk1")
        let page_two = stb.instantiateViewController(withIdentifier: "walk2")
        let page_three = stb.instantiateViewController(withIdentifier: "walk3")
        
        // Attach the pages to the master
        walkthrough.delegate = self
        walkthrough.add(viewController:page_one)
        walkthrough.add(viewController:page_two)
        walkthrough.add(viewController:page_three)
        walkthrough.add(viewController:page_zero)
        
        self.present(walkthrough, animated: true, completion: nil)
    }
    
    
    // MARK: - Walkthrough delegate -
    
    func walkthroughPageDidChange(_ pageNumber: Int) {
        print("Current Page \(pageNumber)")
    }
    
    func walkthroughCloseButtonPressed() {
        self.dismiss(animated: true, completion: nil)
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

