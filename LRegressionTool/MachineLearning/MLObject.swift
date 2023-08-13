//
//  MLObject.swift
//  Linear Regression
//
//  Created by Егор Колобаев on 12.08.2023.
//

import Foundation

class MLObject: Identifiable {
    let id: Int
    var features: [Feature]
    func getData() -> [Double] {
        var arr: [Double] = [1]
        for i in features {
            for j in i.getFormatted() {
                arr.append(j)
            }
        }
        return arr
    }
    init(id: Int, features: [Feature]) {
        self.features = features
        self.id = id
    }
    init(format: [String], current: [String], with translator: [String: Parameter]) {
        if format.count != current.count {
            fatalError("Current row doesn't follow given format!")
        }
        self.features = []
        var id: Int? = nil
        for i in 0..<format.count {
            guard let type = translator[format[i]] else {
                fatalError("Type of \(format[i]) wasn't set")
            }
            switch type {
            case .id:
                id = Int(current[i])!
            case .level:
                self.features.append(LevelFeauture(name: format[i], value: current[i]))
            case .number:
                self.features.append(NumberValueFeature(name: format[i], value: current[i]))
            default:
                continue
            }
        }
        self.id = id!
    }
}
