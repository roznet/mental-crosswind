//
//  Speed.swift
//  xwind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import Foundation

struct Speed {
    var roundedSpeed : Int
    
    var speed : Double {
        get { Double(self.roundedSpeed) }
        set { self.roundedSpeed = Int(round(newValue)) }
    }
    
    var description : String {
        get { "\(roundedSpeed)" }
        set { if let x = Int(newValue) { roundedSpeed = x } else { roundedSpeed = 0 } }
    }
    
    init( roundedSpeed : Int){
        self.roundedSpeed = roundedSpeed
    }
    
    init( speed : Double){
        self.roundedSpeed = Int(round(speed))
    }
    
}
