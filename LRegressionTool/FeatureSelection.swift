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
