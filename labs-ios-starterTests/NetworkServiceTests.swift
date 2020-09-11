//
//  NetworkServiceTests.swift
//  labs-ios-starterTests
//
//  Created by Kenny on 9/9/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import XCTest
@testable import labs_ios_starter

class NetworkServiceTests: XCTestCase {
    let networkService = NetworkService()

    func testGetRequestNoError() {
        let expectation = self.expectation(description: "Test GET Request Valid URL No Error")

        guard let request = networkService.createRequest(url: URL(string: "https://auth.lambdalabs.dev/")!, method: .get) else {
            XCTFail("invalid request")
            return
        }

        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                XCTAssertNotNil(data)
            case .failure(let error):
                //if this were a view controller, presentNetworkError(error: error.rawValue)
                XCTFail("Network error when none expected: \(error)")
            }
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3.0)

    }

    func testGetRequestWith404Error() {
        var expectation: XCTestExpectation? = self.expectation(description: "Test GET Request  with invalid URL")
        // make GET request
        guard let request = networkService.createRequest(url: URL(string: "https://auth.lambdalabs.dev/myveryspecificlinkthatdoesntexist.html")!, method: .get) else {
            XCTFail("invalid request")
            return
        }
        //make network call
        networkService.loadData(using: request) { result in
            switch result {
            case .success(let _):
                XCTFail("This shouldn't pass since /myveryspecificlinkthatdoesntexist.html is a dead endpoint")
            case .failure(let error):
                XCTAssertEqual(error, ErrorHandler.NetworkError.notFound)
                XCTAssertEqual(error.rawValue, 404)
                // this is one we want to present to the user in many applications
                // consider moving to internal errors in this application
                XCTAssertNotNil(ErrorHandler.userNetworkErrors[error.rawValue])
            }

            expectation?.fulfill()
            //hitting edge case with self.expectation being used twice
            expectation = nil
        }
        wait(for: [expectation!], timeout: 3.0)
    }
    

}
