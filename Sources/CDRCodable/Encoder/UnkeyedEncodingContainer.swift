/////
////  UnkeyedEncodingContainer.swift
///   Copyright © 2024 Dmitriy Borovikov. All rights reserved.
//

import Foundation

extension _CDREncoder {
    struct UnkeyedContainer: _CDREncodingContainer {
        var count: Int = 0
        private var index: Data.Index
        var codingPath: [CodingKey]
        var userInfo: [CodingUserInfoKey: Any]
        var dataStore: DataStore

        init(dataStore: DataStore, codingPath: [CodingKey], userInfo: [CodingUserInfoKey : Any]) {
            self.codingPath = codingPath
            self.userInfo = userInfo
            self.dataStore = dataStore
            let count: UInt32 = 0
            dataStore.write(value: count)
            self.index = dataStore.data.endIndex - MemoryLayout<UInt32>.size
        }
    }
}

extension _CDREncoder.UnkeyedContainer: UnkeyedEncodingContainer {
    func encodeNil() throws {}
    
    mutating func encode<T>(_ value: T) throws where T : Encodable {
        defer {
            count += 1
            if let count32 = UInt32(exactly: count) {
                let range = index..<index+MemoryLayout<UInt32>.size
                self.dataStore.data.replaceSubrange(range, with: count32.bytes)
            }
        }
        let encoder = _CDREncoder(data: self.dataStore)
        try value.encode(to: encoder)
    }
    
    func nestedContainer<NestedKey>(keyedBy keyType: NestedKey.Type) -> KeyedEncodingContainer<NestedKey> where NestedKey : CodingKey {
        fatalError("Unimplemented")
    }
    
    func nestedUnkeyedContainer() -> UnkeyedEncodingContainer {
        fatalError("Unimplemented")
    }
    
    func superEncoder() -> Encoder {
        fatalError("Unimplemented")
    }
}
