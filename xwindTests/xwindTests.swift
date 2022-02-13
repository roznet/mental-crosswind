//
//  xwindTests.swift
//  xwindTests
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import XCTest
@testable import MentalCrosswind

class xwindTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        
        let runway = Heading(roundedHeading: 240 )
        let wind = Heading(roundedHeading: 190)
                
        let model = RunwayWindModel(runway: runway, wind: wind, speed: Speed(roundedSpeed: 12), gust: nil)

        print( "\(model.announce)")
        print( "\(model.hint())")
        print( "\(model.analyseHint())")
        print( "\(model.analyse())")
    }

}
