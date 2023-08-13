//
//  Storage.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 13.08.2023.
//

import Foundation

class Storage: ObservableObject {
    @Published var selected: Int? = nil
    @Published var target: Int? = nil
    @Published var id: Int? = nil
    @Published var allFeatures: [String] = []
    @Published var statesFeatures: [String] = []
    @Published var runError: RunErrors? = nil
    var trainData: [String] = []
    var testData: [String] = []
}
