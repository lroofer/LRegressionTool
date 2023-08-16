//
//  SaveDirectory.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 14.08.2023.
//

import SwiftUI

struct SaveDirectory: View {
    @ObservedObject var storage: Storage
    @State private var isClassification = false
    var body: some View {
        HStack (spacing: 20) {
            Button {
                let panel = NSSavePanel()
                panel.nameFieldLabel = "Output file"
                panel.nameFieldStringValue = "proj.csv"
                if panel.runModal() == .OK {
                    storage.saveDirectory = panel.url
                    var s = "\(storage.allFeatures[storage.id!]),\(storage.allFeatures[storage.target!])\n"
                    for i in 0..<storage.ids!.count {
                        if isClassification {
                            let close0 = storage.predictions![i]
                            let close1 = abs(storage.predictions![i] - 1)
                            let ans = close0 < close1 ? 0 : 1
                            s += "\(storage.ids![i]),\(ans)\n"
                        } else {
                            s += "\(storage.ids![i]),\(storage.predictions![i])\n"
                        }
                    }
                    do {
                        try s.write(to: panel.url!, atomically: true, encoding: String.Encoding.utf8)
                    } catch {
                        fatalError("Cannot write!")
                    }
                }
                
            } label: {
                Label("Download", systemImage: "arrow.down.app")
            }
            .frame(width: 100)
            Toggle("Classify: 0/1", isOn: $isClassification)
                .toggleStyle(.checkbox)
        }
    }
}

struct SaveDirectory_Previews: PreviewProvider {
    static var previews: some View {
        SaveDirectory(storage: Storage())
    }
}
