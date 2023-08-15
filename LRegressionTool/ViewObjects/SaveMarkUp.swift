//
//  SaveMarkUp.swift
//  LRegressionTool
//
//  Created by Егор Колобаев on 15.08.2023.
//

import SwiftUI

struct SaveMarkUp: View {
    @ObservedObject var storage: Storage
    @State private var errorMessage: String? = nil
    func saveFeatures() {
        errorMessage = nil
        let panel = NSSavePanel()
        panel.nameFieldLabel = "Markup file"
        panel.nameFieldStringValue = "markup.lrt"
        if panel.runModal() == .OK {
            var s = ""
            for i in 0..<storage.allFeatures.count {
                s.append("\(storage.allFeatures[i]),\(storage.statesFeatures[i])\n")
            }
            guard ((try? s.write(to: panel.url!, atomically: true, encoding: String.Encoding.utf8)) != nil) else {
                errorMessage = "No access!"
                return
            }
        }
    }
    var body: some View {
        VStack{
            Button("Save features' markup", action: saveFeatures)
        }
    }
}

struct SaveMarkUp_Previews: PreviewProvider {
    static var previews: some View {
        SaveMarkUp(storage: Storage())
    }
}
