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

    @discardableResult func decodeAirport(icao : String) -> Airport? {
        guard let url = Bundle(for: type(of: self)).url(forResource: "station-\(icao)", withExtension: "json") else { XCTAssertTrue(false); return nil}
        do {
            let data = try Data(contentsOf: url)
            let airport = try JSONDecoder().decode(Airport.self, from: data)
            XCTAssertEqual(airport.icao.uppercased(), icao.uppercased())
            return airport
        } catch {
            print( "\(error)" )
            XCTAssertTrue(false)
        }
        return nil
    }

    @discardableResult func decodeNear(location : String) -> [Airport]? {
        guard let url = Bundle(for: type(of: self)).url(forResource: "near-\(location)", withExtension: "json") else { XCTAssertTrue(false); return nil}
        do {
            let data = try Data(contentsOf: url)
            let airports = try JSONDecoder().decode([Airport.Near].self, from: data)
            XCTAssertEqual(airports.count, 5)
            return airports.map { $0.station }
        } catch {
            print( "\(error)" )
            XCTAssertTrue(false)
        }
        return nil
    }

    @discardableResult func decodeMetar(icao : String) -> Metar? {
        guard let url = Bundle(for: type(of: self)).url(forResource: "metar-\(icao)", withExtension: "json") else { XCTAssertTrue(false); return nil}
        do {
            let data = try Data(contentsOf: url)
            let metar = try Metar.metar(json: data)
            
            XCTAssertGreaterThan(metar.wind_speed.value, 0)
            XCTAssertGreaterThan(metar.wind_direction.value, 0)
            return metar
        } catch {
            print( "\(error)" )
            XCTAssertTrue(false)
        }
        return nil
    }

    
    func testAirport(){
        decodeAirport(icao: "egll")
        decodeAirport(icao: "eglf")
        decodeAirport(icao: "egtf")
        decodeAirport(icao: "kpao")
    }
    
    func testNear(){
        decodeNear(location: "london")
        decodeNear(location: "paloalto")
    }
    
    func testMetar(){
        decodeMetar(icao: "eglf")
        decodeMetar(icao: "egll")
        decodeMetar(icao: "kpao")
        decodeMetar(icao: "ksfo")
    }
    
    func testRunway(){
        let icao = "ksfo"
        if let airport = decodeAirport(icao: icao) {
            print( airport.bestRunway(wind: Heading(heading: 180)) )
        }
        
        
    }
}
