//
//  LinearRegression.swift
//  Linear Regression
//
//  Created by Егор Колобаев on 12.08.2023.
//

import Foundation

protocol Feature {
    var name: String {get}
    var value: String?  { get }
    func getFormatted() -> [Double]
    init(name: String, value: String)
}

struct LevelFeauture: Feature {
    static var allValues = [String: Int]()
    
    var name: String
    var value: String?
    
    func getFormatted() -> [Double] {
        var vs = [Double]()
        for i in LevelFeauture.allValues {
            vs.append(i.key == value ? 1 : 0)
        }
        if vs.count == 1 {
            fatalError("LevelFeature \(name) doesn't require LevelFeature's terms! Change it or delete!")
        }
        vs.removeLast()
        return vs
    }
    init(name: String, value: String) {
        LevelFeauture.allValues[value] = (LevelFeauture.allValues[value] ?? 0) + 1
        self.value = value
        self.name = name
    }
}

struct NumberValueFeature: Feature {
    static var sumValues: Double = 0
    static var countValues: Double = 0
    static var mid: Double {(sumValues + countValues) / 2 }
    
    var name: String
    var value: String?
    
    func getFormatted() -> [Double] {
        if value != nil {
            if let returnValue = Double(value!) {
                return [returnValue]
            }
        }
        if NumberValueFeature.countValues < 1 {
            fatalError("NumberValueFeature \(name) doesn't require terms! Change it or delete!")
        }
        return [NumberValueFeature.mid]
    }
    init(name: String, value: String) {
        self.name = name
        if let returnValue = Double(value) {
            self.value = value
            NumberValueFeature.countValues += 1
            NumberValueFeature.sumValues += returnValue
        } else {
            self.value = nil
        }
    }
    
}
