//===----------------------------------------------------------------------===//
//
// This source file is part of the FastrangeSipHash open source project
//
// Copyright (c) 2022 fltrWallet AG and the FastrangeSipHash project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// SPDX-License-Identifier: Apache-2.0
//
//===----------------------------------------------------------------------===//
import Cfastrange
import CSipHash

@inlinable @inline(__always)
public func fastrange(_ hash: UInt64, _ f: UInt64) -> UInt64 {
    return Cfastrange.fastrange64(hash, f)
}

@inlinable @inline(__always)
public func fastrange64(_ hash: UInt64, _ f: UInt64) -> UInt64 {
    let hashHi: UInt64 = hash >> 32
    let hashLo: UInt64 = hash & 0xFF_FF_FF_FF
    let fHi: UInt64 = f >> 32
    let fLo: UInt64 = f & 0xFF_FF_FF_FF
    
    let ac = hashHi * fHi
    let ad = hashHi * fLo
    let bc = hashLo * fHi
    let bd = hashLo * fLo
    
    let mid34 = (bd >> 32) + (bc & 0xFF_FF_FF_FF) + (ad & 0xFF_FF_FF_FF)
    let upper64 = ac + (bc >> 32) + (ad >> 32) + (mid34 >> 32)
    return upper64
}

@inlinable
public func siphash<S: Sequence, T: Sequence>(input: S, key: T) -> UInt64 where S.Element == UInt8, T.Element == UInt8 {
    func _siphash(input: UnsafeBufferPointer<UInt8>, key: UnsafeBufferPointer<UInt8>) -> UInt64 {
        assert(key.count == 16)

        var result: UInt64 = 0
        withUnsafeMutableBytes(of: &result) {
            let cResult = CSipHash.siphash(input.baseAddress!, input.count, key.baseAddress!, $0.baseAddress!.bindMemory(to: UInt8.self, capacity: 8), 8)
            assert(cResult == 0)
        }
        return result
    }

    let output: UInt64? = input.withContiguousStorageIfAvailable { inputPointer in
        let inner = key.withContiguousStorageIfAvailable { keyPointer in
            _siphash(input: inputPointer, key: keyPointer)
        }
        guard let fastPathInner = inner else {
            return Array(key).withUnsafeBufferPointer { keyPointer in
                _siphash(input: inputPointer, key: keyPointer)
            }
        }
        return fastPathInner
    }
    guard let fastPathResult = output else {
        return Array(input).withUnsafeBufferPointer { inputPointer in
            Array(key).withUnsafeBufferPointer { keyPointer in
                _siphash(input: inputPointer, key: keyPointer)
            }
        }
    }
    return fastPathResult
}
