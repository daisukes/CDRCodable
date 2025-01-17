/////
////  CDRCodableEncodingTests.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import XCTest
@testable import CDRCodable

class CDRCodableEncodingTests: XCTestCase {
    var encoder: CDREncoder!
    
    override func setUp() {
        self.encoder = CDREncoder()
    }

    func testEncodeFalse() {
        let value = try! encoder.encode(false)
        XCTAssertEqual(value, Data([0, 0, 0, 0]))
    }
    
    func testEncodeTrue() {
        let value = try! encoder.encode(true)
        XCTAssertEqual(value, Data([1, 0, 0, 0]))
    }
    
    func testEncodeInt32() {
        let value = try! encoder.encode(42 as Int32)
        XCTAssertEqual(value, Data([0x2A, 0, 0, 0]))
    }
    
    func testEncodeUInt32() {
        let value = try! encoder.encode(128 as UInt32)
        XCTAssertEqual(value, Data([0x80, 0, 0, 0]))
    }
    
    func testEncodeFloat() {
        let value = try! encoder.encode(3.14 as Float)
        XCTAssertEqual(value, Data([0xC3, 0xF5, 0x48, 0x40]))
    }
    
    func testEncodeDouble() {
        let value = try! encoder.encode(3.14159 as Double)
        XCTAssertEqual(value, Data([0x6E, 0x86, 0x1B, 0xF0, 0xF9, 0x21, 0x09, 0x40]))
    }
    
    func testEncodeString() {
        let value = try! encoder.encode("hello")
        XCTAssertEqual(value, Data([6, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    func testEncodeArray() {
        let array: [Int16] = [1, 2, 3]
        let value = try! encoder.encode(array)
        XCTAssertEqual(value, Data([3, 0, 0, 0, 1, 0, 2, 0, 3, 0, 0, 0]))
    }
    
    func testEncodeData() {
        let data = "hello".data(using: .utf8)
        let value = try! encoder.encode(data)
        XCTAssertEqual(value, Data([5, 0, 0, 0, 0x68, 0x65, 0x6C, 0x6C, 0x6F, 0, 0, 0]))
    }
    
    func testEncodeStruct() {
        struct TestStruct: Codable {
            let i: Int16
            let s: String
            let a: [Int16]
        }
        
        let value = TestStruct(i: 0x55, s: "Test string", a: [1,2,3,4,5,6,7,8,9])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([0x55, 0, 0, 0, 0x0c, 0, 0, 0, 0x54, 0x65, 0x73, 0x74, 0x20, 0x73, 0x74, 0x72, 0x69, 0x6e, 0x67, 0, 0x09, 0, 0, 0, 1, 0, 2, 0, 3, 0, 4, 0, 5, 0, 6, 0, 7, 0, 8, 0, 9, 0, 0, 0]))
    }

    func testEncodeStructWithAlignment() {
        struct TestStruct: Codable {
            let a: Int8
            let b: Int16
            let c: Int16
            let d: Int32
            let e: Int64
        }

        let value = TestStruct(a: 1, b: 2, c: 3, d: 4, e: 5)
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([
            0x01, 0, 0x02, 0, 0x03, 0, 0, 0,
            0x04, 0, 0,    0, 0,    0, 0, 0,
            0x05, 0, 0,    0, 0,    0, 0, 0]))
    }

    func testEncodeStructArrayWithoutAlignment() {
        struct TestStruct: Codable {
            let a: [Int8]
            let b: [Int16]
            let c: [Int16]
            let d: [Int32]
            let e: [Int64]
        }

        let value = TestStruct(a: [1, 1, 1, 1], b: [2, 2], c: [3, 3], d: [4, 4], e: [5])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([
            0x04, 0, 0, 0, 0x01, 0x01, 0x01, 0x01,
            0x02, 0, 0, 0, 0x02, 0,    0x02, 0,
            0x02, 0, 0, 0, 0x03, 0,    0x03, 0,
            0x02, 0, 0, 0, 0x04, 0,    0,    0,
            0x04, 0, 0, 0, 0x01, 0,    0,    0,
            0x05, 0, 0, 0, 0,    0,    0,    0]))
    }

    func testEncodeStructArrayWithAlignment() {
        struct TestStruct: Codable {
            let a: [Int8]
            let b: [Int16]
            let c: [Int16]
            let d: [Int32]
            let e: [Int64]
        }

        let value = TestStruct(a: [1], b: [2], c: [3], d: [4], e: [5])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([
            0x01, 0, 0, 0, 0x01, 0, 0, 0,
            0x01, 0, 0, 0, 0x02, 0, 0, 0,
            0x01, 0, 0, 0, 0x03, 0, 0, 0,
            0x01, 0, 0, 0, 0x04, 0, 0, 0,
            0x01, 0, 0, 0, 0,    0, 0, 0,
            0x05, 0, 0, 0, 0,    0, 0, 0]))
    }

    func testEncodeArrayOfStruct() {
        struct TestStruct: Codable {
            let a: Int32
            let b: Int32
        }

        let value = [TestStruct(a: 1, b: 2), TestStruct(a: 3, b: 4)]
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([
            0x02, 0, 0, 0,
            0x01, 0, 0, 0, 0x02, 0, 0, 0,
            0x03, 0, 0, 0, 0x04, 0, 0, 0]))
    }

    func testEncodeArrayOfStructWithAlignment() {
        struct TestStruct: Codable {
            let a: String
            let b: [TestStruct2]
        }
        struct TestStruct2: Codable {
            let a: Int32
            let b: Int32
        }
        let value = TestStruct(a: "a", b: [TestStruct2(a: 1, b: 2), TestStruct2(a: 3, b: 4)])
        let data = try! encoder.encode(value)
        XCTAssertEqual(data, Data([
            0x02, 0, 0, 0, 0x61, 0, 0, 0,
            0x02, 0, 0, 0,
            0x01, 0, 0, 0, 0x02, 0, 0, 0,
            0x03, 0, 0, 0, 0x04, 0, 0, 0]))
    }
}
