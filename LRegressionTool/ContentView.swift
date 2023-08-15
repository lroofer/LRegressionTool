//
//  ContentView.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 12.08.2023.
//

import SwiftUI

struct ContentView: View {
    @State var trainFile: URL? = nil
    @State var testFile: URL? = nil
    @State var showFeatures = false
    @State var errorMessage: String? = "Choose files first"
    @StateObject var storage = Storage()
    @State var alpha = 0.45
    @State var s = 1000
    @State var tit = "nil"
    @State var savePath = "~/Desktop/proj.csv"
    @State var success = false
    var titOK: Bool {
        tit == "nil" || Double(tit) != nil
    }
    func tryUpload() {
        if trainFile == nil || testFile == nil {
            errorMessage = "Choose files first"
            return
        }
        let trainDataString = try? String(contentsOf: trainFile!)
        let testDataString = try? String(contentsOf: testFile!)
        if trainDataString == nil || testDataString == nil {
            errorMessage = "Data from files is not readable"
            return
        }
        errorMessage = nil
        storage.trainData = trainDataString!.components(separatedBy: "\n")
        storage.testData = testDataString!.components(separatedBy: "\n")
        storage.allFeatures = storage.trainData[0].components(separatedBy: ",")
        storage.statesFeatures = Array<String>(repeating: "Off", count: storage.allFeatures.count)
    }
    func run() {
        success = false
        let tol: Double?
        if tit == "nil" {
            tol = nil
        } else {
            tol = Double(tit)
        }
        let ML = MLModel(alpha: alpha, s: s, m: storage.selected!, tit: tol)
        var translator = [String: Parameter]()
        for i in 0..<storage.allFeatures.count {
            let value: Parameter
            switch (storage.statesFeatures[i]) {
            case "ID":
                value = .id
            case "Level":
                value = .level
            case "Number":
                value = .number
            case "Target":
                value = .target
            default:
                value = .off
            }
            translator[storage.allFeatures[i]] = value
        }
        var trainDataObjects = [MLObject]()
        var targets = [Double]()
        var testDataObjects = [MLObject]()
        for i in 1..<storage.trainData.count {
            if storage.trainData[i].isEmpty {
                continue
            }
            let vals = storage.trainData[i].components(separatedBy: ",")
            if Int(vals[storage.id!]) == nil {
                storage.runError = .IDValueMustExistAsAnInteger
                return
            }
            guard let target = Double(vals[storage.target!]) else {
                storage.runError = .TargetValueMustExistAsAnInteger
                return
            }
            targets.append(target)
            trainDataObjects.append(MLObject(format: storage.allFeatures, current: vals, with: translator))
        }
        let formatTest = storage.testData[0].components(separatedBy: ",")
        var idColumn = 0
        for i in 0..<formatTest.count {
            if translator[formatTest[i]] == .id {
                idColumn = i
            }
        }
        storage.ids = []
        for i in 1..<storage.testData.count {
            if storage.testData[i].isEmpty {
                continue
            }
            let vals = storage.testData[i].components(separatedBy: ",")
            if Int(vals[idColumn]) == nil {
                storage.runError = .IDValueMustExistAsAnInteger
                return
            }
            testDataObjects.append(MLObject(format: formatTest, current: vals, with: translator))
            storage.ids?.append(testDataObjects.last!.id)
        }
        var trainData = Array<Array<Double>>()
        var testData = Array<Array<Double>>()
        for obj in trainDataObjects {
            trainData.append(obj.getData())
        }
        for obj in testDataObjects {
            testData.append(obj.getData())
        }
        ML.fit(trainData: trainData.flatMap{$0}, countData: trainData.count, countArray: targets)
        storage.predictions = ML.predict(testData: testData.flatMap{$0}, countData: testData.count)
        let copy = LevelFeauture.allValues
        success = true
    }
    var body: some View {
        ZStack (alignment: .topLeading) {
            LinearGradient(colors: [.cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing)
            VStack (alignment: .leading){
                Text("Linear regression")
                    .font(.largeTitle.bold())
                VStack(alignment: .leading) {
                    HStack{
                        Text("Train data: \(trainFile?.lastPathComponent ?? "N/A")")
                        Button("Add") {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK {
                                self.trainFile = panel.url
                                tryUpload()
                            }
                        }
                    }
                    HStack{
                        Text("Test data: \(testFile?.lastPathComponent ?? "N/A")")
                        Button("Add") {
                            let panel = NSOpenPanel()
                            panel.allowsMultipleSelection = false
                            panel.canChooseDirectories = false
                            if panel.runModal() == .OK {
                                self.testFile = panel.url
                                tryUpload()
                            }
                        }
                    }
                }
                HStack {
                    Button("Tag features") {
                        if testFile == nil || trainFile == nil {
                            return
                        }
                        showFeatures.toggle()
                    }
                    .sheet(isPresented: $showFeatures) {
                        FeatureSelection(storage: storage)
                            .frame(idealWidth: NSApp.keyWindow?.contentView?.bounds.width ?? 500, idealHeight: NSApp.keyWindow?.contentView?.bounds.height ?? 500)

                    }
                    if errorMessage != nil {
                        Image(systemName: "xmark.seal")
                        Text(errorMessage!)
                    } else {
                        if storage.selected == nil {
                            Text("\(storage.allFeatures.count) feature\(storage.allFeatures.count == 1 ? "" : "s")")
                        } else {
                            Text("Ready: \(storage.selected!) selected")
                        }
                    }
                }
                if (storage.target != nil && storage.id != nil) {
                    Text("ID: \(storage.allFeatures[storage.id!])")
                    Text("Target: \(storage.allFeatures[storage.target!])")
                    SaveMarkUp(storage: storage)
                    HStack {
                        TextField("Alpha", value: $alpha, format: .number)
                        TextField("Iterations", value: $s, format: .number)
                        TextField("Tolerance", text: $tit)
                    }
                    if titOK {
                        Button("Run") {
                            run()
                        }
                    } else {
                        Label("Tolerance must be Double? value", systemImage: "xmark.seal")
                    }
                    if storage.runError != nil {
                        Text("Runtime error: \(storage.runError! == .IDValueMustExistAsAnInteger ? "ID" : "Target")")
                            .foregroundColor(.red)
                    }
                    if (success) {
                        SaveDirectory(storage: storage)
                    }
                }
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
