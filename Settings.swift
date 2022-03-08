//
//  Settings.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import Foundation

class Settings {
    
    static let defaultIcao : String = "EGLL"
    static let defaultUpdateMethod : UpdateMethod = .none
    static let defaultRunway : Int = 24
    
    enum UpdateMethod : String {
        case custom = "custom"
        case nearest = "nearest"
        case none = "none"
    }
    
    enum Key : String {
        case airport_icao = "default-airport-icao"
        case update_method = "default-update-method"
        case runway = "default-runway"
        case wind_speed = "last-wind-speed"
        case wind_direction = "last-wind-direction"
        case last_runway = "last-runway"
        case analysis_is_displayed = "analysis-is-displayed"
    }
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.airport_icao.rawValue  : Self.defaultIcao,
            Key.update_method.rawValue : Self.defaultUpdateMethod.rawValue,
            Key.runway.rawValue        : Self.defaultRunway,
            Key.wind_speed.rawValue    : 10,
            Key.wind_direction.rawValue : (Self.defaultRunway * 10 + 10) % 360
        ])
    }
    
    var analysisIsDisplayed : Bool {
        get {
            let rv = UserDefaults.standard.bool(forKey: Key.analysis_is_displayed.rawValue)
            return rv
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.analysis_is_displayed.rawValue)
        }
    }
    
    var airportIcao : String {
        get {
            if let rv = UserDefaults.standard.string(forKey: Key.airport_icao.rawValue) {
                return rv
            }else{
                return Self.defaultIcao
            }
        }
        set {
            UserDefaults.standard.set(newValue, forKey: Key.airport_icao.rawValue)
        }
    }
    
    var updateMethod : UpdateMethod {
        get {
            if let rawMethod = UserDefaults.standard.string(forKey: Key.update_method.rawValue),
               let method = UpdateMethod(rawValue: rawMethod){
                return method
            }else{
                return Self.defaultUpdateMethod
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.update_method.rawValue)
        }
    }
    
    func heading(key : Key) -> Heading{
        let val = UserDefaults.standard.integer(forKey: key.rawValue)
        return Heading(roundedHeading: val)
    }
    
    func setHeading(key : Key, heading : Heading){
        UserDefaults.standard.set(heading.roundedHeading, forKey: key.rawValue)
    }
    
    func speed(key : Key) -> Speed {
        let val = UserDefaults.standard.integer(forKey: key.rawValue)
        return Speed(roundedSpeed: val)
    }
    
    func setSpeed(key : Key, speed : Speed){
        UserDefaults.standard.set(speed.roundedSpeed, forKey: key.rawValue)
    }
    
    static var shared : Settings = Settings()
    
    private init(){
    }
}
