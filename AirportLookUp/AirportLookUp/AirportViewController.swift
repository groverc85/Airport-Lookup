//
//  AirportViewController.swift
//  AirportLookUp
//
//  Created by Grover Chen on 4/15/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

class AirportViewController: UIViewController {
    
    @IBOutlet weak var back: UIButton!
    
    @IBOutlet weak var name: UITextView!
    @IBOutlet weak var gps: UITextView!
    @IBOutlet weak var coord: UITextView!
    @IBOutlet weak var location: UITextView!
    @IBOutlet weak var type: UITextView!
    @IBOutlet weak var myWebview: UIWebView!
    
    var airport : Airport?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        back.addTarget(self, action: #selector(self.backtoMapView), for: .touchUpInside)
    
        name.text = airport?.name
        gps.text = airport?.GPSCode
        
        let lat : String = (airport?.coordinate.latitude.description)!
        let lng : String = (airport?.coordinate.longitude.description)!
        
        coord.text = lat + " , " + lng
        location.text = airport?.Municipality
        type.text = "Large Airport"
        
        let url = NSURL (string: "https://www.google.com/#q=" + (airport?.GPSCode)!) ;
        let requestObj = NSURLRequest(url: url! as URL);
        myWebview.loadRequest(requestObj as URLRequest);
    }
    
    @IBAction func backtoMapView(sender: UIButton) {
        self.dismiss(animated: true, completion: {})
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
