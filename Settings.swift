//
//  Settings.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 04/03/2022.
//

import Foundation

@propertyWrapper
struct UserStorage<Type> {
    private let key : String
    private let defaultValue : Type
    init(key : String, defaultValue : Type){
        self.key = key
        self.defaultValue = defaultValue
    }
    
    var wrappedValue : Type {
        get {
            UserDefaults.standard.object(forKey: key) as? Type ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}


class Settings {
    
    static let defaultIcao : String = "EGLL"
    static let defaultUpdateMethod : UpdateMethod = .none
    static let defaultRunway : Int = 240
    
    enum UpdateMethod : String {
        case custom = "custom"
        case nearest = "nearest"
        case none = "none"
    }
    
    enum StartingMode : String {
        case practice = "practice"
        case analysis = "analysis"
        case last = "last"
    }
    
    enum Key : String {
        case airport_icao = "default-airport-icao"
        case update_method = "default-update-method"
        case runway = "default-runway"
        case wind_speed = "last-wind-speed"
        case wind_direction = "last-wind-direction"
        case analysis_is_displayed = "analysis-is-displayed"
        case starting_mode = "starting-mode"
        case last_airports_list = "last-airport-list"
        case last_nearest_list = "last-nearest-list"
    }
    
    static func registerDefaults() {
        UserDefaults.standard.register(defaults: [
            Key.airport_icao.rawValue  : Self.defaultIcao,
            Key.update_method.rawValue : Self.defaultUpdateMethod.rawValue,
            Key.runway.rawValue        : Self.defaultRunway,
            Key.wind_speed.rawValue    : 10,
            Key.wind_direction.rawValue : (Self.defaultRunway * 10 + 10) % 360,
            Key.starting_mode.rawValue : StartingMode.last.rawValue,
            Key.last_airports_list.rawValue : [],
            Key.last_nearest_list.rawValue : [],
        ])
    }
    
    @UserStorage(key: Key.last_airports_list.rawValue, defaultValue: [])
    var lastAirportsList : [String]
    
    @UserStorage(key: Key.analysis_is_displayed.rawValue, defaultValue: true)
    var analysisIsDisplayed : Bool
    
    @UserStorage(key: Key.airport_icao.rawValue, defaultValue: "EGLL")
    var airportIcao : String
    
    var startingMode : StartingMode {
        get {
            if let rawMode = UserDefaults.standard.string(forKey: Key.starting_mode.rawValue),
               let mode = StartingMode(rawValue: rawMode) {
                return mode
            }else{
                return .last
            }
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: Key.starting_mode.rawValue)
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
