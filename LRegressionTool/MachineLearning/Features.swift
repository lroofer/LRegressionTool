//
//  LinearRegression.swift
//  Linear Regression
//
//  Created by Егор Колобаев on 12.08.2023.
//

import Foundation

enum Parameter {
    case id, target, level, number, off
}

protocol Feature {
    var name: String {get}
    var value: String?  { get }
    func getFormatted() -> [Double]
    init(name: String, value: String)
}

struct LevelFeauture: Feature {
    static var allValues = [String: Set<String>]()
    
    var name: String
    var value: String?
    
    func getFormatted() -> [Double] {
        var vs = [Double]()
        for i in LevelFeauture.allValues[name]! {
            vs.append(i == value ? 1 : 0)
        }
        if vs.count == 1 {
            fatalError("LevelFeature \(name) doesn't require LevelFeature's terms! Change it or delete!")
        }
        vs.removeLast()
        return vs
    }
    init(name: String, value: String) {
        if LevelFeauture.allValues[name] == nil {
            LevelFeauture.allValues[name] = Set<String>()
        }
        LevelFeauture.allValues[name]!.insert(value)
        self.value = value
        self.name = name
    }
}

struct NumberValueFeature: Feature {
    static var allValues = [String: (Double, Int)]()
    
    var name: String
    var value: String?
    
    func getFormatted() -> [Double] {
        if value != nil {
            if let returnValue = Double(value!) {
                return [returnValue]
            }
        }
        if NumberValueFeature.allValues[name]!.1 < 1 {
            fatalError("NumberValueFeature \(name) doesn't require terms! Change it or delete!")
        }
        return [NumberValueFeature.allValues[name]!.0 / Double(NumberValueFeature.allValues[name]!.1)]
    }
    init(name: String, value: String) {
        self.name = name
        if let returnValue = Double(value) {
            self.value = value
            if NumberValueFeature.allValues[name] == nil {
                NumberValueFeature.allValues[name] = (0, 0)
            }
            NumberValueFeature.allValues[name]!.0 += returnValue
            NumberValueFeature.allValues[name]!.1 += 1
        } else {
            self.value = nil
        }
    }
    
}
