//
//  HeadingIndicatorView.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import UIKit

extension NSString {
    func draw(centeredAt center : CGPoint, angle : CGFloat, withAttribute attr: [NSAttributedString.Key : Any]?){
        let size : CGSize = self.size(withAttributes: attr )
        if let context = UIGraphicsGetCurrentContext() {
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
}

class HeadingIndicatorView: UIView {
    var heading : CGFloat = 240.0
    
    var northUp : Bool = false
    
    var circleColor : UIColor = UIColor.label
    var compassPointColor : UIColor = UIColor.label
    
    var labelAttribute : [NSAttributedString.Key : Any]? = nil
    
    func angle(degree : Float) -> Float {
        if( self.northUp ){
            return degree - 90.0
        }else{
            return (degree - Float(heading)).truncatingRemainder(dividingBy: 360.0) - 90.0
        }
    }
    
    override func draw(_ rect: CGRect) {
        let center : CGPoint = CGPoint(x: rect.origin.x + rect.size.width/2.0, y: rect.origin.y + rect.size.height/2.0)
        let radius : CGFloat = 0.5 * min(rect.size.width, rect.size.height)
        
        let outCircle  = UIBezierPath(arcCenter: center, radius: radius, startAngle: 0.0, endAngle: .pi * 2.0
                                      , clockwise: true)
        
        self.circleColor.setStroke()
        outCircle.stroke()
        
        let smallLength : CGFloat = 5.0
        let regularLength : CGFloat = 10.0
        let smallWidth : CGFloat = 1.0
        let regularWidth : CGFloat = 2.0
        
        let textMargin : CGFloat = 0.0
        
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
            
            let radiusStart = radius * ( 1.0 - ( length / 100.0) )
            let radiusEnd = radius
            let angleDegree =  self.angle(degree: Float(headingPoint) * 10.0 )
            let angleRadian : Float = angleDegree * .pi / 180.0
            
            let startPoint = CGPoint(x: center.x + CGFloat(cosf(angleRadian)) * radiusStart,
                                     y: center.y + CGFloat(sinf(angleRadian)) * radiusStart)
            let endPoint = CGPoint(x: center.x + CGFloat(cosf(angleRadian)) * radiusEnd,
                                   y: center.y + CGFloat(sinf(angleRadian)) * radiusEnd)
            
            let tick = UIBezierPath()
            tick.lineWidth = width
            tick.move(to: startPoint)
            tick.addLine(to: endPoint)
            tick.close()
            tick.stroke()
            
            if let label = label {
                let string = label as NSString
                let size = string.size(withAttributes: self.labelAttribute)
                let textAngle = angleRadian + (.pi / 2.0)
                let textPoint = CGPoint(x: startPoint.x - CGFloat(cosf(angleRadian)) * ( size.height + textMargin),
                                        y: startPoint.y - CGFloat(sinf(angleRadian)) * ( size.height + textMargin))
                string.draw(centeredAt: textPoint, angle: CGFloat(textAngle), withAttribute: self.labelAttribute)
            }
        }
        
        /*

        UIBezierPath * outCircle = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:0.0 endAngle:M_PI*2.0 clockwise:YES];
        [outCircle stroke];

        [[[UIColor darkGrayColor] colorWithAlphaComponent:0.7] setStroke];
        CGFloat innerRadius = radius * 0.3;
        for (NSInteger i=0; i<16.; i++) {
            CGFloat angleFrom = 2.0 * M_PI * i / 16.;
            CGFloat angleTo   = 2.0 * M_PI * (i+1)/16.;

            CGFloat angleEnd = angleTo;
            if (i%2==0) {
                angleEnd = angleFrom;
            }
            CGFloat radiusEnd = radius;
            if (i%4==1 || i%4==2) {
                radiusEnd = radius * 0.6;
            }
            CGPoint pointEnd = CGPointMake(center.x+ cosf(angleEnd) * radiusEnd, center.y+ sinf(angleEnd) * radiusEnd);
            UIBezierPath * innerAngle = [UIBezierPath bezierPathWithArcCenter:center radius:innerRadius  startAngle:angleFrom endAngle:angleTo clockwise:YES];
            [innerAngle addLineToPoint:pointEnd];
            [innerAngle closePath];
            [innerAngle stroke];
        }

        // Wind
        CGFloat usePercent = MAX(self.percent, 0.40);
        CGFloat windAngleFrom = self.direction - M_PI/8.*usePercent;
        CGFloat windAngleTo   = self.direction + M_PI/8.*usePercent;

        CGFloat windRadiusEnd = radius * (1. - usePercent);
        CGPoint windPointEnd = CGPointMake(center.x+cosf(self.direction)*windRadiusEnd, center.y + sinf(self.direction)*windRadiusEnd);
        UIBezierPath * windCone = [UIBezierPath bezierPathWithArcCenter:center radius:radius startAngle:windAngleFrom endAngle:windAngleTo clockwise:YES];
        [windCone addLineToPoint:windPointEnd];
        [windCone closePath];
        [[[UIColor redColor] colorWithAlphaComponent:0.6] setFill];
        [windCone fill];
         */
    }

}
