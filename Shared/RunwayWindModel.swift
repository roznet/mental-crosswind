//
//  XCWindModel.swift
//  xwind
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import Foundation
import AVFoundation

@objc class RunwayWindModel : NSObject {
    private var completion : ()->Void = {}
    var synthetizer : AVSpeechSynthesizer? = nil
    
    var runwayHeading : Heading
    var windDirection : Heading

    var windSpeed : Speed = Speed(roundedSpeed: 10 )
    var windGust : Speed? = nil
    
    init( runway : Heading, wind : Heading? = nil, speed : Speed? = nil, gust : Speed? = nil){
        self.runwayHeading = runway
        self.windDirection = wind ?? runway
        self.windSpeed = speed ?? Speed(roundedSpeed: 0)
        self.windGust = gust
    }
    
    override init(){
        self.runwayHeading = Heading(roundedHeading: 240 )
        self.windDirection = Heading(roundedHeading: 190 )
        self.windSpeed = Speed(roundedSpeed: 10)
        self.windGust = nil
    }

    //MARK: - describe
    
    func enunciate(number : String) -> String{
        let chars = number.map { String($0) }
        return chars.joined(separator: " ")
    }

    var announce : String {
        let eDirection = self.enunciate(number: self.windDirection.description)
        let eSpeed = self.enunciate(number: self.windSpeed.description)
        if let windGust = self.windGust {
            let eGust = self.enunciate(number: windGust.description)
            return  "Wind: \(eDirection) at \(eSpeed), Gust \(eGust)"
        }else{
            return  "Wind: \(eDirection) at \(eSpeed)"
        }
    }
    
    var clearance : String {
        let eRunway = self.enunciate(number: self.runwayHeading.runwayDescription)
        return "\(self.announce), Runway \(eRunway), Clear to land"
    }
    
    func speak( completion : @escaping ()->Void = {}){
        let utterance = AVSpeechUtterance(string: self.clearance )
        utterance.rate = 0.5 + (Float.random(in: 0..<10)/1000.0)
        utterance.pitchMultiplier = 0.8 + (Float.random(in: 0..<10)/1000.0)
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8

        
        let available = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.starts(with: "en")
        }
        
        let voice = available[ Int.random(in: 0 ..< available.count)]
        print( voice )
        utterance.voice = voice
        self.synthetizer = AVSpeechSynthesizer()
        self.completion = completion
        synthetizer?.delegate = self
        synthetizer?.speak(utterance)
    }

    //MARK: - generate
    
    func speedProbabilities() -> [Double] {
        var probabilities : [Double] = []
        
        for _ in 0 ..< 5 {
            probabilities.append(5.0)
        }
        for _ in 5 ..< 20 {
            probabilities.append(10.0)
        }
        for _ in 20 ..< 50 {
            probabilities.append(1.0)
        }
        return probabilities
    }
    
    /**
     * return random number from 0 to probabilities.count each number with probability in array probabilities
     */
    func random(probabilities : [Double]) -> Double {
        let total = probabilities.reduce(0, +)
        let uniform = Double.random(in: 0 ..< total)
        var running : Double = 0.0
        
        for (value,probability) in probabilities.enumerated() {
            running += probability
            if uniform < running {
                return Double(value)
            }
        }
        
        return Double(probabilities.count - 1)
    }
    
    func randomizeWind() {
        let windOffset = Int.random(in: -9...9)
        let runwayHeading = runwayHeading.heading
        let windDirection = runwayHeading + Double(windOffset * 10)
        let windSpeed = self.random(probabilities: self.speedProbabilities())
        // for gust compute % higher than wind
        let windGust = Double.random(in: 0...100)
        if( windGust > 25.0){
            self.windGust = Speed(speed: windSpeed * ( 1.0 + windGust / 100.0 ))
        }else{
            self.windGust = nil
        }
        self.windSpeed = Speed(speed: windSpeed )
        self.windDirection = Heading(heading: windDirection )
    }
    
    //MARK: - Analyse

    func hint() -> String {
        let xwind = self.runwayHeading.absoluteDifference(with: self.windDirection)
        let xcomponent = Int(round(self.runwayHeading.crossComponentPercent(with: self.windDirection)*100.0))
        
        let memo = [ (15,25), (30,50), (45,75), (60,100)]
        if let closest = memo.enumerated().min(by: { abs( $0.1.0 - xwind.roundedHeading ) < abs( $1.1.0 - xwind.roundedHeading ) }) {
            return "\(xwind.description)deg proxy=\(closest.element.0)deg Cross=\(closest.element.1)% "
        }else{
            return "\(xwind.description)deg Cross=\(xcomponent)% "
        }
    }

    
    func analyseHint() -> String {
        let xwind = self.runwayHeading.absoluteDifference(with: self.windDirection)
        let xcomponent = Int(round(self.runwayHeading.crossComponentPercent(with: self.windDirection)*100.0))
        let direct = Int(round(self.runwayHeading.directComponentPercent(with: self.windDirection)*100.0))
        
        return "\(xwind.description)deg Cross=\(xcomponent)% Head=\(direct)%"
    }
    
    func analyse() -> String {
        let xwind = self.runwayHeading.absoluteDifference(with: self.windDirection)
        let xcomponent = Int(round(self.runwayHeading.crossComponentPercent(with: self.windDirection) * self.windSpeed.speed) )
        let direct = Int(round(self.runwayHeading.directComponentPercent(with: self.windDirection) * self.windSpeed.speed))
        let from = self.runwayHeading.direction(to: self.windDirection)
        
        return "\(xwind.description)deg \(from)  Cross=\(xcomponent)kts Head=\(direct)kts"
    }
    
    //MARK: - change values
    func rotateHeading(degree : Int){
        self.runwayHeading.rotate(degree: degree)
    }
    
    func rotateWind(degree : Int){
        self.windDirection.rotate(degree: degree)
    }
    
    func increaseWind(speed : Int, maximumSpeed : Int = 75){
        self.windSpeed.increase(speed: speed)
        self.windSpeed.cap(at: maximumSpeed)
    }
    
}

extension RunwayWindModel : AVSpeechSynthesizerDelegate {
    @objc func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        print( "Called" )
        self.completion()
    }
}
