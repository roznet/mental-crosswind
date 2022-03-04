//
//  MentalCrosswindTests.swift
//  MentalCrosswindTests
//
//  Created by Brice Rosenzweig on 13/02/2022.
//

import XCTest
@testable import MentalCrosswind

class MentalCrosswindTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testHeading() throws {
        let tests = [ (240, 60), (270, 90), (180,0), (20, 200)]
        for test in tests {
            let h1 = test.0
            let h2 = test.1
            XCTAssertEqual(Heading(roundedHeading: h1).opposing, Heading(roundedHeading: h2))
            XCTAssertEqual(Heading(roundedHeading: h2).opposing, Heading(roundedHeading: h1))
        }
    }


}
