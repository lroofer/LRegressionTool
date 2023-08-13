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
        var arr = [Double]()
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
}
