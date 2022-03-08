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
    var windHeading : Heading

    var windSpeed : Speed = Speed(roundedSpeed: 10 )
    var windGust : Speed? = nil
    
    var windSource : String? = nil
    
    init( runway : Heading, wind : Heading? = nil, speed : Speed? = nil, gust : Speed? = nil){
        self.runwayHeading = runway
        self.windHeading = wind ?? runway
        self.windSpeed = speed ?? Speed(roundedSpeed: 0)
        self.windGust = gust
    }
    
    override init(){
        self.runwayHeading = Heading(roundedHeading: 240 )
        self.windHeading = Heading(roundedHeading: 190 )
        self.windSpeed = Speed(roundedSpeed: 10)
        self.windGust = nil
    }

    //MARK: - calculate
    
    var crossWindComponent :  Percent {
        return self.windHeading.crossWindComponent(with: self.runwayHeading)
    }
    
    var crossWindSpeed : Speed {
        return self.windSpeed * crossWindComponent
    }
    
    var directWindDirection : Heading.Direction {
        return self.windHeading.directDirection(to: self.runwayHeading)
    }
    
    var crossWindDirection : Heading.Direction {
        return self.windHeading.crossDirection(to: self.runwayHeading)
    }
    
    var headWindComponent : Percent {
        return self.windHeading.headWindComponent(with: self.runwayHeading)
    }
    
    var headWindSpeed : Speed {
        return self.windSpeed * self.headWindComponent
    }

    var windRunwayOffset : Heading {
        return self.windHeading.absoluteDifference(with: self.runwayHeading)
    }
    
    
    
    //MARK: - describe
    
    func enunciate(number : String) -> String{
        let chars = number.map { String($0) }
        return chars.joined(separator: " ")
    }

    var windDisplay : String {
        return "\(self.windHeading.description) @ \(self.windSpeed.description)"
    }
    
    var announce : String {
        let eHeading = self.enunciate(number: self.windHeading.description)
        let eSpeed = self.enunciate(number: self.windSpeed.description)
        if let windGust = self.windGust {
            let eGust = self.enunciate(number: windGust.description)
            return  "\(eHeading) at \(eSpeed), Gust \(eGust)"
        }else{
            return  "\(eHeading) at \(eSpeed)"
        }
    }
    
    var windcheck : String {
        return "Wind: \(self.announce)"
    }
    
    var clearance : String {
        let eRunway = self.enunciate(number: self.runwayHeading.runwayDescription)
        return "Wind: \(self.announce), Runway \(eRunway), Clear to land"
    }
    
    enum SpeechType {
        case clearance, windcheck
    }
    
    func speak( which : SpeechType = .clearance, completion : @escaping ()->Void = {}){
        
        let utterance = AVSpeechUtterance(string: which == .clearance ? self.clearance : self.windcheck )
        utterance.rate = 0.5 + (Float.random(in: 0..<10)/1000.0)
        utterance.pitchMultiplier = 0.8 + (Float.random(in: 0..<10)/1000.0)
        utterance.postUtteranceDelay = 0.2
        utterance.volume = 0.8

        
        let available = AVSpeechSynthesisVoice.speechVoices().filter {
            $0.language.starts(with: "en")
        }
        
        let voice = available[ Int.random(in: 0 ..< available.count)]
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
        let windHeading = round(runwayHeading/10)*10 + Double(windOffset * 10)
        let windSpeed = self.random(probabilities: self.speedProbabilities())
        // for gust compute % higher than wind
        let windGust = Double.random(in: 0...100)
        if( windGust > 25.0){
            self.windGust = Speed(speed: windSpeed * ( 1.0 + windGust / 100.0 ))
        }else{
            self.windGust = nil
        }
        self.windSpeed = Speed(speed: windSpeed )
        self.windHeading = Heading(heading: windHeading )
    }
    
    //MARK: - change values
    
    func opposingRunway(){
        self.runwayHeading = self.runwayHeading.opposing
    }
    
    func setupFrom(metar : Metar, airport : Airport? = nil, icao : String? = nil) {
        if let icao = icao {
            self.windSource = icao
        }
        if let airport = airport {
            self.windSource = airport.icao
        }
        self.windHeading = Heading(roundedHeading: metar.wind_direction.value)
        self.windSpeed = Speed(roundedSpeed: metar.wind_speed.value)
    }
    
    func rotateHeading(degree : Int){
        self.runwayHeading.rotate(degree: degree)
    }
    
    func updateRunwayHeading(heading : Heading){
        self.runwayHeading = heading
    }
    
    func rotateWind(degree : Int){
        self.windSource = nil
        self.windHeading.rotate(degree: degree)
    }
    
    func increaseWind(speed : Int, maximumSpeed : Int = 75){
        self.windSource = nil
        self.windSpeed.increase(speed: speed)
        self.windSpeed.cap(at: maximumSpeed)
    }
    
    //MARK:- settings
    
    func updateFromSettings(){
        self.windSpeed = Settings.shared.windSpeed
        self.windHeading = Settings.shared.windHeading
        self.runwayHeading = Settings.shared.runwayHeading
    }
    
    func saveToSettings(){
        Settings.shared.windSpeed = self.windSpeed
        Settings.shared.windHeading = self.windHeading
        Settings.shared.runwayHeading = self.runwayHeading
        
    }
}

extension RunwayWindModel : AVSpeechSynthesizerDelegate {
    @objc func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        self.completion()
    }
}
