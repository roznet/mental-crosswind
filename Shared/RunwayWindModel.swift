//
//  RunwayWindModel.swift
//  MentalCrosswind
//
//  Created by Brice Rosenzweig on 23/04/2022.
//

import Foundation
import RZFlight

extension RunwayWindModel {
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
