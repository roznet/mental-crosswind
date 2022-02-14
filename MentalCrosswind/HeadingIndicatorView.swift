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
    var heading : CGFloat = 0.0 { didSet { self.geometry.heading = heading } }
    var windHeading : CGFloat? = 190.0
    var windSpeed : CGFloat = 20.0
    var windSizePercent : CGFloat { min(50.0,max(10.0, windSpeed)) }

    var geometry : HeadingIndicatorGeometry = HeadingIndicatorGeometry(rect: CGRect.zero, heading: 0.0)
    
    /**
     Margin of the circle from view rect
     */
    var margin : CGFloat = 15.0
    let textMargin : CGFloat = 0.0
    
    var circleColor : UIColor = UIColor.label
    var compassPointColor : UIColor = UIColor.label
    
    var windConeColor : UIColor = UIColor.systemRed
    
    var labelAttribute : [NSAttributedString.Key : Any]? = nil
        
    
    //MARK: - draw elements
    
    func drawRunway(_ rect : CGRect){
        
    }
    
    func drawCompass(_ rect : CGRect){
        let outCircle  = UIBezierPath(arcCenter: geometry.center, radius: geometry.baseRadius,
                                      startAngle: 0.0,
                                      endAngle: .pi * 2.0,
                                      clockwise: true)
        
        self.circleColor.setStroke()
        outCircle.stroke()
        
        let smallLength : CGFloat = 5.0
        let regularLength : CGFloat = 10.0
        let smallWidth : CGFloat = 1.0
        let regularWidth : CGFloat = 2.0
        
        
        
        let cardinalPoint : [String] = ["N", "E", "S", "W"]
        
        for headingPoint in 0..<36 {
            var label : String? = nil
            var length : CGFloat = smallLength
            var width : CGFloat = smallWidth
            if headingPoint % 9 == 0 {
                length = regularLength
                width = regularWidth
                label = cardinalPoint[ headingPoint/9]
            }
            else if headingPoint % 3 == 0 {
                length = regularLength
                width = regularWidth
                label = "\(headingPoint)"
            }else{
                label = ""
            }
            
            let radiusStart = geometry.baseRadius * ( 1.0 - ( length / 100.0) )
            let radiusEnd = geometry.baseRadius
            let angle : CGFloat = CGFloat(headingPoint) * 10.0
  
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
                let textPoint = geometry.point(angle: angle, radius: radiusStart - size.height - textMargin )
                string.draw(centeredAt: textPoint, angle: textAngle.radianFromDegree, withAttribute: self.labelAttribute)
            }
            
            
            let headingString = "\(Int(round(geometry.heading)))" as NSString
            let headingSize = headingString.size(withAttributes: self.labelAttribute)

            let headLength : CGFloat = headingSize.height
            let headWidth : CGFloat = 10.0

            let headingPoint = geometry.point(angle: heading, radius: geometry.baseRadius + headLength + textMargin + headingSize.height / 2.0)
            
            self.drawCone(degree: self.heading, width: headWidth, radiusHead: geometry.baseRadius, headLength: headLength, shaftLength: 0.0,
                          strokeColor: self.compassPointColor, fillColor: self.compassPointColor)
            
            headingString.draw(centeredAt: headingPoint, angle: 0, withAttribute: self.labelAttribute)
            
        }
    }
        
    func drawWindCone(_ rect : CGRect){
        
        let coneSize : CGFloat = 10.0
        if let windHeading = windHeading {
            // Compute first as cheat to estimate height to go below heading string
            let windHeadingString = "\(Int(round(windHeading)))" as NSString
            let windHeadingSize = windHeadingString.size(withAttributes: self.labelAttribute)

            let windStartRadius = geometry.baseRadius * ( 1.0 - self.windSizePercent / 100.0 )
            let windEndRadius = geometry.baseRadius + margin
            
            self.drawCone(degree: windHeading, width: coneSize, radiusHead: windStartRadius, headLength: margin, shaftLength: windEndRadius-windStartRadius, strokeColor: self.windConeColor, fillColor: self.windConeColor)
            
            let textAngle = geometry.viewCoordinateAngle(heading: windHeading) + 90.0

            let windHeadingPoint = geometry.point(angle: windHeading, radius: windStartRadius - textMargin - windHeadingSize.height/2.0)
            
            windHeadingString.draw(centeredAt: windHeadingPoint, angle: textAngle.radianFromDegree, withAttribute: self.labelAttribute)
            
        }
    }
    
    override func draw(_ rect: CGRect) {
        self.geometry = HeadingIndicatorGeometry(rect: rect, heading: self.heading)
        self.geometry.margin = self.margin
        
        self.drawCompass(rect)
        self.drawWindCone(rect)
    }
    
    //MARK: - element check
    
    /**
        return angle if in circle, nil otherwise
     */
    func headingInCircle(point : CGPoint) -> CGFloat? {
        let distance = point.distance(to: geometry.center)
        if distance > (geometry.baseRadius * 0.95 - self.margin ) {
            return self.heading(point: point)
        }
        return nil
    }

    func headingInWindCone(point : CGPoint) -> CGFloat? {
        if let windHeading = windHeading {
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
        self.heading = (self.heading - degree + 360.0).truncatingRemainder(dividingBy: 360.0)
    }
    
    func rotateWind(degree : CGFloat){
        if let windHeading = windHeading {
            self.windHeading = (windHeading + degree + 360.0).truncatingRemainder(dividingBy: 360.0)
        }
    }
    
    func increaseWindSpeed(percent : CGFloat){
        // for now just
        self.windSpeed = max(0,percent+windSpeed)
    }
    
    func radius(point : CGPoint) -> CGFloat {
        return geometry.center.distance(to: point)
    }
    func radiusPercent(point : CGPoint) -> CGFloat {
        return geometry.center.distance(to: point) / geometry.baseRadius * 100.0
    }

    
    //MARK: - draw helper
    
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
