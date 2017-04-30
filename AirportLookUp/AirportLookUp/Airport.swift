//
//  Airport.swift
//  AirportLookUp
//
//  Created by Grover Chen on 4/15/17.
//  Copyright © 2017 Grover Chen. All rights reserved.
//

import Foundation

import UIKit
import MapKit
import Mapbox

class Airport: MGLPointAnnotation {
    
    var name: String?
    var url: String?
    var GPSCode : String?
    var Municipality: String?
    var type: String?
    var color: UIColor?
    
    init(name: String?, GPSCode: String?, Municipality: String?, type: String?, color: UIColor?) {
        self.name = name
        self.GPSCode = GPSCode
        self.Municipality = Municipality
        self.type = type
        self.color = color
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
