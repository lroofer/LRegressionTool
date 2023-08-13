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
        let tol: Double?
        if tit == "nil" {
            tol = nil
        } else {
            tol = Double(tit)
        }
        var ML = MLModel(alpha: alpha, s: s, m: storage.selected!, tit: tol)
        
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
