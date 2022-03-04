//
//  HeadingIndicatorView.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit

extension NSString {
    func draw(centeredAt center : CGPoint, angle : CGFloat, withAttribute attr: [NSAttributedString.Key : Any]?){
        if let context = UIGraphicsGetCurrentContext() {
            let size : CGSize = self.size(withAttributes: attr )
            let translation :CGAffineTransform = CGAffineTransform(translationX: center.x, y: center.y)
            let rotation : CGAffineTransform = CGAffineTransform(rotationAngle: angle)
            context.concatenate(translation)
            context.concatenate(rotation)
            
            let drawPoint = CGPoint(x: size.width / 2.0 * -1.0, y: size.height / 2.0 * -1.0)
            self.draw(at: drawPoint, withAttributes: attr)
            
            context.concatenate(rotation.inverted())
            context.concatenate(translation.inverted())
        }
    }
    
    static func mergeAttribute(attr : [NSAttributedString.Key:Any]?, with : [NSAttributedString.Key:Any] ) -> [NSAttributedString.Key:Any]{
        if var attr = attr {
            attr.merge(with, uniquingKeysWith: { return $1 })
            return attr
        }else{
            return with
        }
    }
}

extension CGFloat {
    var radianFromDegree : CGFloat { return self * .pi / 180.0 }
    var degreeFromRadian : CGFloat { return self / .pi * 180.0 }
}

extension CGPoint {
    func distance(to : CGPoint) -> CGFloat {
        let square = (to.x - self.x) * (to.x - self.x) + (to.y - self.y) * (to.y - self.y)
        return sqrt(square)
    }
    
    var rounded : CGPoint { return CGPoint(x: round(self.x), y: round(self.y)) }
    
    /**
     *  angle with 0 on x axis, positive for y negative to 180, negative for y positive to 180
     */
    func angle(to : CGPoint) -> CGFloat {
        return atan2(to.y-self.y,to.x-self.x).degreeFromRadian
    }
}

class HeadingIndicatorView: UIView {
    enum DisplayWind {
        case hidden
        case wind
        case windAndGust
        
        var enabled : Bool { return self != .hidden }
    }
    
    enum DisplayCrossWindComponent {
        case hidden
        case speed
        case hint
        
        var enabled : Bool { return self != .hidden }
    }
    
    var model : RunwayWindModel = RunwayWindModel()
    var displayWind : DisplayWind = .wind
    var displayCrossWind : DisplayCrossWindComponent = .hidden
    var geometry : HeadingIndicatorGeometry = HeadingIndicatorGeometry(rect: CGRect.zero, heading: 0.0)

    var circleColor : UIColor = UIColor.label
    var compassPointColor : UIColor = UIColor.label
    var windConeColor : UIColor = UIColor.systemRed
    var labelAttribute : [NSAttributedString.Key : Any]? = nil
        
    // for now keep heading and runway consistent
    private var heading : CGFloat { CGFloat(self.model.runwayHeading.heading)}
    private var windHeading : CGFloat { return self.model.windHeading.heading }
    private var windSpeed : CGFloat { return self.model.windSpeed.speed }
    private var windSizePercent : CGFloat { min(50.0,max(10.0, windSpeed)) }
    
    //MARK: - draw elements
    
    func drawRunway(_ rect : CGRect){
        let center = geometry.center

        let runwayTargetWidth = geometry.baseRadius * 0.25
        let runwayTargetLength = geometry.baseRadius * 0.4

        // Fit center line + 3 stripe in each side:  stripes or 16 units (stripe + space) + 1 for left
        let stripeEachSideCount : Int = 3
        // how many unit of stripe space to fit
        let stripeSpaceUnitcount : Int = (2/*two sides*/ * 2/*stripe + space*/ * stripeEachSideCount + 2 /*centerline*/ + 1 /*first offset*/)
        let stripeWidth : CGFloat = ceil(runwayTargetWidth / CGFloat(stripeSpaceUnitcount) )
        let stripeOffset : CGFloat = stripeWidth // same as stripe

        let runwayWidth = CGFloat(stripeSpaceUnitcount) * stripeWidth

        let centerLineStripeCount = 5
        // space between line is XX percent of centerline height
        let centerLineOffsetPercent = 20.0
        let stripeHeight = ceil(runwayTargetLength / CGFloat(centerLineStripeCount) * ( 1.0 - centerLineOffsetPercent / 100.0))
        let stripeHeightOffset = stripeHeight * centerLineOffsetPercent / 100.0
        
        let runwayLength = (stripeHeight + stripeHeightOffset) * CGFloat(centerLineStripeCount) + stripeHeightOffset

        let runwayTopLeft  = CGPoint(x: center.x - runwayWidth/2.0 , y: center.y-runwayLength/2.0)
        let runwayTopRight = CGPoint(x: center.x + runwayWidth/2.0 , y: center.y-runwayLength/2.0)

        let runwayBottomLeft  = CGPoint(x: center.x - runwayWidth/2.0 , y: center.y+runwayLength/2.0)
        let runwayBottomRight = CGPoint(x: center.x + runwayWidth/2.0 , y: center.y+runwayLength/2.0)

        let path = UIBezierPath()
        path.move(to: runwayTopLeft)
        path.addLine(to: runwayBottomLeft)
        path.addLine(to: runwayBottomRight)
        path.addLine(to: runwayTopRight)
        path.stroke()

        // Center Line
        let centerLineWidth = 1.0
        let x = center.x - centerLineWidth / 2.0
        
        for i in 2..<centerLineStripeCount {
            let y = runwayBottomLeft.y - CGFloat(i+1) * (stripeHeightOffset + stripeHeight)
            let centerLineRect = CGRect(x: x, y: y, width: centerLineWidth, height: stripeHeight)
            let stripePath = UIBezierPath(roundedRect: centerLineRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0.0, height: 0.0))
            stripePath.fill()
        }
        
        let runwayNumber = "\(Int(round(heading/10.0)))" as NSString
        let numberCenter = CGPoint(x: runwayBottomLeft.x + runwayWidth/2.0,
                                   y: runwayBottomLeft.y -  (2*stripeHeightOffset + stripeHeight * 1.5) )
        runwayNumber.draw(centeredAt: numberCenter, angle: 0, withAttribute: self.labelAttribute)
        
        // Each Side Stripe
        for i in 0..<(2*stripeEachSideCount+1) {
            // left side
            for (xbase,xmult) : (CGFloat,Double) in [(runwayBottomLeft.x,1.0)/*, (runwayBottomRight.x-stripeOffset, -1.0)*/] {
                let x = xbase + xmult * (stripeOffset + CGFloat(i) * (stripeWidth+stripeOffset));
                let stripeRect = CGRect(x: x, y: runwayBottomLeft.y-stripeHeightOffset-stripeHeight, width: stripeWidth, height: stripeHeight)
                let stripePath = UIBezierPath(roundedRect: stripeRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0.0, height: 0.0))
                stripePath.fill()
            }
        }
        
        // Landing Stripe
        let y = runwayBottomLeft.y - (stripeHeightOffset + (stripeHeightOffset + stripeHeight) * 3.5)
        
        for i in [-1,1] {
            let x = center.x +  2 * stripeOffset * CGFloat(i) - stripeOffset/2.0
            let stripeRect = CGRect(x: x, y: y, width: stripeWidth, height: stripeHeight)
            let stripePath = UIBezierPath(roundedRect: stripeRect, byRoundingCorners: .allCorners, cornerRadii: CGSize(width: 0.0, height: 0.0))
            stripePath.fill()
        }
    }
    
    func drawCompass(_ rect : CGRect){
        let outCircle  = UIBezierPath(arcCenter: geometry.center, radius: geometry.baseRadius,
                                      startAngle: 0.0,
                                      endAngle: .pi * 2.0,
                                      clockwise: true)
        
        self.circleColor.setStroke()
        outCircle.stroke()
        
        
        let cardinalPoint : [String] = ["N", "E", "S", "W"]
        
        for headingPoint in 0..<36 {
            let angle : CGFloat = CGFloat(headingPoint) * 10.0
            
            var label : String? = nil
            var length : CGFloat = geometry.smallLength
            var width : CGFloat = geometry.smallWidth
            
            if headingPoint % 9 == 0 {
                length = geometry.regularLength
                width = geometry.regularWidth
                label = cardinalPoint[ headingPoint/9 ]
            }
            else if headingPoint % 3 == 0 {
                length = geometry.regularLength
                width = geometry.regularWidth
                label = "\(headingPoint)"
            }else{
                label = ""
            }
            
            let radiusStart = geometry.baseRadius - length
            let radiusEnd = geometry.baseRadius
  
            let startPoint = geometry.point(angle: angle, radius: radiusStart)
            let endPoint = geometry.point(angle: angle, radius: radiusEnd)
            
            let tick = UIBezierPath()
            tick.lineWidth = width
            tick.move(to: startPoint)
            tick.addLine(to: endPoint)
            tick.close()
            tick.stroke()
            
            if let label = label {
                let string = label as NSString
                let size = string.size(withAttributes: self.labelAttribute)
                let textAngle = geometry.viewCoordinateAngle(heading: angle) + 90.0
                let textPoint = geometry.point(angle: angle, radius: radiusStart - geometry.textMargin - size.height/2.0  )
                string.draw(centeredAt: textPoint, angle: textAngle.radianFromDegree, withAttribute: self.labelAttribute)
            }
            
            let headingString = "\(Int(round(geometry.heading)))" as NSString
            let headingSize = headingString.size(withAttributes: self.labelAttribute)

            let headLength : CGFloat = geometry.headingHeadLength
            let headWidth : CGFloat = 10.0

            let headingPoint = geometry.point(angle: heading, radius: geometry.baseRadius + headLength + geometry.textMargin + headingSize.height / 2.0)
            
            self.drawCone(degree: self.heading, width: headWidth, radiusHead: geometry.baseRadius, headLength: headLength, shaftLength: 0.0,
                          strokeColor: self.compassPointColor, fillColor: self.compassPointColor)
            
            headingString.draw(centeredAt: headingPoint, angle: 0, withAttribute: self.labelAttribute)
            
        }
    }
        
    func drawWindCone(_ rect : CGRect){
        if self.displayWind.enabled {
            // Compute first as cheat to estimate height to go below heading string
            let windHeadingString = "\(Int(round(windHeading))) @ \(Int(round(windSpeed)))" as NSString
            let windHeadingSize = windHeadingString.size(withAttributes: self.labelAttribute)

            let windStartRadius = geometry.windStartRadius(speed: self.windSpeed )
            let windEndRadius = geometry.baseRadius
            
            let coneWidth : CGFloat = geometry.windWidth(speed: self.windSpeed )
            
            self.drawCone(degree: windHeading,
                          width: coneWidth,
                          radiusHead: windStartRadius-geometry.headLength,
                          headLength: geometry.headLength,
                          shaftLength: windEndRadius-windStartRadius+geometry.headingHeadLength,
                          strokeColor: self.windConeColor, fillColor: self.windConeColor)
            
            let textAngle = geometry.viewCoordinateAngle(heading: windHeading) + 90.0

            let windHeadingPoint = geometry.point(angle: windHeading, radius: windStartRadius - geometry.headLength - geometry.textMargin - windHeadingSize.height/2.0)
            
            windHeadingString.draw(centeredAt: windHeadingPoint, angle: textAngle.radianFromDegree, withAttribute: self.labelAttribute)
            
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.geometry = HeadingIndicatorGeometry(rect: rect, heading: self.heading)
        
        self.drawCompass(rect)
        self.drawWindCone(rect)
        self.drawRunway(rect)
    }
    
    //MARK: - element check
    
    /**
        return angle if in circle, nil otherwise
     */
    func headingInCircle(point : CGPoint) -> CGFloat? {
        let distance = point.distance(to: geometry.center)
        if distance > (geometry.baseRadius * 0.95 - geometry.margin ) {
            return self.heading(point: point)
        }
        return nil
    }

    func headingInWindCone(point : CGPoint) -> CGFloat? {
        if displayWind.enabled {
            let heading = self.heading(point: point)
            if abs( heading - windHeading ) < 10 {
                return heading
            }
        }
        return nil
    }

    
    func heading(point : CGPoint) -> CGFloat {
        let angle = geometry.center.angle(to: point)
        // + 90 to rotate north up, +360 to get rid of negative with the modulo and plus heading to rotate
        return (angle + 90.0 + 360.0 + self.heading).truncatingRemainder(dividingBy: 360.0)
    }

    func rotateHeading(degree : CGFloat){
        // minus sign because rotation in screen is opposite
        self.model.rotateHeading(degree: -Int(degree))
    }
    
    func rotateWind(degree : CGFloat){
        if displayWind.enabled {
            //self.model.windHeading.rotate(degree: Int(degree))
            self.model.rotateWind(degree: Int(degree))
        }
    }
    
    func increaseWindSpeed(percent : CGFloat){
        // for now just
        self.model.increaseWind(speed: Int(percent))
        //self.model.windSpeed.increase(speed: Int(percent))
    }
    
    func radius(point : CGPoint) -> CGFloat {
        return geometry.center.distance(to: point)
    }
    
    func radiusPercent(point : CGPoint) -> CGFloat {
        return geometry.center.distance(to: point) / geometry.baseRadius * 100.0
    }

    
    //MARK: - draw helper
    
    /// Draw a cone
    /// - Parameters:
    ///   - degree: degree (in heading degree)
    ///   - width: in degree
    ///   - radiusHead: radius at end of point of head
    ///   - headLength: size of the head
    ///   - shaftLength: size of shaft (total size is headLength + shaftLength
    ///   - strokeColor: color for outside stroke
    ///   - fillColor: fill color wil be with 50% alpha
    func drawCone(degree : CGFloat, width : CGFloat, radiusHead : CGFloat, headLength : CGFloat, shaftLength : CGFloat, strokeColor : UIColor = .label, fillColor : UIColor = .systemFill) {
        let angleCenter = degree
        let angleLeft = angleCenter - (width / 2.0 )
        let angleRight = angleCenter + (width / 2.0 )

        let shaftStartRadius = radiusHead + headLength
        let shaftEndRadius = shaftStartRadius + shaftLength

        let leftTopShaftPoint = geometry.point(angle: angleLeft, radius: shaftEndRadius)
        let rightTopShaftPoint = geometry.point(angle: angleRight, radius: shaftEndRadius)
        
        let leftBottomShaftPoint = geometry.point(angle: angleLeft, radius: shaftStartRadius)
        let rightBottomShaftPoint = geometry.point(angle: angleRight, radius: shaftStartRadius)
        
        let centerBottomHeadPoint = geometry.point(angle: angleCenter, radius: radiusHead)
        
        let cone = UIBezierPath()
        cone.move(to: leftTopShaftPoint)
        cone.addLine(to: rightTopShaftPoint)
        cone.addLine(to: rightBottomShaftPoint)
        cone.addLine(to: centerBottomHeadPoint)
        cone.addLine(to: leftBottomShaftPoint)
        cone.close()
        
        strokeColor.setStroke()
        cone.stroke()
        fillColor.setFill()
        cone.fill(with: .darken, alpha: 0.5)
    }
    

    
}
