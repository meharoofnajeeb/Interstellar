//
//  ObservableTests.swift
//  Interstellar
//
//  Created by Jens Ravens on 11/04/16.
//  Copyright © 2016 nerdgeschoss GmbH. All rights reserved.
//

import XCTest
import Interstellar

internal class Fail: Error, Equatable {
  public static func ==(lhs: Fail, rhs: Fail) -> Bool {
    return lhs.error == rhs.error
  }
  
  let error: String
  
  internal init(_ error: String) {
    self.error = error
  }
}


class ResultObservableTests: XCTestCase {
    
    func greeter(_ subject: String) -> String {
        return "Hello \(subject)"
    }
    
    func throwingGreeter(_ subject: String) throws -> String {
        if subject.count > 0 {
            return "Hello \(subject)"
        } else {
            throw Fail("No one to greet!")
        }
    }
    
    func asyncGreeter(_ subject: String) -> Observable<String> {
        return Observable("Hello \(subject)")
    }
    
    func asyncFail(_ subject: String) -> Observable<Result<String, Error>> {
        return Observable(.failure(Fail("Fail")))
    }
    
    func neverCallMe(_ subject: String) -> Observable<Result<String, Error>> {
        XCTFail()
        return Observable()
    }
    
    var world: Observable<Result<String, Error>> {
        return Observable(Result.success("World"))
    }
    
    var nothing: Observable<Result<String, Error>> {
        return Observable(Result.success(""))
    }
    
    func testContinuingTheChain() {
        let greeting = world.then(greeter).then(throwingGreeter)
        XCTAssertEqual(greeting.peek(), "Hello Hello World")
    }
    
    func testError() {
        let greeting = nothing.then(throwingGreeter).peek()
        XCTAssertNil(greeting)
    }

    func testAsyncChain() {
        let greeting = world.then(asyncGreeter)
        XCTAssertEqual(greeting.peek()!, "Hello World")
    }

    func testAsyncFail() {
        let greeting = world.then(asyncFail).then(neverCallMe)
        var error: Error?
        greeting.error { error = $0 }
        XCTAssertNil(greeting.peek())
        XCTAssertNotNil(error)
    }
}
