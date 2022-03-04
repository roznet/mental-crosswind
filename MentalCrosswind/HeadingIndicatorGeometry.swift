//
//  HeadingIndicatorGeometry.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 14/02/2022.
//

import Foundation
import UIKit

struct HeadingIndicatorGeometry {
    let center : CGPoint
    let rect : CGRect
    let maxRadius : CGFloat

    var heading : CGFloat
    var margin : CGFloat { return maxRadius * 0.10 }
    
    /// rotation in degree 0.0 is due north, positive rotation right, negative rotate left
    var rotationAngle : CGFloat = 0.0
    
    /*
     * Configuration for size of tick on the compass
     */
    var smallLength : CGFloat { return baseRadius *  0.05 }
    var regularLength : CGFloat { return baseRadius *  0.1 }
    let smallWidth : CGFloat = 1.0
    let regularWidth : CGFloat = 2.0

    var headLength : CGFloat { return baseRadius * 0.15 }
    var headingHeadLength : CGFloat { return baseRadius * 0.1 }
    var textMargin : CGFloat { return baseRadius * 0.01 }

    var baseRadius : CGFloat { return maxRadius - margin }
    
    var windMinRadius : CGFloat { return baseRadius - regularLength - textMargin }
    var windMaxRadius : CGFloat { return baseRadius * 0.5 }
    
    var runwayTargetWidth : CGFloat { return baseRadius * 0.25 }
    var runwayTargetLength : CGFloat { return baseRadius * 0.4 }
    
    func windStartRadius(speed : CGFloat ) -> CGFloat {
        let minRadiusSpeed : CGFloat = 0.0
        let maxRadiusSpeed : CGFloat = 50.0
        
        let speedRadius : CGFloat = self.windMinRadius + (speed - minRadiusSpeed)/(maxRadiusSpeed - minRadiusSpeed) * (self.windMaxRadius-self.windMinRadius)
        
        let rv = min( self.windMinRadius, max( self.windMaxRadius, speedRadius) )
        return rv
    }
    
    /**
     * return width of cone in degrees
     */
    func windWidth(speed : CGFloat) -> CGFloat {
        return 10.0
    }
    
    /**
     * Will return the angle in screen coordinate for given heading inside the geometry
     * for example if heading is 0 (north up), East (90) should be 0.0 in screen coordinate
     */
    func viewCoordinateAngle(heading from: CGFloat) -> CGFloat {
        return ((from - heading + rotationAngle) - 90.0 + 360.0).truncatingRemainder(dividingBy: 360.0)
    }

    func point(angle : CGFloat, radius : CGFloat) -> CGPoint {
        let adjustedAngle = self.viewCoordinateAngle(heading: angle)
        let x : CGFloat = self.center.x + __cospi( adjustedAngle / 180.0 ) * radius
        let y : CGFloat = self.center.y + __sinpi( adjustedAngle / 180.0 ) * radius
        return CGPoint(x: x, y: y)
    }
    
    init(rect : CGRect, heading : CGFloat) {
        self.rect = rect
        self.center = CGPoint(x: rect.origin.x + rect.size.width/2.0, y: rect.origin.y + rect.size.height/2.0)
        self.maxRadius = 0.5 * min(rect.size.width, rect.size.height)
        self.heading = heading
    }
}
