//
//  String.swift
//  Assignment4
//
//  Created by Can Wang on 30/10/17.
//  Copyright © 2017 Can Wang. All rights reserved.
//

// class for String to Double, Float and Int
extension String {
    var doubleValue: Double? {
        return Double(self)
    }
    var floatValue: Float? {
        return Float(self)
    }
    var integerValue: Int? {
        return Int(self)
    }
}
