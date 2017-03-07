// The MIT License (MIT)
//
// Copyright (c) 2016 Robert Gummesson
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

//
//  UserCache.swift
//  BuildTimeAnalyzer
//

import Foundation

class UserSettings {
    
    static private let derivedDataLocationKey = "derivedDataLocationKey"
    static private let windowLevelIsNormalKey = "windowLevelIsNormalKey"
    
    static private var _derivedDataLocation: String?
    static private var _windowLevelIsNormal: Bool?
    
    static var derivedDataLocation: String {
        get {
            if _derivedDataLocation == nil {
                _derivedDataLocation = UserDefaults.standard.string(forKey: derivedDataLocationKey)
            }
            if _derivedDataLocation == nil, let libraryFolder = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first {
                _derivedDataLocation = "\(libraryFolder)/Developer/Xcode/DerivedData"
            }
            return _derivedDataLocation ?? ""
        }
        set {
            _derivedDataLocation = newValue
            UserDefaults.standard.set(newValue, forKey: derivedDataLocationKey)
            UserDefaults.standard.synchronize()
        }
    }
    
    static var windowShouldBeTopMost: Bool {
        get {
            if _windowLevelIsNormal == nil {
                _windowLevelIsNormal = UserDefaults.standard.bool(forKey: windowLevelIsNormalKey)
            }
            return !(_windowLevelIsNormal ?? true)
        }
        set {
            _windowLevelIsNormal = !newValue
            UserDefaults.standard.set(_windowLevelIsNormal, forKey: windowLevelIsNormalKey)
            UserDefaults.standard.synchronize()
        }
    }
}
