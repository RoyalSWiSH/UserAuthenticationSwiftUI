//
//  UserAuthenticationSwiftUITests.swift
//  UserAuthenticationSwiftUITests
//
//  Created by Sebastian Roy on 25.12.21.
//

import XCTest
import SwiftUI
@testable import Gelly

class UserAuthenticationSwiftUITests: XCTestCase {
    @State var pixelToBasepairReferenceLadder = [PixelToBasePairArray(yPixel: 0, basePair: 0), PixelToBasePairArray(yPixel: 1, basePair: 1)]
    let band = Band(column: 0, bpSize: -1, intensity: "low", smear: "low", xid: "jafsde", confidence: 0.22, xMin: 20, yMin: 20, xMax: 30, yMax: 30)
    
    
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    // Currently not a functional test, just get the test suite startet
    func testLinearMappingFromPixelToBasePair() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.

        let expectedOutput = 1.0
        // Can I initialize this outside like in init?
        let bandView = BandView(pixelToBasepairReferenceLadder: self.$pixelToBasepairReferenceLadder, band: band)
        
        XCTAssertEqual(bandView.linearMappingFromPixelToBasePair(yPositionInPixels: 0, slope: 1.0, yCross: 1.0), expectedOutput, "Linear function to convert pixels to base pairs is not fittet correctly.")
    }

    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
