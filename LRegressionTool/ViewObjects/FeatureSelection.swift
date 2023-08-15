//
//  FeatureSelection.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 12.08.2023.
//

import SwiftUI

struct FeatureSelection: View {
    @ObservedObject var storage: Storage
    @State var errorMessage: String? = nil
    @Environment(\.dismiss) var dismiss
    let states = ["Off", "Level", "Number", "ID", "Target"]
    var statesFeatures: [String]
    func load() {
        errorMessage = nil
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        if panel.runModal() == .OK {
            guard let url = panel.url else {
                errorMessage = "File is not accessible"
                return
            }
            if url.lastPathComponent.components(separatedBy: ".").last != "lrt" {
                errorMessage = "You should select .lrt file, \(panel.url!.lastPathComponent) is not active extension"
                return
            }
            guard let data = try? String(contentsOf: url).components(separatedBy: "\n") else {
                errorMessage = "Can't read markup from the file! Choose another .lrt file!"
                return
            }
            var markup = [String]()
            var skipped = 0
            for i in 0..<data.count {
                if data[i].isEmpty {
                    skipped += 1
                    continue
                }
                let doubleValue = data[i].components(separatedBy: ",")
                if doubleValue.count != 2 {
                    errorMessage = "\(url.lastPathComponent) was damaged"
                    return
                }
                if storage.allFeatures[i - skipped] != doubleValue[0] {
                    errorMessage = "\(doubleValue[0]) doesn't correspond the feature's format of train file"
                    return
                }
                var isOK = false
                for j in states {
                    if j != doubleValue[1] {
                        continue
                    }
                    markup.append(doubleValue[1])
                    isOK = true
                    break
                }
                if (!isOK) {
                    errorMessage = "\(doubleValue[1]) is not a state"
                    return
                }
            }
            if storage.allFeatures.count != markup.count {
                errorMessage = "Data was lost, \(url.lastPathComponent) was damaged!"
                return
            }
            storage.statesFeatures = markup
        }
    }
    var body: some View {
        VStack (alignment: .leading) {
            HStack {
                Text("Features")
                    .font(.title.bold())
                Button("Apply") {
                    errorMessage = nil
                    var id = -1, target = -1
                    var countOn = 0
                    for i in 0..<storage.statesFeatures.count {
                        if storage.statesFeatures[i] == "ID" {
                            if id != -1 {
                                errorMessage = "Ambigious ID value"
                                return
                            }
                            id = i
                        }
                        else if storage.statesFeatures[i] == "Target" {
                            if target != -1 {
                                errorMessage = "Ambigious target value"
                                return
                            }
                            target = i
                        }
                        else if storage.statesFeatures[i] != "Off" {
                            countOn += 1
                        }
                    }
                    if id == -1 {
                        errorMessage = "Select ID"
                        return
                    }
                    if target == -1 {
                        errorMessage = "Select target"
                        return
                    }
                    if countOn < 1 {
                        errorMessage = "Select features"
                        return
                    }
                    storage.statesFeatures = statesFeatures
                    storage.selected = countOn
                    storage.target = target
                    storage.id = id
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                Button("Cancel") {
                    dismiss()
                }
                Button("Load markup") {
                    load()
                }
                if errorMessage != nil {
                    Label(errorMessage!, systemImage: "xmark.seal")
                        .foregroundColor(.red)
                }
            }
            List {
                ForEach(0..<storage.allFeatures.count, id: \.self) { i in
                    HStack {
                        Text(storage.allFeatures[i])
                        Spacer()
                        Picker("Type:", selection: $storage.statesFeatures[i]) {
                            ForEach(states, id:\.self) {
                                Text($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .labelsHidden()
                    }
                }
            }
            .background(.secondary)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
        .padding(20)
        .background(LinearGradient(colors: [.cyan, .indigo], startPoint: .topLeading, endPoint: .bottomTrailing))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
    init(storage: Storage) {
        self.storage = storage
        self.statesFeatures = storage.statesFeatures
    }
}

struct FeatureSelection_Previews: PreviewProvider {
    static var previews: some View {
        FeatureSelection(storage: Storage())
    }
}
