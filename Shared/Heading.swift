//
//  Heading.swift
//  xwind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import Foundation

struct Heading {
    enum Direction {
        case left
        case right
        case ahead
        case behind
    }
    
    private(set) var roundedHeading : Int
    
    var heading : Double {
        get { return Double(roundedHeading) }
        set { self.roundedHeading = Int(round(newValue)) % 360 }
    }
    
    var description : String {
        get { let x = Int(round(heading)); return "\(x)" }
        set { if let x = Int(newValue) { self.roundedHeading = x } }
    }
    
    var runwayDescription : String {
        get { let x = Int(round(heading/10)); return "\(x)" }
        set { if let x = Int(newValue) { self.roundedHeading = (x % 360) * 10 } }
    }
    
    //MARK: - Init
    
    init(roundedHeading: Int){
        self.roundedHeading = roundedHeading
    }
    
    init(runwayDescription : String){
        if let x = Int(runwayDescription) {
            self.roundedHeading = x * 10
        }else{
            self.roundedHeading = 0
        }
    }
    
    init(heading : Double){
        self.roundedHeading = Int(round(heading))
    }
    
    init(description: String){
        if let x = Int(description) {
            self.roundedHeading = x
        }else{
            self.roundedHeading = 0
        }

    }

    //MARK: - Computations
    
    func absoluteDifference(with other : Heading) -> Heading {
        let diff = abs(other.roundedHeading - self.roundedHeading)
        if diff > 180 {
            return Heading(roundedHeading: 360-diff)
        }else{
            return Heading(roundedHeading: diff)
        }
    }
    
    func direction(to other: Heading) -> Direction {
        let diff = self.absoluteDifference(with: other)
        if diff.roundedHeading == 0 {
            return .ahead
        }else if diff.roundedHeading == 180 {
            return .behind
        }else{
            if( self + diff == other){
                return .right
            }else{
                return .left
            }
        }
    }
    
    func crossComponentPercent(with other : Heading) -> Double {
        return __sinpi(self.absoluteDifference(with: other).heading/180.0)
    }
    
    func directComponentPercent(with other : Heading) -> Double {
        return __cospi(self.absoluteDifference(with: other).heading/180.0)
    }

    
}

func + (left:Heading, right:Heading) -> Heading {
    return Heading(roundedHeading: (left.roundedHeading+right.roundedHeading)%360)
}
extension Heading : Equatable {
    static func == (left:Heading, right:Heading) -> Bool {
        return left.roundedHeading == right.roundedHeading
    }
}
