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
    var margin : CGFloat
    
    var baseRadius : CGFloat { return maxRadius - margin }
    
    /**
     * Will return the angle in screen coordinate for given heading inside the geometry
     * for example if heading is 0 (north up), East (90) should be 0.0 in screen coordinate
     */
    func viewCoordinateAngle(heading from: CGFloat) -> CGFloat {
        return ((from - heading) - 90.0 + 360.0).truncatingRemainder(dividingBy: 360.0)
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
        self.margin = 0.0
        self.heading = heading
    }
}
